import {
  badRequest,
  unauthorized,
  notFound,
  serverError,
  successResponse,
  createdResponse,
  rateLimited,
} from '../errors.ts'
import { assertEquals } from 'https://deno.land/std@0.177.0/testing/asserts.ts'

function parseResponse(res: Response): Promise<any> {
  return res.json()
}

Deno.test('badRequest returns 400 with error code', async () => {
  const res = badRequest('Missing field')
  assertEquals(res.status, 400)
  const body = await parseResponse(res)
  assertEquals(body.success, false)
  assertEquals(body.error.code, 'INVALID_REQUEST')
  assertEquals(body.error.message, 'Missing field')
})

Deno.test('unauthorized returns 401', async () => {
  const res = unauthorized()
  assertEquals(res.status, 401)
  const body = await parseResponse(res)
  assertEquals(body.error.code, 'UNAUTHORIZED')
})

Deno.test('notFound returns 404', async () => {
  const res = notFound('User not found')
  assertEquals(res.status, 404)
  const body = await parseResponse(res)
  assertEquals(body.error.code, 'NOT_FOUND')
})

Deno.test('rateLimited returns 429', async () => {
  const res = rateLimited()
  assertEquals(res.status, 429)
  const body = await parseResponse(res)
  assertEquals(body.error.code, 'RATE_LIMIT_HIT')
})

Deno.test('serverError returns 500', async () => {
  const res = serverError('Internal error')
  assertEquals(res.status, 500)
  const body = await parseResponse(res)
  assertEquals(body.error.code, 'SERVER_ERROR')
})

Deno.test('successResponse returns 200 with data', async () => {
  const res = successResponse({ greeting: 'hello' })
  assertEquals(res.status, 200)
  const body = await parseResponse(res)
  assertEquals(body.success, true)
  assertEquals(body.data.greeting, 'hello')
})

Deno.test('createdResponse returns 201', async () => {
  const res = createdResponse({ id: 'abc' })
  assertEquals(res.status, 201)
  const body = await parseResponse(res)
  assertEquals(body.success, true)
  assertEquals(body.data.id, 'abc')
})
