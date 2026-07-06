-- Migration: 20260705210000_create_seed_tables_and_data.sql
-- Creates reference tables and seed data for development

ALTER TABLE public.grammar_topics ALTER COLUMN difficulty TYPE VARCHAR(50);

-- ─── Languages ──────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS languages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(10) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  native_name VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE languages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view languages"
  ON languages FOR SELECT
  USING (is_active = true);

-- ─── CEFR Levels ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS cefr_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(5) UNIQUE NOT NULL,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  min_xp INTEGER DEFAULT 0,
  max_xp INTEGER,
  order_index INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE cefr_levels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view CEFR levels"
  ON cefr_levels FOR SELECT
  USING (true);

-- ─── Lesson Categories ──────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS lesson_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE lesson_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view lesson categories"
  ON lesson_categories FOR SELECT
  USING (is_active = true);

-- ─── Vocabulary Categories ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS vocabulary_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  parent_id UUID REFERENCES vocabulary_categories(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE vocabulary_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view vocabulary categories"
  ON vocabulary_categories FOR SELECT
  USING (is_active = true);

-- ─── System Roles ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS system_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  permissions JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE system_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view system roles"
  ON system_roles FOR SELECT
  USING (is_active = true);

-- ─── Notification Templates ─────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS notification_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  title_template TEXT NOT NULL,
  body_template TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE notification_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view notification templates"
  ON notification_templates FOR SELECT
  USING (is_active = true);

-- ─── Seed: Languages ────────────────────────────────────────────────────────

INSERT INTO languages (code, name, native_name) VALUES
('en', 'English', 'English'),
('es', 'Spanish', 'Español'),
('fr', 'French', 'Français'),
('de', 'German', 'Deutsch'),
('it', 'Italian', 'Italiano'),
('pt', 'Portuguese', 'Português'),
('zh', 'Chinese', '中文'),
('ja', 'Japanese', '日本語'),
('ko', 'Korean', '한국어'),
('ar', 'Arabic', 'العربية'),
('hi', 'Hindi', 'हिन्दी'),
('ru', 'Russian', 'Русский'),
('nl', 'Dutch', 'Nederlands'),
('sv', 'Swedish', 'Svenska'),
('tr', 'Turkish', 'Türkçe'),
('pl', 'Polish', 'Polski'),
('th', 'Thai', 'ไทย'),
('vi', 'Vietnamese', 'Tiếng Việt'),
('id', 'Indonesian', 'Bahasa Indonesia'),
('ms', 'Malay', 'Bahasa Melayu')
ON CONFLICT (code) DO NOTHING;

-- ─── Seed: CEFR Levels ──────────────────────────────────────────────────────

INSERT INTO cefr_levels (code, name, description, min_xp, max_xp, order_index) VALUES
('A1', 'Beginner', 'Can understand and use familiar everyday expressions and very basic phrases', 0, 999, 1),
('A2', 'Elementary', 'Can understand sentences and frequently used expressions related to areas of most immediate relevance', 1000, 2999, 2),
('B1', 'Intermediate', 'Can understand the main points of clear standard input on familiar matters regularly encountered in work, school, leisure, etc.', 3000, 5999, 3),
('B2', 'Upper Intermediate', 'Can understand the main ideas of complex text on both concrete and abstract topics', 6000, 9999, 4),
('C1', 'Advanced', 'Can understand a wide range of demanding, longer texts, and recognize implicit meaning', 10000, 14999, 5),
('C2', 'Proficiency', 'Can understand with ease virtually everything heard or read', 15000, NULL, 6)
ON CONFLICT (code) DO NOTHING;

-- ─── Seed: Lesson Categories ────────────────────────────────────────────────

INSERT INTO lesson_categories (name, slug, description, icon, sort_order) VALUES
('Grammar', 'grammar', 'Learn grammar rules and structures', 'book', 1),
('Vocabulary', 'vocabulary', 'Expand your word knowledge', 'dictionary', 2),
('Listening', 'listening', 'Improve your listening comprehension', 'headphones', 3),
('Reading', 'reading', 'Practice reading comprehension', 'book-open', 4),
('Writing', 'writing', 'Develop your writing skills', 'pen', 5),
('Speaking', 'speaking', 'Practice speaking and pronunciation', 'mic', 6),
('Pronunciation', 'pronunciation', 'Improve your accent and pronunciation', 'volume-2', 7),
('Conversation', 'conversation', 'Practice real-world conversations', 'message-circle', 8),
('Idioms', 'idioms', 'Learn common idioms and expressions', 'sparkles', 9),
('Business', 'business', 'Business English and professional communication', 'briefcase', 10),
('Academic', 'academic', 'Academic writing and vocabulary', 'graduation-cap', 11),
('Travel', 'travel', 'Travel vocabulary and situations', 'map', 12),
('Culture', 'culture', 'Cultural topics and customs', 'globe', 13),
('Exam Prep', 'exam-prep', 'Prepare for English exams', 'target', 14),
('Daily Life', 'daily-life', 'Everyday situations and vocabulary', 'home', 15)
ON CONFLICT (slug) DO NOTHING;

-- ─── Seed: Vocabulary Categories ────────────────────────────────────────────

INSERT INTO vocabulary_categories (name, slug, description) VALUES
('Common Words', 'common', 'Frequently used everyday words'),
('Academic', 'academic', 'Academic and scholarly vocabulary'),
('Business', 'business', 'Professional and business terminology'),
('Technology', 'technology', 'Computer and technology terms'),
('Health', 'health', 'Medical and health-related vocabulary'),
('Food & Drink', 'food-drink', 'Culinary vocabulary'),
('Travel', 'travel', 'Transportation and travel vocabulary'),
('Emotions', 'emotions', 'Feelings and emotional vocabulary'),
('Nature', 'nature', 'Environment and nature vocabulary'),
('Sports', 'sports', 'Sports and fitness vocabulary'),
('Arts', 'arts', 'Art, music, and entertainment vocabulary'),
('Science', 'science', 'Scientific terminology'),
('Law', 'law', 'Legal terminology'),
('Education', 'education', 'Academic and school vocabulary'),
('Shopping', 'shopping', 'Retail and shopping vocabulary')
ON CONFLICT (slug) DO NOTHING;

-- ─── Seed: System Roles ─────────────────────────────────────────────────────

INSERT INTO system_roles (name, description, permissions) VALUES
('admin', 'Full system access', '["*"]'::jsonb),
('moderator', 'Content moderation access', '["read", "update_content", "ban_users"]'::jsonb),
('teacher', 'Teacher access for content creation', '["read", "create_lessons", "view_analytics"]'::jsonb),
('premium', 'Premium subscriber access', '["read", "premium_features"]'::jsonb),
('user', 'Standard user access', '["read"]'::jsonb)
ON CONFLICT (name) DO NOTHING;

-- ─── Seed: Notification Templates ───────────────────────────────────────────

INSERT INTO notification_templates (name, title_template, body_template, type) VALUES
('streak_reminder', 'Keep Your Streak Alive!', 'You haven''t practiced today. Complete a lesson to maintain your {{streak}}-day streak!', 'streak'),
('daily_goal', 'Daily Goal Reminder', 'You''ve completed {{completed}}/{{goal}} minutes today. Keep going!', 'goal'),
('new_achievement', 'New Achievement Unlocked!', 'Congratulations! You''ve earned the "{{achievement}}" badge!', 'achievement'),
('vocab_review', 'Vocabulary Review Due', 'You have {{count}} words due for review. Review now to strengthen your memory!', 'reminder'),
('lesson_complete', 'Lesson Complete!', 'Great job! You completed "{{lesson}}" and earned {{xp}} XP!', 'success'),
('exam_ready', 'Exam Results Available', 'Your {{exam}} results are ready. Check your score now!', 'info'),
('subscription_expiring', 'Subscription Expiring Soon', 'Your {{plan}} subscription expires in {{days}} days. Renew to keep premium features.', 'warning'),
('weekly_report', 'Weekly Progress Report', 'This week: {{lessons}} lessons, {{xp}} XP earned, {{words}} new words!', 'report'),
('welcome', 'Welcome to AI Language Coach!', 'Start your language learning journey today. Complete your first lesson to earn 50 XP!', 'welcome'),
('level_up', 'Level Up!', 'Congratulations! You''ve reached Level {{level}}!', 'achievement')
ON CONFLICT (name) DO NOTHING;

-- ─── Seed: Sample Grammar Topics ────────────────────────────────────────────

INSERT INTO grammar_topics (title, description, category, difficulty, cefr_level, language, examples, rules) VALUES
('Present Simple', 'Used for habits, general truths, and repeated actions', 'Tenses', 'Beginner', 'A1', 'English',
'[{"example": "I speak English.", "translation": "मैं अंग्रेज़ी बोलता हूँ।"}]'::jsonb,
'[{"rule": "Use base form for I/you/we/they", "example": "I play football."}, {"rule": "Add -s/-es for he/she/it", "example": "She plays football."}]'::jsonb),
('Present Continuous', 'Used for actions happening now or temporary situations', 'Tenses', 'Beginner', 'A1', 'English',
'[{"example": "I am learning English.", "translation": "मैं अंग्रेज़ी सीख रहा हूँ।"}]'::jsonb,
'[{"rule": "Subject + am/is/are + verb-ing", "example": "I am studying."}]'::jsonb),
('Past Simple', 'Used for completed actions in the past', 'Tenses', 'Elementary', 'A2', 'English',
'[{"example": "I visited London last year.", "translation": "मैं पिछले साल लंदन गया था।"}]'::jsonb,
'[{"rule": "Regular verbs: add -ed", "example": "I walked home."}, {"rule": "Irregular verbs: memorize forms", "example": "I went home."}]'::jsonb),
('Conditional Sentences', 'Used to talk about hypothetical situations', 'Conditionals', 'Intermediate', 'B1', 'English',
'[{"example": "If I had money, I would travel the world.", "translation": "अगर मेरे पास पैसे होते, मैं दुनिया घूमता।"}]'::jsonb,
'[{"rule": "Zero conditional: If + present, present", "example": "If you heat water, it boils."}, {"rule": "First conditional: If + present, will + base", "example": "If it rains, I will stay home."}]'::jsonb),
('Relative Clauses', 'Used to give more information about nouns', 'Clauses', 'Intermediate', 'B1', 'English',
'[{"example": "The man who lives next door is a doctor.", "translation": "जो आदमी बगल में रहता है वह डॉक्टर है।"}]'::jsonb,
'[{"rule": "Who for people", "example": "The girl who sings."}, {"rule": "Which/that for things", "example": "The book that I read."}]'::jsonb)
ON CONFLICT DO NOTHING;

-- ─── Seed: Sample Lessons ───────────────────────────────────────────────────

INSERT INTO lessons (title, description, language, category, difficulty, estimated_minutes, xp_reward) VALUES
('Greetings and Introductions', 'Learn how to greet people and introduce yourself', 'English', 'Conversation', 'Beginner', 15, 100),
('Numbers and Counting', 'Learn numbers 1-100 and basic counting', 'English', 'Vocabulary', 'Beginner', 10, 75),
('At the Restaurant', 'Practice ordering food and drinks', 'English', 'Daily Life', 'Beginner', 20, 120),
('Present Perfect Tense', 'Learn to use present perfect correctly', 'English', 'Grammar', 'Intermediate', 25, 150),
('Business Email Writing', 'Write professional business emails', 'English', 'Business', 'Intermediate', 30, 200),
('IELTS Writing Task 2', 'Practice writing IELTS essay', 'English', 'Exam Prep', 'Advanced', 45, 300),
('Common Idioms', 'Learn 20 common English idioms', 'English', 'Idioms', 'Intermediate', 20, 150),
('Travel Vocabulary', 'Essential vocabulary for traveling', 'English', 'Travel', 'Beginner', 15, 100)
ON CONFLICT DO NOTHING;

-- ─── Seed: Sample Vocabulary ────────────────────────────────────────────────

INSERT INTO vocabulary (word, meaning, pronunciation, examples, cefr_level) VALUES
('hello', 'A greeting', '/həˈloʊ/', '[{"example": "Hello, how are you?", "context": "Greeting"}]'::jsonb, 'A1'),
('goodbye', 'A farewell', '/ɡʊdˈbaɪ/', '[{"example": "Goodbye, see you tomorrow!", "context": "Farewell"}]'::jsonb, 'A1'),
('please', 'Polite request word', '/pliːz/', '[{"example": "Please pass the salt.", "context": "Polite request"}]'::jsonb, 'A1'),
('thank you', 'Expression of gratitude', '/θæŋk juː/', '[{"example": "Thank you for your help.", "context": "Gratitude"}]'::jsonb, 'A1'),
('beautiful', 'Pleasing to the senses', '/ˈbjuːtɪfəl/', '[{"example": "The sunset is beautiful.", "context": "Description"}]'::jsonb, 'A1'),
('important', 'Of great significance', '/ɪmˈpɔːrtənt/', '[{"example": "This is very important.", "context": "Emphasis"}]'::jsonb, 'A2'),
('understand', 'Comprehend the meaning', '/ˌʌndərˈstænd/', '[{"example": "I understand the lesson.", "context": "Learning"}]'::jsonb, 'A2'),
('environment', 'Natural world and surroundings', '/ɪnˈvaɪrənmənt/', '[{"example": "We must protect the environment.", "context": "Nature"}]'::jsonb, 'B1'),
('opportunity', 'A chance to do something', '/ˌɒpərˈtjuːnɪti/', '[{"example": "This is a great opportunity.", "context": "Career"}]'::jsonb, 'B1'),
('consequence', 'A result of an action', '/ˈkɒnsɪkwəns/', '[{"example": "Consider the consequences.", "context": "Decision-making"}]'::jsonb, 'B1')
ON CONFLICT DO NOTHING;
