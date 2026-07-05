-- Migration: 20260705180000_create_views.sql
-- Creates reusable database views for reporting and analytics

-- ─── User Dashboard View ────────────────────────────────────────────────────

CREATE OR REPLACE VIEW user_dashboard_view AS
SELECT
  up.id AS user_id,
  up.auth_user_id,
  up.full_name,
  up.avatar_url,
  up.native_language,
  up.target_language,
  up.proficiency_level,
  up.target_exam,
  up.xp AS total_xp,
  up.level,
  ug.daily_goal_minutes,
  ug.weekly_goal_minutes,
  s.current_streak,
  s.longest_streak,
  s.last_active_date,
  up.onboarding_created_at,
  up.onboarding_completed
FROM user_profiles up
LEFT JOIN user_goals ug ON ug.user_id = up.auth_user_id
LEFT JOIN streaks s ON s.user_id = up.auth_user_id;

-- ─── Exam Summary View ──────────────────────────────────────────────────────

CREATE OR REPLACE VIEW exam_summary_view AS
SELECT
  ea.id AS attempt_id,
  ea.user_id,
  e.name AS exam_name,
  e.code AS exam_code,
  ea.exam_type,
  ea.status,
  ea.started_at,
  ea.completed_at,
  es.section,
  es.score,
  es.max_score,
  es.percentage,
  es.time_taken_seconds,
  ef.feedback_type,
  ef.message AS feedback_message,
  ef.suggestion AS feedback_suggestion
FROM exam_attempts ea
JOIN exams e ON e.code = ea.exam_type
LEFT JOIN exam_scores es ON es.attempt_id = ea.id
LEFT JOIN exam_feedback ef ON ef.attempt_id = ea.id;

-- ─── Learning Progress View ─────────────────────────────────────────────────

CREATE OR REPLACE VIEW learning_progress_view AS
SELECT
  up.id AS user_id,
  up.full_name,
  up.xp,
  up.level,
  up.streak,
  ug.daily_goal_minutes,
  upr.grammar_score,
  upr.speaking_score,
  upr.writing_score,
  upr.vocabulary_score,
  upr.reading_score,
  upr.listening_score,
  upr.last_study_date,
  (SELECT COUNT(*) FROM lesson_progress lp WHERE lp.user_id = up.id AND lp.completed_at IS NOT NULL) AS total_lessons_completed,
  (SELECT COUNT(*) FROM vocabulary_history vh WHERE vh.user_id = up.id) AS total_words_learned,
  (SELECT COUNT(*) FROM voice_sessions vs WHERE vs.user_id = up.id) AS total_voice_sessions,
  (SELECT COUNT(*) FROM exam_attempts ea WHERE ea.user_id = up.auth_user_id) AS total_exams_taken
FROM user_profiles up
LEFT JOIN user_goals ug ON ug.user_id = up.auth_user_id
LEFT JOIN user_progress upr ON upr.user_id = up.auth_user_id;

-- ─── Streak View ────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW streak_view AS
SELECT
  s.user_id,
  s.current_streak,
  s.longest_streak,
  s.freeze_count,
  s.last_active_date,
  CASE
    WHEN s.last_active_date = CURRENT_DATE THEN 'active_today'
    WHEN s.last_active_date = CURRENT_DATE - INTERVAL '1 day' THEN 'active_yesterday'
    ELSE 'streak_broken'
  END AS streak_status,
  (SELECT COUNT(*) FROM daily_progress dp WHERE dp.user_id = s.user_id AND dp.streak_maintained = true) AS total_streak_days
FROM streaks s;

-- ─── Subscription View ──────────────────────────────────────────────────────

CREATE OR REPLACE VIEW subscription_view AS
SELECT
  sub.id AS subscription_id,
  sub.user_id,
  sub.provider,
  sub.plan,
  sub.status,
  sub.renewal_date,
  sub.expires_at,
  sub.current_period_start,
  sub.current_period_end,
  CASE
    WHEN sub.expires_at < now() THEN 'expired'
    WHEN sub.expires_at < now() + INTERVAL '7 days' THEN 'expiring_soon'
    ELSE 'active'
  END AS subscription_status,
  (SELECT array_agg(pf.name) FROM premium_features pf WHERE pf.is_active = true) AS available_features
FROM subscriptions sub;

-- ─── Vocabulary Progress View ───────────────────────────────────────────────

CREATE OR REPLACE VIEW vocabulary_progress_view AS
SELECT
  vh.user_id,
  v.word,
  v.meaning,
  v.cefr_level,
  vh.mastery_level,
  vh.review_count,
  vh.next_review,
  CASE
    WHEN vh.mastery_level >= 80 THEN 'mastered'
    WHEN vh.mastery_level >= 50 THEN 'learning'
    WHEN vh.mastery_level >= 20 THEN 'familiar'
    ELSE 'new'
  END AS mastery_status,
  CASE
    WHEN vh.next_review <= now() THEN true
    ELSE false
  END AS is_due_for_review
FROM vocabulary_history vh
JOIN vocabulary v ON v.id = vh.vocabulary_id;

-- ─── Weekly Activity View ───────────────────────────────────────────────────

CREATE OR REPLACE VIEW weekly_activity_view AS
SELECT
  dp.user_id,
  dp.date,
  dp.xp_earned,
  dp.lessons_completed,
  dp.vocabulary_learned,
  dp.minutes_studied,
  dp.streak_maintained,
  EXTRACT(DOW FROM dp.date) AS day_of_week
FROM daily_progress dp
WHERE dp.date >= CURRENT_DATE - INTERVAL '7 days';

-- ─── User Achievements View ─────────────────────────────────────────────────

CREATE OR REPLACE VIEW user_achievements_view AS
SELECT
  ub.user_id,
  b.name AS badge_name,
  b.description AS badge_description,
  b.icon_url,
  b.category,
  b.rarity,
  b.xp_reward,
  ub.earned_at
FROM user_badges ub
JOIN badges b ON b.id = ub.badge_id
ORDER BY ub.earned_at DESC;
