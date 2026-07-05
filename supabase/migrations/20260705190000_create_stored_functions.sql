-- Migration: 20260705190000_create_stored_functions.sql
-- Creates reusable database functions per strategy document

-- ─── calculate_exam_score() ─────────────────────────────────────────────────
-- Calculates weighted exam score from sections

CREATE OR REPLACE FUNCTION calculate_exam_score(attempt_id UUID)
RETURNS NUMERIC AS $$
DECLARE
  total_score NUMERIC := 0;
  total_weight NUMERIC := 0;
  section_record RECORD;
BEGIN
  FOR section_record IN
    SELECT score, max_score
    FROM exam_scores
    WHERE exam_scores.attempt_id = calculate_exam_score.attempt_id
      AND score IS NOT NULL
      AND max_score > 0
  LOOP
    total_weight := total_weight + section_record.max_score;
    total_score := total_score + section_record.score;
  END LOOP;

  IF total_weight = 0 THEN
    RETURN 0;
  END IF;

  RETURN ROUND((total_score / total_weight) * 100, 2);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── update_user_level() ────────────────────────────────────────────────────
-- Updates user level based on XP

CREATE OR REPLACE FUNCTION update_user_level(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  current_xp INTEGER;
  new_level INTEGER;
BEGIN
  SELECT xp INTO current_xp
  FROM user_profiles
  WHERE auth_user_id = p_user_id;

  -- Level formula: level = floor(sqrt(xp / 100)) + 1
  new_level := FLOOR(SQRT(COALESCE(current_xp, 0) / 100)) + 1;

  UPDATE user_profiles
  SET level = new_level
  WHERE auth_user_id = p_user_id;

  RETURN new_level;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── calculate_streak() ─────────────────────────────────────────────────────
-- Calculates and updates user streak

CREATE OR REPLACE FUNCTION calculate_streak(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  last_active DATE;
  current_streak INTEGER;
  today DATE := CURRENT_DATE;
BEGIN
  SELECT s.last_active_date, s.current_streak
  INTO last_active, current_streak
  FROM streaks s
  WHERE s.user_id = p_user_id;

  IF last_active IS NULL THEN
    -- First time, start streak
    INSERT INTO streaks (user_id, current_streak, longest_streak, last_active_date)
    VALUES (p_user_id, 1, 1, today)
    ON CONFLICT (user_id) DO UPDATE
    SET current_streak = 1,
        longest_streak = GREATEST(streaks.longest_streak, 1),
        last_active_date = today,
        updated_at = now();
    RETURN 1;
  ELSIF last_active = today THEN
    -- Already active today
    RETURN current_streak;
  ELSIF last_active = today - INTERVAL '1 day' THEN
    -- Consecutive day
    current_streak := current_streak + 1;
    UPDATE streaks
    SET current_streak = current_streak,
        longest_streak = GREATEST(longest_streak, current_streak),
        last_active_date = today,
        updated_at = now()
    WHERE user_id = p_user_id;
    RETURN current_streak;
  ELSE
    -- Streak broken
    INSERT INTO streaks (user_id, current_streak, longest_streak, last_active_date)
    VALUES (p_user_id, 1, 1, today)
    ON CONFLICT (user_id) DO UPDATE
    SET current_streak = 1,
        longest_streak = GREATEST(streaks.longest_streak, 1),
        last_active_date = today,
        updated_at = now();
    RETURN 1;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── refresh_dashboard() ────────────────────────────────────────────────────
-- Refreshes materialized view for dashboard (if using materialized views)

CREATE OR REPLACE FUNCTION refresh_dashboard()
RETURNS VOID AS $$
BEGIN
  -- This function can be called periodically to refresh dashboard data
  -- If materialized views are used, uncomment:
  -- REFRESH MATERIALIZED VIEW CONCURRENTLY user_dashboard_materialized;
  
  -- For now, this is a placeholder for dashboard refresh logic
  RAISE NOTICE 'Dashboard refresh completed at %', now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── schedule_review() ──────────────────────────────────────────────────────
-- Schedules next vocabulary review using spaced repetition

CREATE OR REPLACE FUNCTION schedule_review(
  p_user_id UUID,
  p_vocabulary_id UUID,
  p_quality INTEGER -- 0-5 quality of response
)
RETURNS TIMESTAMPTZ AS $$
DECLARE
  current_interval INTEGER;
  current_ease NUMERIC;
  next_review TIMESTAMPTZ;
BEGIN
  -- Get current SRS data
  SELECT review_count, mastery_level
  INTO current_interval, current_ease
  FROM vocabulary_history
  WHERE user_id = p_user_id AND vocabulary_id = p_vocabulary_id;

  -- Simple SM-2 algorithm adaptation
  IF p_quality >= 3 THEN
    -- Good response, increase interval
    IF current_interval IS NULL OR current_interval = 0 THEN
      current_interval := 1;
    ELSIF current_interval < 6 THEN
      current_interval := 6;
    ELSE
      current_interval := ROUND(current_interval * 1.5);
    END IF;
  ELSE
    -- Poor response, reset interval
    current_interval := 1;
  END IF;

  next_review := now() + (current_interval || ' days')::INTERVAL;

  -- Update vocabulary history
  INSERT INTO vocabulary_history (user_id, vocabulary_id, mastery_level, review_count, next_review)
  VALUES (p_user_id, p_vocabulary_id, p_quality * 20, 1, next_review)
  ON CONFLICT (user_id, vocabulary_id) DO UPDATE
  SET mastery_level = p_quality * 20,
      review_count = vocabulary_history.review_count + 1,
      next_review = schedule_review.next_review,
      updated_at = now();

  RETURN next_review;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── estimate_cefr() ────────────────────────────────────────────────────────
-- Estimates CEFR level based on vocabulary and performance

CREATE OR REPLACE FUNCTION estimate_cefr(p_user_id UUID)
RETURNS VARCHAR(5) AS $$
DECLARE
  word_count INTEGER;
  avg_mastery NUMERIC;
  exam_score NUMERIC;
  cefr_level VARCHAR(5);
BEGIN
  -- Get vocabulary stats
  SELECT COUNT(*), AVG(mastery_level)
  INTO word_count, avg_mastery
  FROM vocabulary_history
  WHERE user_id = p_user_id;

  -- Get best exam score
  SELECT MAX(percentage)
  INTO exam_score
  FROM exam_scores es
  JOIN exam_attempts ea ON ea.id = es.attempt_id
  WHERE ea.user_id = p_user_id;

  -- Estimate CEFR level
  IF word_count < 100 THEN
    cefr_level := 'A1';
  ELSIF word_count < 300 THEN
    cefr_level := 'A2';
  ELSIF word_count < 600 THEN
    cefr_level := 'B1';
  ELSIF word_count < 1200 THEN
    cefr_level := 'B2';
  ELSIF word_count < 2500 THEN
    cefr_level := 'C1';
  ELSE
    cefr_level := 'C2';
  END IF;

  -- Adjust based on exam score if available
  IF exam_score IS NOT NULL THEN
    IF exam_score >= 90 AND cefr_level < 'C1' THEN
      cefr_level := 'C1';
    ELSIF exam_score >= 75 AND cefr_level < 'B2' THEN
      cefr_level := 'B2';
    END IF;
  END IF;

  RETURN cefr_level;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── award_badge() ──────────────────────────────────────────────────────────
-- Awards a badge to a user if criteria are met

CREATE OR REPLACE FUNCTION award_badge(
  p_user_id UUID,
  p_badge_name VARCHAR
)
RETURNS BOOLEAN AS $$
DECLARE
  badge_record RECORD;
  criteria_met BOOLEAN := false;
BEGIN
  -- Get badge
  SELECT * INTO badge_record
  FROM badges
  WHERE name = p_badge_name AND is_active = true;

  IF badge_record IS NULL THEN
    RETURN false;
  END IF;

  -- Check if already earned
  IF EXISTS (SELECT 1 FROM user_badges WHERE user_id = p_user_id AND badge_id = badge_record.id) THEN
    RETURN false;
  END IF;

  -- Check criteria (simplified - expand based on actual criteria)
  criteria_met := true; -- Placeholder for actual criteria checking

  IF criteria_met THEN
    -- Award badge
    INSERT INTO user_badges (user_id, badge_id)
    VALUES (p_user_id, badge_record.id);

    -- Award XP if specified
    IF badge_record.xp_reward > 0 THEN
      UPDATE user_profiles
      SET xp = xp + badge_record.xp_reward
      WHERE auth_user_id = p_user_id;

      -- Record XP history
      INSERT INTO xp_history (user_id, amount, source, description)
      VALUES (p_user_id, badge_record.xp_reward, 'badge', 'Badge earned: ' || badge_record.name);
    END IF;

    RETURN true;
  END IF;

  RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── expire_subscription() ──────────────────────────────────────────────────
-- Expires subscriptions that have passed their expiration date

CREATE OR REPLACE FUNCTION expire_subscription(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  sub_record RECORD;
BEGIN
  SELECT * INTO sub_record
  FROM subscriptions
  WHERE user_id = p_user_id
    AND status = 'active'
    AND expires_at < now()
  LIMIT 1;

  IF sub_record IS NOT NULL THEN
    UPDATE subscriptions
    SET status = 'expired'
    WHERE id = sub_record.id;

    -- Create notification
    INSERT INTO notifications (user_id, title, body, type)
    VALUES (p_user_id, 'Subscription Expired', 'Your subscription has expired. Please renew to continue premium features.', 'subscription');

    RETURN true;
  END IF;

  RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Helper: Award XP ───────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION award_xp(
  p_user_id UUID,
  p_amount INTEGER,
  p_source VARCHAR,
  p_source_id UUID DEFAULT NULL,
  p_description TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
  new_balance INTEGER;
BEGIN
  -- Update user XP
  UPDATE user_profiles
  SET xp = xp + p_amount
  WHERE auth_user_id = p_user_id
  RETURNING xp INTO new_balance;

  -- Record in history
  INSERT INTO xp_history (user_id, amount, source, source_id, description, balance_after)
  VALUES (p_user_id, p_amount, p_source, p_source_id, p_description, new_balance);

  -- Update level
  PERFORM update_user_level(p_user_id);

  RETURN new_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Helper: Track Daily Progress ───────────────────────────────────────────

CREATE OR REPLACE FUNCTION track_daily_progress(
  p_user_id UUID,
  p_xp_earned INTEGER DEFAULT 0,
  p_lessons_completed INTEGER DEFAULT 0,
  p_vocabulary_learned INTEGER DEFAULT 0,
  p_minutes_studied INTEGER DEFAULT 0
)
RETURNS VOID AS $$
DECLARE
  today DATE := CURRENT_DATE;
BEGIN
  INSERT INTO daily_progress (user_id, date, xp_earned, lessons_completed, vocabulary_learned, minutes_studied)
  VALUES (p_user_id, today, p_xp_earned, p_lessons_completed, p_vocabulary_learned, p_minutes_studied)
  ON CONFLICT (user_id, date) DO UPDATE
  SET xp_earned = daily_progress.xp_earned + p_xp_earned,
      lessons_completed = daily_progress.lessons_completed + p_lessons_completed,
      vocabulary_learned = daily_progress.vocabulary_learned + p_vocabulary_learned,
      minutes_studied = daily_progress.minutes_studied + p_minutes_studied;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
