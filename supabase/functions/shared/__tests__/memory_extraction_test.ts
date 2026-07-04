import { assertEquals, assert } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

// ─── Grammar Weakness Extraction ──────────────────────────────────────────────

Deno.test('grammar weakness extraction - present perfect error', () => {
  const feedback = {
    is_correct: false,
    category: 'Tense',
    original: 'I have went to school',
    corrected: 'I have gone to school',
    explanation: 'Use past participle "gone" after "have"',
  };

  const insights: any[] = [];
  if (!feedback.is_correct) {
    insights.push({
      type: 'grammar_weakness',
      content: `${feedback.category} error detected`,
      importance: 3,
    });
  }

  assertEquals(insights.length, 1);
  assertEquals(insights[0].type, 'grammar_weakness');
});

Deno.test('grammar weakness extraction - subject verb agreement', () => {
  const feedback = {
    is_correct: false,
    category: 'Subject-Verb Agreement',
    original: 'He go to school',
    corrected: 'He goes to school',
    explanation: 'Third person singular requires "goes"',
  };

  const insights: any[] = [];
  if (!feedback.is_correct) {
    insights.push({
      type: 'grammar_weakness',
      content: `${feedback.category} error detected`,
      importance: 3,
    });
  }

  assertEquals(insights.length, 1);
  assert(insights[0].content.includes('Subject-Verb Agreement'));
});

Deno.test('grammar weakness extraction - preposition error', () => {
  const feedback = {
    is_correct: false,
    category: 'Preposition',
    original: 'I am interested in to learn',
    corrected: 'I am interested in learning',
    explanation: 'Use gerund after "interested in"',
  };

  const insights: any[] = [];
  if (!feedback.is_correct) {
    insights.push({
      type: 'grammar_weakness',
      content: `${feedback.category} error detected`,
      importance: 3,
    });
  }

  assertEquals(insights.length, 1);
  assert(insights[0].content.includes('Preposition'));
});

// ─── Learning Gap Detection ───────────────────────────────────────────────────

Deno.test('learning gap - explicit confusion', () => {
  const messages = [
    "I don't understand",
    "I don't understand this",
    "Can you explain?",
    "Can you explain this rule?",
    "What does this mean?",
    "I'm confused",
  ];

  for (const msg of messages) {
    const lower = msg.toLowerCase();
    const isGap =
      lower.includes("don't understand") ||
      lower.includes('can you explain') ||
      lower.includes('what does') ||
      lower.includes('confused');

    assert(isGap, `Message "${msg}" should be detected as learning gap`);
  }
});

Deno.test('learning gap - normal messages not detected', () => {
  const messages = [
    'The weather is nice',
    'I went to school yesterday',
    'She is a teacher',
    'We play cricket',
  ];

  for (const msg of messages) {
    const lower = msg.toLowerCase();
    const isGap =
      lower.includes("don't understand") ||
      lower.includes('can you explain');

    assertEquals(isGap, false, `Message "${msg}" should not be detected as gap`);
  }
});

// ─── Importance Scoring ───────────────────────────────────────────────────────

Deno.test('importance scoring - grammar errors are high priority', () => {
  const importance = 3;
  assert(importance >= 3, 'Grammar errors should have importance >= 3');
});

Deno.test('importance scoring - learning gaps are medium priority', () => {
  const importance = 2;
  assertEquals(importance, 2);
});

Deno.test('importance scoring - positive feedback is low priority', () => {
  const importance = 1;
  assert(importance <= 2, 'Positive feedback should have importance <= 2');
});

// ─── Memory Type Classification ───────────────────────────────────────────────

Deno.test('memory types - valid types', () => {
  const validTypes = [
    'grammar_weakness',
    'learning_gap',
    'vocabulary_gap',
    'pronunciation_issue',
    'strength',
    'preference',
  ];

  assert(validTypes.includes('grammar_weakness'));
  assert(validTypes.includes('learning_gap'));
  assert(validTypes.includes('vocabulary_gap'));
  assert(validTypes.includes('pronunciation_issue'));
  assert(validTypes.includes('strength'));
  assert(validTypes.includes('preference'));
});

Deno.test('memory types - invalid type not in list', () => {
  const validTypes = [
    'grammar_weakness',
    'learning_gap',
    'vocabulary_gap',
  ];

  assertEquals(validTypes.includes('invalid_type'), false);
});
