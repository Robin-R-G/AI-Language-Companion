import {
  validateRequired,
  validateString,
  validateNumber,
  validateEnum,
  combineValidations,
} from '../validator.ts'
import { assertEquals, assert } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

Deno.test('validateRequired returns valid for non-empty fields', () => {
  const result = validateRequired({ name: 'John', age: 25 })
  assertEquals(result.isValid, true)
  assertEquals(result.errors.length, 0)
})

Deno.test('validateRequired returns invalid for missing fields', () => {
  const result = validateRequired({ name: undefined, age: null, email: '' })
  assertEquals(result.isValid, false)
  assertEquals(result.errors.length, 3)
})

Deno.test('validateString enforces min and max length', () => {
  const minResult = validateString('ab', 'name', { minLength: 3 })
  assertEquals(minResult.isValid, false)

  const okResult = validateString('hello', 'name', { minLength: 2, maxLength: 10 })
  assertEquals(okResult.isValid, true)
})

Deno.test('validateNumber enforces min, max, and integer constraints', () => {
  const intResult = validateNumber(3.5, 'count', { integer: true })
  assertEquals(intResult.isValid, false)

  const rangeResult = validateNumber(15, 'score', { min: 0, max: 10 })
  assertEquals(rangeResult.isValid, false)

  const okResult = validateNumber(7, 'score', { min: 0, max: 10, integer: true })
  assertEquals(okResult.isValid, true)
})

Deno.test('validateEnum validates against allowed values', () => {
  const result = validateEnum('openai', 'provider', ['openai', 'gemini'])
  assertEquals(result.isValid, true)

  const badResult = validateEnum('anthropic', 'provider', ['openai', 'gemini'])
  assertEquals(badResult.isValid, false)
})

Deno.test('combineValidations aggregates errors', () => {
  const r1 = validateRequired({ name: '' })
  const r2 = validateNumber(-1, 'age', { min: 0 })
  const combined = combineValidations(r1, r2)
  assertEquals(combined.isValid, false)
  assertEquals(combined.errors.length, 2)
})

Deno.test('validateString rejects non-string values', () => {
  const result = validateString(123, 'name')
  assertEquals(result.isValid, false)
  assert(result.errors[0].includes('must be a string'))
})
