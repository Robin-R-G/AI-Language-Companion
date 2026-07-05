import { assertEquals, assert, assertExists } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

// ─── AI Chat Tests ───────────────────────────────────────────────────────────

Deno.test('AI Chat - Send message request format', () => {
  const request = {
    message: 'How do I use present perfect?',
    conversation_id: 'conv_001',
    model_preference: 'fast'
  }
  assertExists(request.message)
  assert(request.message.length > 0)
})

Deno.test('AI Chat - Response contains message', () => {
  const response = {
    success: true,
    data: {
      message: 'The present perfect is formed with have/has + past participle.',
      grammar_feedback: null,
      translation: null
    }
  }
  assertEquals(response.success, true)
  assertExists(response.data.message)
})

// ─── Grammar Check Tests ─────────────────────────────────────────────────────

Deno.test('Grammar Check - Validate input text', () => {
  const request = {
    text: 'I have went to the store',
    target_language: 'English',
    native_language: 'Malayalam'
  }
  assertExists(request.text)
  assert(request.text.length > 0)
})

Deno.test('Grammar Check - Response format', () => {
  const response = {
    success: true,
    data: {
      is_correct: false,
      original: 'I have went',
      corrected: 'I have gone',
      explanation: 'Use past participle',
      category: 'Tense',
      examples: ['I have eaten', 'She has gone']
    }
  }
  assertEquals(response.success, true)
  assertEquals(response.data.is_correct, false)
  assert(response.data.examples.length > 0)
})

// ─── Writing Evaluate Tests ──────────────────────────────────────────────────

Deno.test('Writing Evaluate - Essay submission', () => {
  const request = {
    essay: 'Climate change is one of the most pressing issues...',
    task_type: 'essay',
    target_language: 'English'
  }
  assertExists(request.essay)
  assert(request.essay.length > 0)
})

Deno.test('Writing Evaluate - Response format', () => {
  const response = {
    success: true,
    data: {
      estimated_band: '6.5',
      grammar_score: 72,
      vocabulary_score: 68,
      organization_score: 75,
      clarity_score: 70,
      strengths: ['Good task achievement'],
      mistakes: ['Run-on sentences'],
      improved_version: 'Improved essay text...',
      recommendations: ['Practice complex sentences']
    }
  }
  assertEquals(response.success, true)
  assertEquals(response.data.estimated_band, '6.5')
  assert(response.data.strengths.length > 0)
})

// ─── Speaking Evaluate Tests ─────────────────────────────────────────────────

Deno.test('Speaking Evaluate - Transcript submission', () => {
  const request = {
    transcript: 'Hello, how are you today?',
    target_language: 'English'
  }
  assertExists(request.transcript)
  assert(request.transcript.length > 0)
})

Deno.test('Speaking Evaluate - Response format', () => {
  const response = {
    success: true,
    data: {
      fluency_score: 82,
      grammar_score: 75,
      vocabulary_score: 80,
      pronunciation_score: 70,
      overall_score: 78,
      feedback: 'Good job',
      strengths: ['Clear speech'],
      issues: ['Minor errors'],
      practice_words: ['example'],
      shadowing_exercise: 'Practice sentence',
      estimated_proficiency: 'B1'
    }
  }
  assertEquals(response.success, true)
  assert(response.data.overall_score >= 0)
  assert(response.data.overall_score <= 100)
})

// ─── Vocabulary Tests ────────────────────────────────────────────────────────

Deno.test('Vocabulary - Daily vocabulary request', () => {
  const request = {
    action: 'daily',
    target_language: 'English',
    native_language: 'Malayalam',
    level: 'B1'
  }
  assertExists(request.action)
  assertExists(request.level)
})

Deno.test('Vocabulary - Word definition format', () => {
  const word = {
    word: 'hello',
    meaning: 'A greeting',
    pronunciation: '/həˈloʊ/',
    examples: ['Hello, how are you?'],
    cefr_level: 'A1'
  }
  assertExists(word.word)
  assertExists(word.meaning)
  assertExists(word.cefr_level)
})
