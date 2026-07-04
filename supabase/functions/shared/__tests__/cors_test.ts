import { corsHeaders } from '../cors.ts'
import { assertEquals } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

Deno.test('corsHeaders has expected keys', () => {
  assertEquals(corsHeaders['Access-Control-Allow-Origin'], '*')
  assertEquals(corsHeaders['Access-Control-Allow-Headers'], 'authorization, x-client-info, apikey, content-type')
  assertEquals(corsHeaders['Access-Control-Allow-Methods'], 'POST, GET, OPTIONS, PUT, DELETE')
})
