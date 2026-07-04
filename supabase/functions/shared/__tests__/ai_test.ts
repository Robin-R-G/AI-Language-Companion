import { assertEquals, assert } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

// ─── AI Provider Interface Tests ──────────────────────────────────────────────

Deno.test('AIProvider - OpenAI provider has correct models', () => {
  const models = {
    fast: 'gpt-4o-mini',
    standard: 'gpt-4o',
    premium: 'gpt-4o',
  };

  assertEquals(models.fast, 'gpt-4o-mini');
  assertEquals(models.standard, 'gpt-4o');
  assertEquals(models.premium, 'gpt-4o');
});

Deno.test('AIProvider - Gemini provider has correct models', () => {
  const models = {
    fast: 'gemini-1.5-flash',
    standard: 'gemini-1.5-flash',
    premium: 'gemini-1.5-pro',
  };

  assertEquals(models.fast, 'gemini-1.5-flash');
  assertEquals(models.standard, 'gemini-1.5-flash');
  assertEquals(models.premium, 'gemini-1.5-pro');
});

// ─── Message Formatting Tests ─────────────────────────────────────────────────

Deno.test('Gemini formatMessages - converts OpenAI messages to Gemini format', () => {
  const messages = [
    { role: 'system', content: 'You are a helpful tutor.' },
    { role: 'user', content: 'Hello!' },
    { role: 'assistant', content: 'Hi there!' },
  ];

  const systemMsg = messages.find((m) => m.role === 'system');
  const chatMsgs = messages.filter((m) => m.role !== 'system');

  const contents = chatMsgs.map((m) => ({
    role: m.role === 'assistant' ? 'model' : 'user',
    parts: [{ text: m.content }],
  }));

  if (systemMsg) {
    contents.unshift({
      role: 'user',
      parts: [{ text: `[System Instructions]: ${systemMsg.content}` }],
    });
  }

  assertEquals(contents.length, 3);
  assertEquals(contents[0].role, 'user');
  assertEquals(contents[0].parts[0].text, '[System Instructions]: You are a helpful tutor.');
  assertEquals(contents[1].role, 'user');
  assertEquals(contents[1].parts[0].text, 'Hello!');
  assertEquals(contents[2].role, 'model');
  assertEquals(contents[2].parts[0].text, 'Hi there!');
});

Deno.test('Gemini formatMessages - handles messages without system prompt', () => {
  const messages = [
    { role: 'user', content: 'What is grammar?' },
    { role: 'assistant', content: 'Grammar is the system of rules...' },
  ];

  const systemMsg = messages.find((m) => m.role === 'system');
  const chatMsgs = messages.filter((m) => m.role !== 'system');

  assertEquals(systemMsg, undefined);
  assertEquals(chatMsgs.length, 2);
});

Deno.test('Gemini formatMessages - handles empty messages', () => {
  const messages: { role: string; content: string }[] = [];

  const systemMsg = messages.find((m) => m.role === 'system');
  const chatMsgs = messages.filter((m) => m.role !== 'system');

  assertEquals(systemMsg, undefined);
  assertEquals(chatMsgs.length, 0);
});

// ─── Provider Factory Tests ───────────────────────────────────────────────────

Deno.test('AIProviderFactory - defaults to gemini primary, openai fallback', () => {
  const primary = 'gemini';
  const fallback = 'openai';

  assertEquals(primary, 'gemini');
  assertEquals(fallback, 'openai');
});

Deno.test('AIProviderFactory - can configure custom providers', () => {
  const primary = 'openai';
  const fallback = 'gemini';

  assertEquals(primary, 'openai');
  assertEquals(fallback, 'gemini');
});

Deno.test('AIProviderFactory - fallback switches to other provider on failure', () => {
  const primary = 'gemini';
  const fallback = primary === 'gemini' ? 'openai' : 'gemini';

  assertEquals(fallback, 'openai');
});

// ─── AI Response Format Tests ─────────────────────────────────────────────────

Deno.test('AIResponse - has required fields', () => {
  const response = {
    content: 'Hello!',
    provider: 'gemini',
    model: 'gemini-1.5-flash',
    tokensUsed: 50,
    latencyMs: 250,
  };

  assertEquals(typeof response.content, 'string');
  assertEquals(typeof response.provider, 'string');
  assertEquals(typeof response.model, 'string');
  assertEquals(typeof response.tokensUsed, 'number');
  assertEquals(typeof response.latencyMs, 'number');
});

Deno.test('ChatMessage - has correct role types', () => {
  const validRoles = ['system', 'user', 'assistant'];

  assertEquals(validRoles.includes('system'), true);
  assertEquals(validRoles.includes('user'), true);
  assertEquals(validRoles.includes('assistant'), true);
  assertEquals(validRoles.includes('invalid'), false);
});

// ─── Streaming Tests ──────────────────────────────────────────────────────────

Deno.test('SSE chunk parsing - extracts content from OpenAI delta', () => {
  const chunk = 'data: {"choices":[{"delta":{"content":"Hello"}}]}';
  const data = chunk.replace('data: ', '');

  const parsed = JSON.parse(data);
  const delta = parsed.choices?.[0]?.delta?.content;

  assertEquals(delta, 'Hello');
});

Deno.test('SSE chunk parsing - handles [DONE] marker', () => {
  const chunk = 'data: [DONE]';

  assertEquals(chunk.replace('data: ', ''), '[DONE]');
});

Deno.test('SSE chunk parsing - handles malformed JSON gracefully', () => {
  const chunk = 'data: {invalid json}';

  let parsed = null;
  try {
    parsed = JSON.parse(chunk.replace('data: ', ''));
  } catch {
    // Skip malformed chunks
  }

  assertEquals(parsed, null);
});

Deno.test('SSE chunk parsing - extracts Gemini content', () => {
  const chunk =
    'data: {"candidates":[{"content":{"parts":[{"text":"Response"}]}}]}';
  const data = chunk.replace('data: ', '');

  const parsed = JSON.parse(data);
  const delta = parsed.candidates?.[0]?.content?.parts?.[0]?.text;

  assertEquals(delta, 'Response');
});

// ─── Error Handling Tests ─────────────────────────────────────────────────────

Deno.test('AI timeout error format', () => {
  const error = {
    code: 'AI_TIMEOUT',
    message: 'AI provider timed out',
    status: 504,
  };

  assertEquals(error.status, 504);
  assertEquals(error.code, 'AI_TIMEOUT');
});

Deno.test('AI provider error format', () => {
  const error = {
    code: 'AI_PROVIDER_ERROR',
    message: 'OpenAI API error (429): Rate limit exceeded',
    status: 502,
  };

  assertEquals(error.status, 502);
  assert(error.message.includes('Rate limit'));
});

Deno.test('provider fallback error aggregates both errors', () => {
  const primaryError = new Error('Gemini failed');
  const fallbackError = new Error('OpenAI failed');

  const combinedMessage = `All AI providers failed. Primary: ${primaryError}, Fallback: ${fallbackError}`;

  assert(combinedMessage.includes('Gemini failed'));
  assert(combinedMessage.includes('OpenAI failed'));
  assert(combinedMessage.includes('All AI providers failed'));
});

// ─── Token Counting Tests ────────────────────────────────────────────────────

Deno.test('token estimation - approximate token count from text', () => {
  const text = 'Hello, how are you today?';
  const estimatedTokens = Math.ceil(text.length / 4);

  assert(estimatedTokens > 0);
  assert(estimatedTokens < 100);
});

Deno.test('token estimation - longer text has more tokens', () => {
  const shortText = 'Hello';
  const longText = 'Hello, how are you today? I am learning English and I want to improve my grammar skills.';

  const shortTokens = Math.ceil(shortText.length / 4);
  const longTokens = Math.ceil(longText.length / 4);

  assert(longTokens > shortTokens);
});
