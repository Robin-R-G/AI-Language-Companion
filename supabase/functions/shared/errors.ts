// supabase/functions/shared/errors.ts
// Standardized Error Handling

import { corsHeaders } from './cors.ts';

export type ErrorCode =
  | 'UNAUTHORIZED'
  | 'AUTH_FAILED'
  | 'INVALID_REQUEST'
  | 'NOT_FOUND'
  | 'RATE_LIMIT_HIT'
  | 'SERVER_ERROR'
  | 'AI_TIMEOUT'
  | 'AI_PROVIDER_ERROR'
  | 'PAYMENT_REQUIRED';

export interface AppError {
  code: ErrorCode;
  message: string;
  status: number;
}

export function createError(code: ErrorCode, message: string, status: number): Response {
  return new Response(
    JSON.stringify({
      success: false,
      error: { code, message },
    }),
    {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

export function unauthorized(message = 'Missing JWT authorization token'): Response {
  return createError('UNAUTHORIZED', message, 401);
}

export function authFailed(message = 'Invalid JWT authorization token'): Response {
  return createError('AUTH_FAILED', message, 401);
}

export function badRequest(message: string): Response {
  return createError('INVALID_REQUEST', message, 400);
}

export function notFound(message: string): Response {
  return createError('NOT_FOUND', message, 404);
}

export function rateLimited(message = 'Rate limit exceeded'): Response {
  return createError('RATE_LIMIT_HIT', message, 429);
}

export function serverError(message: string): Response {
  return createError('SERVER_ERROR', message, 500);
}

export function aiTimeout(message = 'AI provider timed out'): Response {
  return createError('AI_TIMEOUT', message, 504);
}

export function aiProviderError(message: string): Response {
  return createError('AI_PROVIDER_ERROR', message, 502);
}

export function successResponse(data: any, message = 'Operation completed successfully'): Response {
  return new Response(
    JSON.stringify({
      success: true,
      data,
      message,
    }),
    {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

export function createdResponse(data: any, message = 'Resource created'): Response {
  return new Response(
    JSON.stringify({
      success: true,
      data,
      message,
    }),
    {
      status: 201,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}
