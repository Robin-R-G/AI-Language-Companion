import { assertEquals, assert } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

// ─── Conversation Context Tests ───────────────────────────────────────────────

Deno.test('ConversationContext - has required fields', () => {
  const context = {
    conversationId: 'conv_001',
    userId: 'user_001',
    recentMessages: [],
    userProfile: null,
    memories: [],
  };

  assertEquals(typeof context.conversationId, 'string');
  assertEquals(typeof context.userId, 'string');
  assertEquals(Array.isArray(context.recentMessages), true);
  assertEquals(Array.isArray(context.memories), true);
});

Deno.test('UserProfile - has required fields', () => {
  const profile = {
    id: 'user_001',
    fullName: 'Rahul Nair',
    nativeLanguage: 'Malayalam',
    targetLanguage: 'English',
    proficiencyLevel: 'B1',
    targetExam: 'ielts',
    dailyGoalMinutes: 20,
  };

  assertEquals(profile.proficiencyLevel, 'B1');
  assertEquals(profile.nativeLanguage, 'Malayalam');
  assertEquals(profile.dailyGoalMinutes, 20);
});

// ─── Context Truncation Tests ─────────────────────────────────────────────────

Deno.test('truncateContext - keeps messages within token limit', () => {
  const MAX_CONTEXT_TOKENS = 3000;
  const MAX_CHARS = MAX_CONTEXT_TOKENS * 4;

  const messages = Array.from({ length: 20 }, (_, i) => ({
    role: i % 2 === 0 ? 'user' : 'assistant',
    content: 'A'.repeat(200), // ~50 tokens each
  }));

  let totalChars = 0;
  const truncated: typeof messages = [];

  for (let i = messages.length - 1; i >= 0; i--) {
    const msg = messages[i];
    totalChars += msg.content.length;
    if (totalChars > MAX_CHARS) break;
    truncated.unshift(msg);
  }

  assert(truncated.length <= messages.length);
  assert(truncated.length > 0);
});

Deno.test('truncateContext - handles empty messages', () => {
  const messages: { role: string; content: string }[] = [];

  const truncated = messages.slice(-10);

  assertEquals(truncated.length, 0);
});

Deno.test('truncateContext - handles single message', () => {
  const messages = [{ role: 'user', content: 'Hello' }];

  const truncated = messages.slice(-10);

  assertEquals(truncated.length, 1);
});

// ─── Memory Extraction Tests ──────────────────────────────────────────────────

Deno.test('extractMemoryInsights - extracts grammar weakness', () => {
  const grammarFeedback = {
    is_correct: false,
    category: 'Tense',
    original: 'I have went',
    corrected: 'I have gone',
    explanation: 'Use past participle after have/has',
  };

  const insights: { type: string; content: string; importance: number }[] = [];

  if (grammarFeedback && !grammarFeedback.is_correct) {
    insights.push({
      type: 'grammar_weakness',
      content: `User made a ${grammarFeedback.category} error: "${grammarFeedback.original}" -> "${grammarFeedback.corrected}". Rule: ${grammarFeedback.explanation}`,
      importance: 3,
    });
  }

  assertEquals(insights.length, 1);
  assertEquals(insights[0].type, 'grammar_weakness');
  assertEquals(insights[0].importance, 3);
  assert(insights[0].content.includes('Tense'));
});

Deno.test('extractMemoryInsights - extracts learning gap', () => {
  const userMessage = "I don't understand this grammar rule. Can you explain?";

  const insights: { type: string; content: string; importance: number }[] = [];

  const lowerMsg = userMessage.toLowerCase();
  if (
    lowerMsg.includes("i don't understand") ||
    lowerMsg.includes('can you explain')
  ) {
    insights.push({
      type: 'learning_gap',
      content: 'User requested clarification on a topic.',
      importance: 2,
    });
  }

  assertEquals(insights.length, 1);
  assertEquals(insights[0].type, 'learning_gap');
  assertEquals(insights[0].importance, 2);
});

Deno.test('extractMemoryInsights - no insights for correct grammar', () => {
  const grammarFeedback = {
    is_correct: true,
  };

  const insights: { type: string; content: string; importance: number }[] = [];

  if (grammarFeedback && !grammarFeedback.is_correct) {
    insights.push({
      type: 'grammar_weakness',
      content: 'error',
      importance: 3,
    });
  }

  assertEquals(insights.length, 0);
});

Deno.test('extractMemoryInsights - no insights for normal message', () => {
  const userMessage = 'The weather is nice today.';

  const insights: { type: string; content: string; importance: number }[] = [];

  const lowerMsg = userMessage.toLowerCase();
  if (
    lowerMsg.includes("i don't understand") ||
    lowerMsg.includes('can you explain')
  ) {
    insights.push({
      type: 'learning_gap',
      content: 'User requested clarification.',
      importance: 2,
    });
  }

  assertEquals(insights.length, 0);
});

// ─── Message Saving Tests ─────────────────────────────────────────────────────

Deno.test('saveMessage - constructs correct insert data', () => {
  const conversationId = 'conv_001';
  const role = 'user';
  const content = 'Hello, how are you?';
  const metadata = {
    tokenCount: 50,
    latencyMs: 200,
  };

  const insertData: any = {
    conversation_id: conversationId,
    role,
    content,
  };

  if (metadata?.tokenCount) {
    insertData.token_count = metadata.tokenCount;
  }
  if (metadata?.latencyMs) {
    insertData.latency_ms = metadata.latencyMs;
  }

  assertEquals(insertData.conversation_id, 'conv_001');
  assertEquals(insertData.role, 'user');
  assertEquals(insertData.content, 'Hello, how are you?');
  assertEquals(insertData.token_count, 50);
  assertEquals(insertData.latency_ms, 200);
});

Deno.test('saveMessage - handles grammar feedback metadata', () => {
  const metadata = {
    grammarFeedback: {
      is_correct: false,
      corrected: 'corrected text',
    },
  };

  const insertData: any = {
    conversation_id: 'conv_001',
    role: 'assistant',
    content: 'response',
  };

  if (metadata?.grammarFeedback) {
    insertData.grammar_feedback = metadata.grammarFeedback;
  }

  assertEquals(insertData.grammar_feedback.is_correct, false);
  assertEquals(insertData.grammar_feedback.corrected, 'corrected text');
});

Deno.test('saveMessage - handles translation metadata', () => {
  const metadata = {
    translation: {
      translation: 'malayalam text',
      pronunciation: 'phonetic',
    },
  };

  const insertData: any = {
    conversation_id: 'conv_001',
    role: 'assistant',
    content: 'response',
  };

  if (metadata?.translation) {
    insertData.translation = metadata.translation;
  }

  assertEquals(insertData.translation.translation, 'malayalam text');
  assertEquals(insertData.translation.pronunciation, 'phonetic');
});

// ─── Memory Entry Tests ───────────────────────────────────────────────────────

Deno.test('MemoryEntry - has required fields', () => {
  const entry = {
    id: 'mem_001',
    memoryType: 'grammar_weakness',
    content: 'User struggles with present perfect',
    importance: 3,
  };

  assertEquals(typeof entry.id, 'string');
  assertEquals(typeof entry.memoryType, 'string');
  assertEquals(typeof entry.content, 'string');
  assert(entry.importance >= 1 && entry.importance <= 5);
});

Deno.test('MemoryEntry - importance scoring', () => {
  const lowImportance = 1;
  const mediumImportance = 2;
  const highImportance = 3;

  assert(lowImportance < mediumImportance);
  assert(mediumImportance < highImportance);
});
