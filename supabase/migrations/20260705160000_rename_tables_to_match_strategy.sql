-- Migration: 20260705160000_rename_tables_to_match_strategy.sql
-- Renames tables to align with strategy document:
--   reading_passages → reading_lessons
--   listening_exercises → listening_lessons
--   writing_evaluations → writing_tasks
--   mock_exams → exam_attempts (with schema migration)

-- ─── Rename reading_passages → reading_lessons ──────────────────────────────

ALTER TABLE IF EXISTS reading_passages RENAME TO reading_lessons;

-- Rename indexes
ALTER INDEX IF EXISTS idx_reading_passages_difficulty RENAME TO idx_reading_lessons_difficulty;
ALTER INDEX IF EXISTS idx_reading_passages_language RENAME TO idx_reading_lessons_language;

-- Rename trigger
DROP TRIGGER IF EXISTS reading_passages_updated_at ON reading_lessons;
DROP FUNCTION IF EXISTS update_reading_passages_updated_at();

CREATE OR REPLACE FUNCTION update_reading_lessons_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reading_lessons_updated_at
  BEFORE UPDATE ON reading_lessons
  FOR EACH ROW
  EXECUTE FUNCTION update_reading_lessons_updated_at();

-- Update RLS policy
DROP POLICY IF EXISTS "Anyone can view reading passages" ON reading_lessons;
CREATE POLICY "Anyone can view reading lessons"
  ON reading_lessons FOR SELECT
  USING (true);

-- ─── Rename listening_exercises → listening_lessons ─────────────────────────

ALTER TABLE IF EXISTS listening_exercises RENAME TO listening_lessons;

-- Rename indexes
ALTER INDEX IF EXISTS idx_listening_exercises_difficulty RENAME TO idx_listening_lessons_difficulty;
ALTER INDEX IF EXISTS idx_listening_exercises_language RENAME TO idx_listening_lessons_language;

-- Rename trigger
DROP TRIGGER IF EXISTS listening_exercises_updated_at ON listening_lessons;
DROP FUNCTION IF EXISTS update_listening_exercises_updated_at();

CREATE OR REPLACE FUNCTION update_listening_lessons_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER listening_lessons_updated_at
  BEFORE UPDATE ON listening_lessons
  FOR EACH ROW
  EXECUTE FUNCTION update_listening_lessons_updated_at();

-- Update RLS policy
DROP POLICY IF EXISTS "Anyone can view listening exercises" ON listening_lessons;
CREATE POLICY "Anyone can view listening lessons"
  ON listening_lessons FOR SELECT
  USING (true);

-- ─── Rename writing_evaluations → writing_tasks ─────────────────────────────

ALTER TABLE IF EXISTS writing_evaluations RENAME TO writing_tasks;

-- Rename index
ALTER INDEX IF EXISTS idx_writing_evaluations_user_id RENAME TO idx_writing_tasks_user_id;

-- Update RLS policies
DROP POLICY IF EXISTS "Users can view own writing evaluations" ON writing_tasks;
DROP POLICY IF EXISTS "Users can insert own writing evaluations" ON writing_tasks;

CREATE POLICY "Users can view own writing tasks"
  ON writing_tasks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own writing tasks"
  ON writing_tasks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ─── Migrate mock_exams → exam_attempts ─────────────────────────────────────
-- Step 1: Drop the new exam_attempts/exam_scores/exam_feedback tables
--         we created in the previous migration (they don't have data yet)

DROP TABLE IF EXISTS exam_feedback;
DROP TABLE IF EXISTS exam_scores;
DROP TABLE IF EXISTS exam_attempts;

-- Step 2: Rename mock_exams to exam_attempts
ALTER TABLE mock_exams RENAME TO exam_attempts;

-- Rename index
ALTER INDEX IF EXISTS idx_mock_exams_user_created RENAME TO idx_exam_attempts_user_created;

-- Rename constraint
ALTER TABLE exam_attempts
  DROP CONSTRAINT IF EXISTS mock_exams_user_id_fkey,
  ADD CONSTRAINT exam_attempts_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE CASCADE;

-- Update RLS policies
DROP POLICY IF EXISTS "Users manage own mock exams" ON exam_attempts;

CREATE POLICY "Users can view own exam attempts"
  ON exam_attempts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own exam attempts"
  ON exam_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own exam attempts"
  ON exam_attempts FOR UPDATE
  USING (auth.uid() = user_id);

-- Step 3: Add missing columns to align with strategy
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'exam_attempts' AND column_name = 'status') THEN
    ALTER TABLE exam_attempts ADD COLUMN status VARCHAR(20) DEFAULT 'completed';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'exam_attempts' AND column_name = 'started_at') THEN
    ALTER TABLE exam_attempts ADD COLUMN started_at TIMESTAMPTZ DEFAULT now();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'exam_attempts' AND column_name = 'completed_at') THEN
    ALTER TABLE exam_attempts ADD COLUMN completed_at TIMESTAMPTZ;
  END IF;
END $$;

-- Set completed_at = created_at for existing records
UPDATE exam_attempts SET completed_at = created_at WHERE completed_at IS NULL;

-- ─── Create exam_scores table ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS exam_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID REFERENCES exam_attempts(id) ON DELETE CASCADE,
  section VARCHAR(50) NOT NULL,
  score INTEGER,
  max_score INTEGER,
  percentage NUMERIC(5,2),
  time_taken_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE exam_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own exam scores"
  ON exam_scores FOR SELECT
  USING (
    attempt_id IN (
      SELECT id FROM exam_attempts WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own exam scores"
  ON exam_scores FOR INSERT
  WITH CHECK (
    attempt_id IN (
      SELECT id FROM exam_attempts WHERE user_id = auth.uid()
    )
  );

CREATE INDEX idx_exam_scores_attempt_id ON exam_scores(attempt_id);

-- ─── Create exam_feedback table ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS exam_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID REFERENCES exam_attempts(id) ON DELETE CASCADE,
  section VARCHAR(50),
  feedback_type VARCHAR(50),
  message TEXT,
  suggestion TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE exam_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own exam feedback"
  ON exam_feedback FOR SELECT
  USING (
    attempt_id IN (
      SELECT id FROM exam_attempts WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own exam feedback"
  ON exam_feedback FOR INSERT
  WITH CHECK (
    attempt_id IN (
      SELECT id FROM exam_attempts WHERE user_id = auth.uid()
    )
  );

CREATE INDEX idx_exam_feedback_attempt_id ON exam_feedback(attempt_id);

-- ─── Migrate existing feedback data from exam_attempts to exam_feedback ─────

INSERT INTO exam_feedback (attempt_id, section, feedback_type, message)
SELECT
  id,
  COALESCE(section, 'general'),
  'overall',
  (feedback->>'comment')::TEXT
FROM exam_attempts
WHERE feedback IS NOT NULL AND feedback != '{}'::jsonb;
