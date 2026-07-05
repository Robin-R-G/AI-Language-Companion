-- Migration: 20260705150000_add_missing_tables.sql
-- Adds missing tables from strategy document: user_settings, user_preferences,
-- grammar_topics, exam_attempts, exam_scores, exam_feedback, ai_context,
-- ai_feedback, pronunciation_scores, transcripts, daily_progress,
-- learning_statistics, xp_history, notification_preferences, invoices, premium_features

-- ─── User Settings ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE UNIQUE,
  theme VARCHAR(20) DEFAULT 'light',
  language VARCHAR(10) DEFAULT 'en',
  sound_enabled BOOLEAN DEFAULT true,
  notifications_enabled BOOLEAN DEFAULT true,
  auto_play_audio BOOLEAN DEFAULT true,
  show_translations BOOLEAN DEFAULT true,
  difficulty_preference VARCHAR(20) DEFAULT 'auto',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own settings"
  ON user_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own settings"
  ON user_settings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings"
  ON user_settings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

-- ─── User Preferences ───────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE UNIQUE,
  learning_style VARCHAR(50) DEFAULT 'visual',
  preferred_study_time VARCHAR(20) DEFAULT 'morning',
  daily_reminder BOOLEAN DEFAULT true,
  weekly_report BOOLEAN DEFAULT true,
  achievement_notifications BOOLEAN DEFAULT true,
  lesson_reminders BOOLEAN DEFAULT true,
  vocabulary_reminders BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own preferences"
  ON user_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
  ON user_preferences FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
  ON user_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- ─── Grammar Topics ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS grammar_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category VARCHAR(50),
  difficulty VARCHAR(10),
  cefr_level VARCHAR(5),
  language TEXT DEFAULT 'English',
  examples JSONB DEFAULT '[]'::jsonb,
  rules JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE grammar_topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view grammar topics"
  ON grammar_topics FOR SELECT
  USING (true);

CREATE INDEX idx_grammar_topics_category ON grammar_topics(category);
CREATE INDEX idx_grammar_topics_difficulty ON grammar_topics(difficulty);
CREATE INDEX idx_grammar_topics_cefr_level ON grammar_topics(cefr_level);

-- ─── Exam Attempts ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS exam_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  exam_type VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'in_progress',
  started_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE exam_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own exam attempts"
  ON exam_attempts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own exam attempts"
  ON exam_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own exam attempts"
  ON exam_attempts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE INDEX idx_exam_attempts_user_id ON exam_attempts(user_id);
CREATE INDEX idx_exam_attempts_type ON exam_attempts(exam_type);

-- ─── Exam Scores ────────────────────────────────────────────────────────────

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

-- ─── Exam Feedback ──────────────────────────────────────────────────────────

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

-- ─── AI Context ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS ai_context (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES ai_conversations(id) ON DELETE CASCADE,
  context_type VARCHAR(50),
  context_data JSONB DEFAULT '{}'::jsonb,
  relevance_score NUMERIC(3,2) DEFAULT 0.5,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE ai_context ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own ai context"
  ON ai_context FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own ai context"
  ON ai_context FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own ai context"
  ON ai_context FOR DELETE
  USING (auth.uid() = user_id);

CREATE INDEX idx_ai_context_user_id ON ai_context(user_id);
CREATE INDEX idx_ai_context_conversation_id ON ai_context(conversation_id);

-- ─── AI Feedback ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS ai_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES ai_conversations(id) ON DELETE CASCADE,
  feedback_type VARCHAR(50),
  original_text TEXT,
  corrected_text TEXT,
  explanation TEXT,
  severity VARCHAR(20) DEFAULT 'info',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE ai_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own ai feedback"
  ON ai_feedback FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own ai feedback"
  ON ai_feedback FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_ai_feedback_user_id ON ai_feedback(user_id);
CREATE INDEX idx_ai_feedback_conversation_id ON ai_feedback(conversation_id);

-- ─── Pronunciation Scores ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS pronunciation_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES voice_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  word TEXT NOT NULL,
  accuracy_score NUMERIC(5,2),
  phoneme_scores JSONB DEFAULT '{}'::jsonb,
  feedback TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE pronunciation_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own pronunciation scores"
  ON pronunciation_scores FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own pronunciation scores"
  ON pronunciation_scores FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_pronunciation_scores_session_id ON pronunciation_scores(session_id);
CREATE INDEX idx_pronunciation_scores_user_id ON pronunciation_scores(user_id);

-- ─── Transcripts ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS transcripts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES voice_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  speaker VARCHAR(20) DEFAULT 'user',
  text TEXT NOT NULL,
  start_time NUMERIC(10,3),
  end_time NUMERIC(10,3),
  confidence NUMERIC(3,2),
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE transcripts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transcripts"
  ON transcripts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transcripts"
  ON transcripts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_transcripts_session_id ON transcripts(session_id);
CREATE INDEX idx_transcripts_user_id ON transcripts(user_id);

-- ─── Daily Progress ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS daily_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  date DATE NOT NULL,
  xp_earned INTEGER DEFAULT 0,
  lessons_completed INTEGER DEFAULT 0,
  vocabulary_learned INTEGER DEFAULT 0,
  minutes_studied INTEGER DEFAULT 0,
  streak_maintained BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, date)
);

ALTER TABLE daily_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own daily progress"
  ON daily_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily progress"
  ON daily_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily progress"
  ON daily_progress FOR UPDATE
  USING (auth.uid() = user_id);

CREATE INDEX idx_daily_progress_user_id ON daily_progress(user_id);
CREATE INDEX idx_daily_progress_date ON daily_progress(date);

-- ─── Learning Statistics ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS learning_statistics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  period_type VARCHAR(20) NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  total_xp INTEGER DEFAULT 0,
  total_minutes INTEGER DEFAULT 0,
  lessons_completed INTEGER DEFAULT 0,
  vocabulary_learned INTEGER DEFAULT 0,
  accuracy_rate NUMERIC(5,2),
  streak_days INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE learning_statistics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own learning statistics"
  ON learning_statistics FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own learning statistics"
  ON learning_statistics FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_learning_statistics_user_id ON learning_statistics(user_id);
CREATE INDEX idx_learning_statistics_period ON learning_statistics(period_type, period_start);

-- ─── XP History ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS xp_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  amount INTEGER NOT NULL,
  source VARCHAR(50) NOT NULL,
  source_id UUID,
  description TEXT,
  balance_after INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE xp_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own xp history"
  ON xp_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own xp history"
  ON xp_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_xp_history_user_id ON xp_history(user_id);
CREATE INDEX idx_xp_history_created_at ON xp_history(created_at);

-- ─── Notification Preferences ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE UNIQUE,
  email_notifications BOOLEAN DEFAULT true,
  push_notifications BOOLEAN DEFAULT true,
  lesson_reminders BOOLEAN DEFAULT true,
  streak_reminders BOOLEAN DEFAULT true,
  achievement_alerts BOOLEAN DEFAULT true,
  weekly_report BOOLEAN DEFAULT true,
  marketing_emails BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notification preferences"
  ON notification_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notification preferences"
  ON notification_preferences FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification preferences"
  ON notification_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);

-- ─── Invoices ───────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE CASCADE,
  payment_id UUID REFERENCES payments(id) ON DELETE SET NULL,
  invoice_number VARCHAR(50) UNIQUE NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  status VARCHAR(20) DEFAULT 'pending',
  due_date DATE,
  paid_at TIMESTAMPTZ,
  billing_address JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own invoices"
  ON invoices FOR SELECT
  USING (auth.uid() = user_id);

CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_status ON invoices(status);

-- ─── Premium Features ───────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS premium_features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  feature_key VARCHAR(100) UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  required_plan VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE premium_features ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active premium features"
  ON premium_features FOR SELECT
  USING (is_active = true);

CREATE INDEX idx_premium_features_key ON premium_features(feature_key);

-- ─── Updated_at Triggers ────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_user_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_settings_updated_at();

CREATE OR REPLACE FUNCTION update_user_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_user_preferences_updated_at();

CREATE OR REPLACE FUNCTION update_notification_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notification_preferences_updated_at
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_notification_preferences_updated_at();

-- ─── Insert Default Premium Features ────────────────────────────────────────

INSERT INTO premium_features (name, description, feature_key, required_plan) VALUES
('Unlimited AI Chat', 'Unlimited conversations with AI tutor', 'unlimited_ai_chat', 'pro'),
('Advanced Analytics', 'Detailed learning analytics and insights', 'advanced_analytics', 'pro'),
('Priority Support', 'Priority customer support', 'priority_support', 'pro'),
('Offline Mode', 'Download lessons for offline access', 'offline_mode', 'premium'),
('Custom Study Plans', 'AI-generated personalized study plans', 'custom_study_plans', 'premium'),
('1-on-1 Tutoring', 'Live sessions with human tutors', 'one_on_one_tutoring', 'premium'),
('Exam Simulation', 'Full-length practice exams with scoring', 'exam_simulation', 'pro'),
('Voice Analysis', 'Advanced pronunciation feedback', 'voice_analysis', 'pro')
ON CONFLICT (feature_key) DO NOTHING;
