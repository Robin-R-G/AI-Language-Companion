// supabase/functions/shared/rate-limiter.ts
// In-memory rate limiter for Edge Functions (per-isolate, resets on cold start)
// For production, use Redis or Supabase table-backed rate limiting

interface RateLimitEntry {
  count: number
  resetAt: number
}

interface LockoutEntry {
  lockedUntil: number
  failedAttempts: number
}

const rateLimitStore = new Map<string, RateLimitEntry>()
const lockoutStore = new Map<string, LockoutEntry>()

// Cleanup old entries every 5 minutes
setInterval(() => {
  const now = Date.now()
  for (const [key, entry] of rateLimitStore.entries()) {
    if (entry.resetAt <= now) {
      rateLimitStore.delete(key)
    }
  }
  for (const [key, entry] of lockoutStore.entries()) {
    if (entry.lockedUntil <= now) {
      lockoutStore.delete(key)
    }
  }
}, 5 * 60 * 1000)

export interface RateLimitConfig {
  windowMs: number    // Time window in milliseconds
  maxRequests: number // Max requests per window
}

export interface LockoutConfig {
  maxAttempts: number      // Max failed attempts before lockout
  lockoutDurationMs: number // Lockout duration in milliseconds
  incrementMs: number      // Additional lockout time per repeated lockout
}

// Default configs
export const AUTH_RATE_LIMIT: RateLimitConfig = {
  windowMs: 60 * 1000,     // 1 minute
  maxRequests: 10,          // 10 requests per minute
}

export const LOGIN_RATE_LIMIT: RateLimitConfig = {
  windowMs: 15 * 60 * 1000, // 15 minutes
  maxRequests: 5,            // 5 login attempts per 15 minutes
}

export const LOGIN_LOCKOUT: LockoutConfig = {
  maxAttempts: 5,            // 5 failed attempts
  lockoutDurationMs: 15 * 60 * 1000, // 15 minutes
  incrementMs: 15 * 60 * 1000,        // +15 min per repeated lockout
}

/**
 * Check if a request is rate-limited
 * Returns null if allowed, or a Response with 429 status if limited
 */
export function checkRateLimit(
  key: string,
  config: RateLimitConfig
): { allowed: boolean; retryAfterMs?: number } {
  const now = Date.now()
  const entry = rateLimitStore.get(key)

  if (!entry || entry.resetAt <= now) {
    // New window
    rateLimitStore.set(key, {
      count: 1,
      resetAt: now + config.windowMs,
    })
    return { allowed: true }
  }

  if (entry.count >= config.maxRequests) {
    return {
      allowed: false,
      retryAfterMs: entry.resetAt - now,
    }
  }

  entry.count++
  return { allowed: true }
}

/**
 * Check if an account is locked out due to failed login attempts
 */
export function checkAccountLockout(
  identifier: string,
  config: LockoutConfig
): { locked: boolean; lockedUntilMs?: number; remainingMs?: number } {
  const now = Date.now()
  const entry = lockoutStore.get(identifier)

  if (!entry || entry.lockedUntil <= now) {
    // Not locked (or lockout expired)
    return { locked: false }
  }

  return {
    locked: true,
    lockedUntilMs: entry.lockedUntil,
    remainingMs: entry.lockedUntil - now,
  }
}

/**
 * Record a failed login attempt
 * Returns true if account is now locked
 */
export function recordFailedLogin(
  identifier: string,
  config: LockoutConfig
): { locked: boolean; lockedUntilMs?: number; attempts: number } {
  const now = Date.now()
  let entry = lockoutStore.get(identifier)

  if (!entry || entry.lockedUntil <= now) {
    entry = { lockedUntil: 0, failedAttempts: 0 }
  }

  entry.failedAttempts++

  if (entry.failedAttempts >= config.maxAttempts) {
    const lockoutDuration = config.lockoutDurationMs +
      (Math.floor(entry.failedAttempts / config.maxAttempts) - 1) * config.incrementMs
    entry.lockedUntil = now + lockoutDuration
    lockoutStore.set(identifier, entry)

    return {
      locked: true,
      lockedUntilMs: entry.lockedUntil,
      attempts: entry.failedAttempts,
    }
  }

  lockoutStore.set(identifier, entry)
  return {
    locked: false,
    attempts: entry.failedAttempts,
  }
}

/**
 * Clear failed login attempts (on successful login)
 */
export function clearFailedLogins(identifier: string): void {
  lockoutStore.delete(identifier)
}

/**
 * Get client IP from request headers
 */
export function getClientIP(req: Request): string {
  return req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ||
    req.headers.get('x-real-ip') ||
    req.headers.get('cf-connecting-ip') ||
    'unknown'
}
