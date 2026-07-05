-- Migration: 20260705010000_add_api_tables.sql
-- Adds tables needed by API endpoints: reading_passages, listening_exercises, assessments

-- ─── Reading Passages Table ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS reading_passages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  passage TEXT NOT NULL,
  difficulty VARCHAR(10),
  language TEXT DEFAULT 'English',
  category TEXT,
  questions JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE reading_passages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reading passages"
  ON reading_passages FOR SELECT
  USING (true);

CREATE INDEX idx_reading_passages_difficulty ON reading_passages(difficulty);
CREATE INDEX idx_reading_passages_language ON reading_passages(language);

-- ─── Listening Exercises Table ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS listening_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  transcript TEXT NOT NULL,
  audio_url TEXT,
  difficulty VARCHAR(10),
  language TEXT DEFAULT 'English',
  category TEXT,
  questions JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE listening_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view listening exercises"
  ON listening_exercises FOR SELECT
  USING (true);

CREATE INDEX idx_listening_exercises_difficulty ON listening_exercises(difficulty);
CREATE INDEX idx_listening_exercises_language ON listening_exercises(language);

-- ─── Assessments Table ──────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS assessments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL DEFAULT 'placement',
  status VARCHAR(20) DEFAULT 'in_progress',
  score INTEGER,
  proficiency_level VARCHAR(5),
  skill_scores JSONB DEFAULT '{}'::jsonb,
  feedback JSONB DEFAULT '{}'::jsonb,
  started_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own assessments"
  ON assessments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own assessments"
  ON assessments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own assessments"
  ON assessments FOR UPDATE
  USING (auth.uid() = user_id);

CREATE INDEX idx_assessments_user_id ON assessments(user_id);
CREATE INDEX idx_assessments_type ON assessments(type);

-- ─── Subscriptions Table Enhancement ────────────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'subscriptions' AND column_name = 'plan_id') THEN
    ALTER TABLE subscriptions ADD COLUMN plan_id VARCHAR(50);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'subscriptions' AND column_name = 'current_period_start') THEN
    ALTER TABLE subscriptions ADD COLUMN current_period_start TIMESTAMPTZ;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'subscriptions' AND column_name = 'current_period_end') THEN
    ALTER TABLE subscriptions ADD COLUMN current_period_end TIMESTAMPTZ;
  END IF;
END $$;

-- ─── Updated_at Triggers ────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_reading_passages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reading_passages_updated_at
  BEFORE UPDATE ON reading_passages
  FOR EACH ROW
  EXECUTE FUNCTION update_reading_passages_updated_at();

CREATE OR REPLACE FUNCTION update_listening_exercises_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER listening_exercises_updated_at
  BEFORE UPDATE ON listening_exercises
  FOR EACH ROW
  EXECUTE FUNCTION update_listening_exercises_updated_at();

-- ─── Storage Buckets ────────────────────────────────────────────────────────

-- Note: Storage buckets are created via Supabase dashboard or API
-- Buckets needed: 'avatars', 'files'

-- Insert sample reading passage
INSERT INTO reading_passages (title, passage, difficulty, language, questions)
VALUES
(
  'The Benefits of Learning Languages',
  'Learning a new language has many benefits. It helps improve memory, enhances problem-solving skills, and increases cultural awareness. Studies show that bilingual people tend to have better cognitive abilities and can even delay the onset of dementia. Furthermore, speaking multiple languages opens up career opportunities and allows you to connect with people from different backgrounds.',
  'A1',
  'English',
  '[
    {"question": "What is one benefit of learning a new language mentioned in the passage?", "options": ["Better memory", "More money", "Faster running", "Better cooking"], "correct_answer": "Better memory", "explanation": "The passage states that learning a new language helps improve memory."},
    {"question": "According to the passage, bilingual people have better:", "options": ["Physical strength", "Cognitive abilities", "Cooking skills", "Driving skills"], "correct_answer": "Cognitive abilities", "explanation": "The passage mentions that bilingual people tend to have better cognitive abilities."}
  ]'::jsonb
);

-- Insert sample listening exercise
INSERT INTO listening_exercises (title, transcript, difficulty, language, questions)
VALUES
(
  'Daily Routine Conversation',
  'A: What time do you usually wake up? B: I wake up at 6:30 AM every day. A: What do you do first in the morning? B: I usually brush my teeth and then have breakfast. A: What do you eat for breakfast? B: I typically have toast with eggs and a cup of tea.',
  'A1',
  'English',
  '[
    {"question": "What time does person B wake up?", "options": ["6:00 AM", "6:30 AM", "7:00 AM", "7:30 AM"], "correct_answer": "6:30 AM", "explanation": "Person B says they wake up at 6:30 AM."},
    {"question": "What does person B eat for breakfast?", "options": ["Cereal", "Pancakes", "Toast with eggs", "Nothing"], "correct_answer": "Toast with eggs", "explanation": "Person B says they typically have toast with eggs."}
  ]'::jsonb
);
