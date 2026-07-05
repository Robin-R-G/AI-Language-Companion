-- Migration: 20260705000000_add_missing_tables_and_fix_schema
-- Adds missing tables: streaks, user_progress, writing_evaluations
-- Fixes ai_memory column alignment with code

-- ─── Streaks Table ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS streaks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE UNIQUE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  freeze_count INTEGER DEFAULT 0,
  last_active_date DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own streaks"
  ON streaks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own streaks"
  ON streaks FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own streaks"
  ON streaks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_streaks_user_id ON streaks(user_id);

-- ─── User Progress Table ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE UNIQUE,
  xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  grammar_score INTEGER DEFAULT 0,
  speaking_score INTEGER DEFAULT 0,
  writing_score INTEGER DEFAULT 0,
  vocabulary_score INTEGER DEFAULT 0,
  reading_score INTEGER DEFAULT 0,
  listening_score INTEGER DEFAULT 0,
  last_study_date DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own progress"
  ON user_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
  ON user_progress FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress"
  ON user_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);

-- ─── Writing Evaluations Table ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS writing_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  essay_text TEXT NOT NULL,
  estimated_band VARCHAR(20),
  grammar_score INTEGER,
  vocabulary_score INTEGER,
  organization_score INTEGER,
  clarity_score INTEGER,
  strengths TEXT[],
  mistakes TEXT[],
  improved_version TEXT,
  recommendations TEXT[],
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE writing_evaluations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own writing evaluations"
  ON writing_evaluations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own writing evaluations"
  ON writing_evaluations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_writing_evaluations_user_id ON writing_evaluations(user_id);

-- ─── Fix ai_memory table ────────────────────────────────────────────────────
-- The migration uses key/value but code expects memory_type/content/importance.
-- Add columns if they don't exist.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ai_memory' AND column_name = 'memory_type') THEN
    ALTER TABLE ai_memory ADD COLUMN memory_type VARCHAR(50) NOT NULL DEFAULT 'general';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ai_memory' AND column_name = 'content') THEN
    ALTER TABLE ai_memory ADD COLUMN content TEXT NOT NULL DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ai_memory' AND column_name = 'importance') THEN
    ALTER TABLE ai_memory ADD COLUMN importance INTEGER DEFAULT 1;
  END IF;
END $$;

-- ─── Updated_at Triggers ────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_streaks_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER streaks_updated_at
  BEFORE UPDATE ON streaks
  FOR EACH ROW
  EXECUTE FUNCTION update_streaks_updated_at();

CREATE OR REPLACE FUNCTION update_user_progress_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_progress_updated_at
  BEFORE UPDATE ON user_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_user_progress_updated_at();

-- ─── User Goals Updated At Trigger ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_user_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'updated_at') THEN
    ALTER TABLE user_goals ADD COLUMN updated_at TIMESTAMPTZ DEFAULT now();
  END IF;
END $$;

-- ─── Notifications RLS ──────────────────────────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Users can view own notifications') THEN
    CREATE POLICY "Users can view own notifications"
      ON notifications FOR SELECT
      USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Users can insert own notifications') THEN
    CREATE POLICY "Users can insert own notifications"
      ON notifications FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Users can delete own notifications') THEN
    CREATE POLICY "Users can delete own notifications"
      ON notifications FOR DELETE
      USING (auth.uid() = user_id);
  END IF;
END $$;

-- ─── Analytics Events RLS ───────────────────────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'analytics_events' AND policyname = 'Users can view own analytics events') THEN
    CREATE POLICY "Users can view own analytics events"
      ON analytics_events FOR SELECT
      USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'analytics_events' AND policyname = 'Users can insert own analytics events') THEN
    CREATE POLICY "Users can insert own analytics events"
      ON analytics_events FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;
