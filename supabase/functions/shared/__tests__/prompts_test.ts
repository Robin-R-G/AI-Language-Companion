import {
  buildPrompt,
  buildTutorPrompt,
  buildGrammarPrompt,
  buildTranslationPrompt,
} from '../prompts.ts'
import { assertEquals, assert } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

Deno.test('buildTutorPrompt includes target language and level', () => {
  const prompt = buildTutorPrompt({
    targetLanguage: 'English',
    nativeLanguage: 'Malayalam',
    learningLevel: 'A1',
  })
  assert(prompt.includes('TARGET LANGUAGE: English'))
  assert(prompt.includes('NATIVE LANGUAGE: Malayalam'))
  assert(prompt.includes('USER LEVEL: A1'))
  assert(prompt.includes('AI Language Coach'))
})

Deno.test('buildTutorPrompt adjusts scaffolding for beginner level', () => {
  const prompt = buildTutorPrompt({
    learningLevel: 'A1',
    nativeLanguage: 'Hindi',
  })
  assert(prompt.includes('dual Hindi and English explanations'))
})

Deno.test('buildTutorPrompt uses English-only for advanced levels', () => {
  const prompt = buildTutorPrompt({
    learningLevel: 'C1',
    nativeLanguage: 'Malayalam',
  })
  assert(prompt.includes('Do NOT include Malayalam translations'))
})

Deno.test('buildGrammarPrompt returns structured JSON format', () => {
  const prompt = buildGrammarPrompt({
    targetLanguage: 'English',
    nativeLanguage: 'Malayalam',
    learningLevel: 'B1',
  })
  assert(prompt.includes('"is_correct"'))
  assert(prompt.includes('"corrected"'))
  assert(prompt.includes('"explanation"'))
  assert(prompt.includes('"category"'))
})

Deno.test('buildTranslationPrompt includes source and target languages', () => {
  const prompt = buildTranslationPrompt({
    targetLanguage: 'English',
    nativeLanguage: 'French',
  })
  assert(prompt.includes('SOURCE LANGUAGE'))
  assert(prompt.includes('TARGET LANGUAGE'))
  assert(prompt.includes('"translation"'))
})

Deno.test('buildPrompt dispatches to correct builder', () => {
  const tutor = buildPrompt('tutor', { targetLanguage: 'English' })
  assert(tutor.includes('Expert language tutor'))

  const grammar = buildPrompt('grammar', { targetLanguage: 'English' })
  assert(grammar.includes('Specialized grammar coach'))

  const translation = buildPrompt('translation', { targetLanguage: 'English' })
  assert(translation.includes('Professional translator'))
})
