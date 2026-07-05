-- Migration: 20260705170000_add_exams_definitions_and_badges.sql
-- Adds exams (definitions) table and badges table per strategy document

-- ─── Exams (Definitions) ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS exams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20) UNIQUE NOT NULL,
  description TEXT,
  exam_type VARCHAR(50) NOT NULL,
  duration_minutes INTEGER,
  max_score INTEGER,
  passing_score INTEGER,
  sections JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE exams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active exams"
  ON exams FOR SELECT
  USING (is_active = true);

CREATE INDEX idx_exams_type ON exams(exam_type);
CREATE INDEX idx_exams_code ON exams(code);

-- ─── Badges ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon_url TEXT,
  category VARCHAR(50),
  rarity VARCHAR(20) DEFAULT 'common',
  xp_reward INTEGER DEFAULT 0,
  criteria JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active badges"
  ON badges FOR SELECT
  USING (is_active = true);

CREATE INDEX idx_badges_category ON badges(category);
CREATE INDEX idx_badges_rarity ON badges(rarity);

-- ─── User Badges (junction table) ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
  earned_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, badge_id)
);

ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own badges"
  ON user_badges FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can earn badges"
  ON user_badges FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_user_badges_user_id ON user_badges(user_id);
CREATE INDEX idx_user_badges_badge_id ON user_badges(badge_id);

-- ─── Insert Default Exams ───────────────────────────────────────────────────

INSERT INTO exams (name, code, description, exam_type, duration_minutes, max_score, passing_score, sections) VALUES
('IELTS Academic', 'IELTS_A', 'International English Language Testing System - Academic', 'IELTS', 165, 9, 6, '[
  {"name": "Listening", "duration_minutes": 30, "max_score": 9, "questions": 40},
  {"name": "Reading", "duration_minutes": 60, "max_score": 9, "questions": 40},
  {"name": "Writing", "duration_minutes": 60, "max_score": 9, "tasks": 2},
  {"name": "Speaking", "duration_minutes": 15, "max_score": 9, "parts": 3}
]'::jsonb),
('IELTS General Training', 'IELTS_GT', 'International English Language Testing System - General Training', 'IELTS', 165, 9, 6, '[
  {"name": "Listening", "duration_minutes": 30, "max_score": 9, "questions": 40},
  {"name": "Reading", "duration_minutes": 60, "max_score": 9, "questions": 40},
  {"name": "Writing", "duration_minutes": 60, "max_score": 9, "tasks": 2},
  {"name": "Speaking", "duration_minutes": 15, "max_score": 9, "parts": 3}
]'::jsonb),
('TOEFL iBT', 'TOEFL', 'Test of English as a Foreign Language - Internet Based Test', 'TOEFL', 180, 120, 80, '[
  {"name": "Reading", "duration_minutes": 54, "max_score": 30, "questions": 30},
  {"name": "Listening", "duration_minutes": 41, "max_score": 30, "questions": 28},
  {"name": "Speaking", "duration_minutes": 17, "max_score": 30, "tasks": 4},
  {"name": "Writing", "duration_minutes": 50, "max_score": 30, "tasks": 2}
]'::jsonb),
('PTE Academic', 'PTE', 'Pearson Test of English Academic', 'PTE', 120, 90, 50, '[
  {"name": "Speaking & Writing", "duration_minutes": 54, "max_score": 90},
  {"name": "Reading", "duration_minutes": 30, "max_score": 90},
  {"name": "Listening", "duration_minutes": 30, "max_score": 90}
]'::jsonb),
('Cambridge B2 First', 'FCE', 'First Certificate in English', 'Cambridge', 190, 230, 160, '[
  {"name": "Reading & Use of English", "duration_minutes": 75, "max_score": 42},
  {"name": "Writing", "duration_minutes": 80, "max_score": 42},
  {"name": "Listening", "duration_minutes": 40, "max_score": 30},
  {"name": "Speaking", "duration_minutes": 14, "max_score": 42}
]'::jsonb),
('Cambridge C1 Advanced', 'CAE', 'Certificate in Advanced English', 'Cambridge', 230, 230, 180, '[
  {"name": "Reading & Use of English", "duration_minutes": 90, "max_score": 50},
  {"name": "Writing", "duration_minutes": 90, "max_score": 50},
  {"name": "Listening", "duration_minutes": 40, "max_score": 30},
  {"name": "Speaking", "duration_minutes": 15, "max_score": 50}
]'::jsonb)
ON CONFLICT (code) DO NOTHING;

-- ─── Insert Default Badges ──────────────────────────────────────────────────

INSERT INTO badges (name, description, category, rarity, xp_reward, criteria) VALUES
('First Steps', 'Complete your first lesson', 'learning', 'common', 50, '{"lessons_completed": 1}'::jsonb),
('Quick Learner', 'Complete 5 lessons in one day', 'learning', 'uncommon', 100, '{"lessons_in_day": 5}'::jsonb),
('Study Streak', 'Maintain a 7-day streak', 'streak', 'common', 150, '{"streak_days": 7}'::jsonb),
('Month Master', 'Maintain a 30-day streak', 'streak', 'rare', 500, '{"streak_days": 30}'::jsonb),
('Vocabulary Builder', 'Learn 100 vocabulary words', 'vocabulary', 'common', 100, '{"words_learned": 100}'::jsonb),
('Word Wizard', 'Learn 500 vocabulary words', 'vocabulary', 'rare', 300, '{"words_learned": 500}'::jsonb),
('Perfect Score', 'Score 100% on any exam', 'exam', 'epic', 1000, '{"perfect_score": true}'::jsonb),
('Exam Ready', 'Complete 3 practice exams', 'exam', 'uncommon', 200, '{"exams_completed": 3}'::jsonb),
('Voice Master', 'Complete 10 voice sessions', 'speaking', 'uncommon', 200, '{"voice_sessions": 10}'::jsonb),
('Grammar Guru', 'Complete all grammar topics', 'grammar', 'rare', 400, '{"all_grammar": true}'::jsonb),
('Bookworm', 'Complete 20 reading lessons', 'reading', 'uncommon', 150, '{"reading_lessons": 20}'::jsonb),
('Active Listener', 'Complete 20 listening exercises', 'listening', 'uncommon', 150, '{"listening_exercises": 20}'::jsonb),
('Writing Whiz', 'Submit 10 writing evaluations', 'writing', 'uncommon', 200, '{"writing_submissions": 10}'::jsonb),
('Social Butterfly', 'Invite 3 friends', 'social', 'uncommon', 100, '{"friends_invited": 3}'::jsonb),
('Premium Member', 'Subscribe to premium plan', 'subscription', 'common', 0, '{"premium_subscriber": true}'::jsonb),
('Night Owl', 'Study after 10 PM', 'engagement', 'common', 25, '{"study_time": "night"}'::jsonb),
('Early Bird', 'Study before 7 AM', 'engagement', 'common', 25, '{"study_time": "morning"}'::jsonb),
('XP Hunter', 'Earn 1000 XP total', 'xp', 'uncommon', 0, '{"total_xp": 1000}'::jsonb),
('XP Legend', 'Earn 10000 XP total', 'xp', 'epic', 0, '{"total_xp": 10000}'::jsonb)
ON CONFLICT (name) DO NOTHING;
