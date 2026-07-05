// supabase/functions/shared/errors.ts
// Standardized Error Handling per API Specification v1.0

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
  | 'PAYMENT_REQUIRED'
  | 'VALIDATION_ERROR'
  | 'CONFLICT'
  | 'FORBIDDEN'
  | 'SERVICE_UNAVAILABLE';

export interface AppError {
  code: ErrorCode;
  message: string;
  status: number;
  details?: string[];
}

export interface ResponseMeta {
  page?: number;
  limit?: number;
  total?: number;
  total_pages?: number;
}

function buildMeta(meta?: ResponseMeta): Record<string, any> | undefined {
  if (!meta) return undefined;
  const m: Record<string, any> = {};
  if (meta.page !== undefined) m.page = meta.page;
  if (meta.limit !== undefined) m.limit = meta.limit;
  if (meta.total !== undefined) m.total = meta.total;
  if (meta.total_pages !== undefined) m.total_pages = meta.total_pages;
  return Object.keys(m).length > 0 ? m : undefined;
}

export function createError(code: ErrorCode, message: string, status: number, details?: string[]): Response {
  const errorBody: Record<string, any> = { code, message };
  if (details && details.length > 0) errorBody.details = details;

  return new Response(
    JSON.stringify({
      success: false,
      error: errorBody,
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

export function validationError(message: string, details?: string[]): Response {
  return createError('VALIDATION_ERROR', message, 422, details);
}

export function notFound(message: string): Response {
  return createError('NOT_FOUND', message, 404);
}

export function conflict(message: string): Response {
  return createError('CONFLICT', message, 409);
}

export function forbidden(message = 'Insufficient permissions'): Response {
  return createError('FORBIDDEN', message, 403);
}

export function rateLimited(message = 'Rate limit exceeded'): Response {
  return createError('RATE_LIMIT_HIT', message, 429);
}

export function serverError(message: string): Response {
  return createError('SERVER_ERROR', message, 500);
}

export function serviceUnavailable(message = 'Service temporarily unavailable'): Response {
  return createError('SERVICE_UNAVAILABLE', message, 503);
}

export function aiTimeout(message = 'AI provider timed out'): Response {
  return createError('AI_TIMEOUT', message, 504);
}

export function aiProviderError(message: string): Response {
  return createError('AI_PROVIDER_ERROR', message, 502);
}

export function paymentRequired(message = 'Subscription required'): Response {
  return createError('PAYMENT_REQUIRED', message, 402);
}

export function successResponse(data: any, message = 'Request completed successfully.', meta?: ResponseMeta): Response {
  const body: Record<string, any> = {
    success: true,
    message,
    data,
  };
  const metaObj = buildMeta(meta);
  if (metaObj) body.meta = metaObj;

  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

export function createdResponse(data: any, message = 'Resource created successfully.'): Response {
  return new Response(
    JSON.stringify({
      success: true,
      message,
      data,
    }),
    {
      status: 201,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

export function noContentResponse(): Response {
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}
