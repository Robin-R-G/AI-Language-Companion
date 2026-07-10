// supabase/functions/shared/errors.ts
import { corsHeaders } from './cors.ts'

export interface APIResponse {
  success: boolean
  message: string
  data?: unknown
  meta?: Record<string, unknown>
  error?: {
    code: string
    message: string
    details?: unknown[]
  }
}

export function successResponse(data: unknown, message = 'Request completed successfully.', meta?: Record<string, unknown>): Response {
  const body: APIResponse = {
    success: true,
    message,
    data,
  }
  if (meta) body.meta = meta

  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function createdResponse(data: unknown, message = 'Resource created successfully.'): Response {
  return new Response(JSON.stringify({
    success: true,
    message,
    data,
  } as APIResponse), {
    status: 201,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function noContentResponse(): Response {
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  })
}

export function badRequest(message = 'Invalid request.', details?: unknown[]): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'VALIDATION_ERROR',
      message,
      details,
    },
  } as APIResponse), {
    status: 400,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function unauthorized(message = 'Authentication required.'): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'UNAUTHORIZED',
      message,
    },
  } as APIResponse), {
    status: 401,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function forbidden(message = 'Access denied.'): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'FORBIDDEN',
      message,
    },
  } as APIResponse), {
    status: 403,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function notFound(message = 'Resource not found.'): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message,
    },
  } as APIResponse), {
    status: 404,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function conflict(message = 'Resource already exists.'): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'CONFLICT',
      message,
    },
  } as APIResponse), {
    status: 409,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function rateLimited(message = 'Rate limit exceeded.'): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'RATE_LIMITED',
      message,
    },
  } as APIResponse), {
    status: 429,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function aiProviderError(message = 'AI provider error.'): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'AI_PROVIDER_ERROR',
      message,
    },
  } as APIResponse), {
    status: 502,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

export function serverError(message = 'Internal server error.'): Response {
  return new Response(JSON.stringify({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message,
    },
  } as APIResponse), {
    status: 500,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
