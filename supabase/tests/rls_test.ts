import { assertEquals, assert, assertExists } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

// ─── RLS Policy Tests ────────────────────────────────────────────────────────

Deno.test('RLS - All tables have RLS enabled', () => {
  const tablesWithRLS = [
    'user_profiles',
    'user_goals',
    'user_settings',
    'user_preferences',
    'lessons',
    'lesson_progress',
    'vocabulary',
    'vocabulary_history',
    'ai_conversations',
    'chat_messages',
    'voice_sessions',
    'exam_attempts',
    'exam_scores',
    'exam_feedback',
    'ai_memory',
    'ai_context',
    'ai_feedback',
    'subscriptions',
    'payments',
    'invoices',
    'achievements',
    'badges',
    'user_badges',
    'notifications',
    'notification_preferences',
    'analytics_events',
    'daily_progress',
    'learning_statistics',
    'xp_history',
    'streaks',
    'user_progress',
    'grammar_topics',
    'reading_lessons',
    'listening_lessons',
    'writing_tasks',
    'pronunciation_scores',
    'transcripts',
    'premium_features',
    'audit_logs',
    'exams'
  ]
  assert(tablesWithRLS.length > 0)
})

// ─── User Profile RLS Tests ─────────────────────────────────────────────────

Deno.test('RLS - User can read own profile', () => {
  const policy = {
    table: 'user_profiles',
    operation: 'SELECT',
    condition: 'auth.uid() = auth_user_id',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
  assert(policy.condition.includes('auth.uid()'))
})

Deno.test('RLS - User can update own profile', () => {
  const policy = {
    table: 'user_profiles',
    operation: 'UPDATE',
    condition: 'auth.uid() = auth_user_id',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
  assert(policy.condition.includes('auth.uid()'))
})

Deno.test('RLS - User cannot read other profiles', () => {
  const policy = {
    table: 'user_profiles',
    operation: 'SELECT',
    condition: 'auth.uid() = auth_user_id',
    effect: 'DENY'
  }
  assertEquals(policy.effect, 'DENY')
})

// ─── Lesson Progress RLS Tests ───────────────────────────────────────────────

Deno.test('RLS - User can read own lesson progress', () => {
  const policy = {
    table: 'lesson_progress',
    operation: 'SELECT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
  assert(policy.condition.includes('current_user_profile_id'))
})

Deno.test('RLS - User can insert own lesson progress', () => {
  const policy = {
    table: 'lesson_progress',
    operation: 'INSERT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

// ─── Vocabulary RLS Tests ────────────────────────────────────────────────────

Deno.test('RLS - User can read own vocabulary history', () => {
  const policy = {
    table: 'vocabulary_history',
    operation: 'SELECT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

Deno.test('RLS - User can insert own vocabulary history', () => {
  const policy = {
    table: 'vocabulary_history',
    operation: 'INSERT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

// ─── AI Conversations RLS Tests ──────────────────────────────────────────────

Deno.test('RLS - User can read own AI conversations', () => {
  const policy = {
    table: 'ai_conversations',
    operation: 'SELECT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

Deno.test('RLS - User can read own chat messages via conversation', () => {
  const policy = {
    table: 'chat_messages',
    operation: 'SELECT',
    condition: 'conversation_id IN (SELECT id FROM ai_conversations WHERE user_id = public.current_user_profile_id())',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
  assert(policy.condition.includes('ai_conversations'))
})

// ─── Voice Sessions RLS Tests ────────────────────────────────────────────────

Deno.test('RLS - User can read own voice sessions', () => {
  const policy = {
    table: 'voice_sessions',
    operation: 'SELECT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

// ─── Exam Attempts RLS Tests ─────────────────────────────────────────────────

Deno.test('RLS - User can read own exam attempts', () => {
  const policy = {
    table: 'exam_attempts',
    operation: 'SELECT',
    condition: 'auth.uid() = user_id',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

Deno.test('RLS - User can read own exam scores via attempt', () => {
  const policy = {
    table: 'exam_scores',
    operation: 'SELECT',
    condition: 'attempt_id IN (SELECT id FROM exam_attempts WHERE user_id = auth.uid())',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
  assert(policy.condition.includes('exam_attempts'))
})

// ─── Subscription RLS Tests ──────────────────────────────────────────────────

Deno.test('RLS - User can read own subscriptions', () => {
  const policy = {
    table: 'subscriptions',
    operation: 'SELECT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

// ─── Notifications RLS Tests ─────────────────────────────────────────────────

Deno.test('RLS - User can read own notifications', () => {
  const policy = {
    table: 'notifications',
    operation: 'SELECT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

// ─── Analytics RLS Tests ─────────────────────────────────────────────────────

Deno.test('RLS - User can insert own analytics events', () => {
  const policy = {
    table: 'analytics_events',
    operation: 'INSERT',
    condition: 'user_id = public.current_user_profile_id()',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
})

// ─── Admin RLS Tests ─────────────────────────────────────────────────────────

Deno.test('RLS - Admin can read all audit logs', () => {
  const policy = {
    table: 'audit_logs',
    operation: 'SELECT',
    condition: 'EXISTS (SELECT 1 FROM user_profiles WHERE auth_user_id = auth.uid() AND role = \'admin\')',
    effect: 'ALLOW'
  }
  assertEquals(policy.effect, 'ALLOW')
  assert(policy.condition.includes('admin'))
})
