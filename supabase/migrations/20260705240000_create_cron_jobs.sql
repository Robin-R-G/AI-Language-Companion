-- Migration: 20260705240000_create_cron_jobs.sql
-- Creates scheduled jobs for background tasks

-- ─── Enable pg_cron Extension ───────────────────────────────────────────────
-- Note: pg_cron must be enabled in Supabase Dashboard > Extensions

-- ─── Daily Review Scheduling ────────────────────────────────────────────────
-- Runs daily at 6 AM UTC to schedule vocabulary reviews

CREATE OR REPLACE FUNCTION schedule_daily_reviews()
RETURNS void AS $$
BEGIN
  -- Update vocabulary items due for review
  UPDATE vocabulary_history
  SET next_review = now()
  WHERE next_review <= now()
  AND mastery_level < 80;

  -- Create notifications for users with due reviews
  INSERT INTO notifications (user_id, title, body, type)
  SELECT DISTINCT
    vh.user_id,
    'Vocabulary Review Due',
    'You have vocabulary words due for review. Practice now to strengthen your memory!',
    'reminder'
  FROM vocabulary_history vh
  WHERE vh.next_review <= now()
  AND vh.mastery_level < 80
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = vh.user_id
    AND n.type = 'reminder'
    AND n.created_at > now() - INTERVAL '24 hours'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Streak Maintenance ─────────────────────────────────────────────────────
-- Runs daily at midnight UTC to check and update streaks

CREATE OR REPLACE FUNCTION maintain_streaks()
RETURNS void AS $$
BEGIN
  -- Reset streaks for users who didn't study yesterday
  UPDATE streaks
  SET current_streak = 0,
      updated_at = now()
  WHERE last_active_date < CURRENT_DATE - INTERVAL '1 day'
  AND current_streak > 0;

  -- Create notifications for users about to lose streaks
  INSERT INTO notifications (user_id, title, body, type)
  SELECT
    s.user_id,
    'Streak at Risk!',
    'You haven''t studied today. Complete a lesson to maintain your ' || s.current_streak || '-day streak!',
    'streak'
  FROM streaks s
  WHERE s.last_active_date = CURRENT_DATE - INTERVAL '1 day'
  AND s.current_streak >= 3
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = s.user_id
    AND n.type = 'streak'
    AND n.created_at > now() - INTERVAL '24 hours'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Subscription Validation ────────────────────────────────────────────────
-- Runs daily to validate and expire subscriptions

CREATE OR REPLACE FUNCTION validate_subscriptions()
RETURNS void AS $$
BEGIN
  -- Expire subscriptions past their expiration date
  UPDATE subscriptions
  SET status = 'expired',
      updated_at = now()
  WHERE status = 'active'
  AND expires_at < now();

  -- Notify users with expiring subscriptions (3 days warning)
  INSERT INTO notifications (user_id, title, body, type)
  SELECT
    s.user_id,
    'Subscription Expiring Soon',
    'Your ' || s.plan || ' subscription expires in ' ||
    EXTRACT(DAY FROM s.expires_at - now()) || ' days. Renew to keep premium features.',
    'warning'
  FROM subscriptions s
  WHERE s.status = 'active'
  AND s.expires_at > now()
  AND s.expires_at < now() + INTERVAL '3 days'
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = s.user_id
    AND n.type = 'warning'
    AND n.created_at > now() - INTERVAL '7 days'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Analytics Aggregation ──────────────────────────────────────────────────
-- Runs weekly to aggregate learning statistics

CREATE OR REPLACE FUNCTION aggregate_weekly_analytics()
RETURNS void AS $$
DECLARE
  week_start DATE := CURRENT_DATE - INTERVAL '7 days';
  week_end DATE := CURRENT_DATE;
BEGIN
  -- Aggregate daily progress into learning statistics
  INSERT INTO learning_statistics (
    user_id, period_type, period_start, period_end,
    total_xp, total_minutes, lessons_completed,
    vocabulary_learned, streak_days
  )
  SELECT
    dp.user_id,
    'weekly',
    week_start,
    week_end,
    SUM(dp.xp_earned),
    SUM(dp.minutes_studied),
    SUM(dp.lessons_completed),
    SUM(dp.vocabulary_learned),
    COUNT(CASE WHEN dp.streak_maintained THEN 1 END)
  FROM daily_progress dp
  WHERE dp.date >= week_start
  AND dp.date < week_end
  GROUP BY dp.user_id
  ON CONFLICT (user_id, period_type, period_start) DO UPDATE
  SET
    total_xp = EXCLUDED.total_xp,
    total_minutes = EXCLUDED.total_minutes,
    lessons_completed = EXCLUDED.lessons_completed,
    vocabulary_learned = EXCLUDED.vocabulary_learned,
    streak_days = EXCLUDED.streak_days;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Session Cleanup ────────────────────────────────────────────────────────
-- Runs hourly to clean up expired sessions

CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS void AS $$
BEGIN
  -- Delete old analytics events (keep 90 days)
  DELETE FROM analytics_events
  WHERE created_at < now() - INTERVAL '90 days';

  -- Delete old temporary storage files
  PERFORM cleanup_temporary_storage();

  -- Archive old exam attempts (move to archive table if needed)
  -- This is a placeholder for actual archival logic
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Reminder Notifications ─────────────────────────────────────────────────
-- Runs daily to send reminder notifications

CREATE OR REPLACE FUNCTION send_reminder_notifications()
RETURNS void AS $$
BEGIN
  -- Daily study reminders
  INSERT INTO notifications (user_id, title, body, type)
  SELECT
    up.auth_user_id,
    'Time to Study!',
    'Complete your daily learning goal. You''ve studied ' ||
    COALESCE(dp.minutes_studied, 0) || ' minutes today.',
    'reminder'
  FROM user_profiles up
  LEFT JOIN daily_progress dp ON dp.user_id = up.auth_user_id AND dp.date = CURRENT_DATE
  WHERE up.onboarding_completed = true
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = up.auth_user_id
    AND n.type = 'reminder'
    AND n.created_at > now() - INTERVAL '20 hours'
  )
  AND EXISTS (
    SELECT 1 FROM user_preferences upref
    WHERE upref.user_id = up.auth_user_id
    AND upref.lesson_reminders = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Badge Award Check ──────────────────────────────────────────────────────
-- Runs daily to check and award badges

CREATE OR REPLACE FUNCTION check_and_award_badges()
RETURNS void AS $$
DECLARE
  user_record RECORD;
BEGIN
  FOR user_record IN
    SELECT DISTINCT user_id FROM lesson_progress
    UNION
    SELECT DISTINCT user_id FROM vocabulary_history
    UNION
    SELECT DISTINCT user_id FROM voice_sessions
  LOOP
    -- Check for First Steps badge (first lesson completed)
    IF EXISTS (
      SELECT 1 FROM lesson_progress
      WHERE user_id = user_record.user_id
      AND completed_at IS NOT NULL
      LIMIT 1
    ) THEN
      PERFORM award_badge(user_record.user_id, 'First Steps');
    END IF;

    -- Check for Study Streak badge (7-day streak)
    IF EXISTS (
      SELECT 1 FROM streaks
      WHERE user_id = user_record.user_id
      AND current_streak >= 7
    ) THEN
      PERFORM award_badge(user_record.user_id, 'Study Streak');
    END IF;

    -- Check for Vocabulary Builder badge (100 words)
    IF EXISTS (
      SELECT 1 FROM vocabulary_history
      WHERE user_id = user_record.user_id
      GROUP BY user_id
      HAVING COUNT(*) >= 100
    ) THEN
      PERFORM award_badge(user_record.user_id, 'Vocabulary Builder');
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Schedule Configuration ─────────────────────────────────────────────────
-- These would be configured via Supabase Dashboard > SQL > Cron
-- or via the pg_cron extension

-- Example cron job configurations (to be run via Supabase Dashboard):
--
-- SELECT cron.schedule(
--   'daily-reviews',
--   '0 6 * * *',  -- 6 AM UTC daily
--   'SELECT schedule_daily_reviews()'
-- );
--
-- SELECT cron.schedule(
--   'maintain-streaks',
--   '0 0 * * *',  -- Midnight UTC daily
--   'SELECT maintain_streaks()'
-- );
--
-- SELECT cron.schedule(
--   'validate-subscriptions',
--   '0 1 * * *',  -- 1 AM UTC daily
--   'SELECT validate_subscriptions()'
-- );
--
-- SELECT cron.schedule(
--   'aggregate-analytics',
--   '0 2 * * 0',  -- 2 AM UTC every Sunday
--   'SELECT aggregate_weekly_analytics()'
-- );
--
-- SELECT cron.schedule(
--   'cleanup-sessions',
--   '0 * * * *',  -- Every hour
--   'SELECT cleanup_expired_sessions()'
-- );
--
-- SELECT cron.schedule(
--   'send-reminders',
--   '0 8 * * *',  -- 8 AM UTC daily
--   'SELECT send_reminder_notifications()'
-- );
--
-- SELECT cron.schedule(
--   'check-badges',
--   '0 3 * * *',  -- 3 AM UTC daily
--   'SELECT check_and_award_badges()'
-- );
