// supabase/functions/auth/index.ts
// Section 7: Authentication APIs
// POST /auth/register, /auth/login, /auth/refresh, /auth/logout,
//       /auth/forgot-password, /auth/reset-password, /auth/verify-email
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { corsHeaders } from '../shared/cors.ts'
import {
  successResponse,
  createdResponse,
  badRequest,
  conflict,
  unauthorized,
  forbidden,
  noContentResponse,
  serverError,
  rateLimited,
} from '../shared/errors.ts'
import {
  validateRequired,
  validateEmail,
  validatePassword,
  sanitizeString,
} from '../shared/validator.ts'
import {
  checkRateLimit,
  checkAccountLockout,
  recordFailedLogin,
  clearFailedLogins,
  getClientIP,
  AUTH_RATE_LIMIT,
  LOGIN_RATE_LIMIT,
  LOGIN_LOCKOUT,
} from '../shared/rate-limiter.ts'

// ─── Helpers ────────────────────────────────────────────────────────────────

function getSupabaseClient(authHeader?: string) {
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY') ?? ''

  if (authHeader) {
    return createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } },
    })
  }
  return createClient(supabaseUrl, supabaseKey)
}

function cleanEmail(email: string): string {
  return sanitizeString(email).toLowerCase().trim()
}

function maskEmail(email: string): string {
  const [local, domain] = email.split('@')
  if (!domain) return '***'
  const masked = local.length > 2
    ? local[0] + '***' + local[local.length - 1]
    : '***'
  return `${masked}@${domain}`
}

// ─── Rate Limit Middleware ───────────────────────────────────────────────────

function checkAuthRateLimit(ip: string): Response | null {
  const result = checkRateLimit(`auth:${ip}`, AUTH_RATE_LIMIT)
  if (!result.allowed) {
    return rateLimited(`Too many requests. Retry after ${Math.ceil((result.retryAfterMs || 0) / 1000)} seconds.`)
  }
  return null
}

function checkLoginRateLimit(ip: string, email: string): Response | null {
  const result = checkRateLimit(`login:${ip}:${email}`, LOGIN_RATE_LIMIT)
  if (!result.allowed) {
    return rateLimited(`Too many login attempts. Retry after ${Math.ceil((result.retryAfterMs || 0) / 1000)} seconds.`)
  }
  return null
}

// ─── Handlers ───────────────────────────────────────────────────────────────

async function handleRegister(req: Request): Promise<Response> {
  const body = await req.json()
  const { email, password, name } = body

  // 1. Validate required fields
  const validation = validateRequired({ email, password })
  if (!validation.isValid) {
    return badRequest('Validation failed', validation.errors)
  }

  // 2. Clean and validate email
  const cleanEmailValue = cleanEmail(email)
  if (!validateEmail(cleanEmailValue)) {
    return badRequest('Invalid email format. Please enter a valid email address.')
  }

  // 3. Validate password strength
  const passwordValidation = validatePassword(password)
  if (!passwordValidation.isValid) {
    return badRequest('Password does not meet security requirements', passwordValidation.errors)
  }

  // 4. Clean name input
  const cleanName = name ? sanitizeString(name) : ''

  // 5. Register with Supabase (handles password hashing with bcrypt)
  const supabase = getSupabaseClient()
  const { data, error } = await supabase.auth.signUp({
    email: cleanEmailValue,
    password,
    options: {
      data: { full_name: cleanName },
    },
  })

  // 6. Handle errors with generic messages (prevent email enumeration)
  if (error) {
    if (error.message.includes('already registered') || error.message.includes('already been registered')) {
      // Return success to prevent email enumeration
      return successResponse(
        null,
        'If this email is not already registered, a verification link has been sent.',
      )
    }
    console.error('Registration error:', error.message)
    return serverError('Registration failed. Please try again later.')
  }

  return createdResponse(
    {
      user: data.user
        ? {
            id: data.user.id,
            email: data.user.email,
            name: data.user.user_metadata?.full_name,
          }
        : null,
      session: data.session
        ? {
            access_token: data.session.access_token,
            refresh_token: data.session.refresh_token,
            expires_in: data.session.expires_in,
            expires_at: data.session.expires_at,
          }
        : null,
    },
    'Registration successful. Please check your email for verification.',
  )
}

async function handleLogin(req: Request): Promise<Response> {
  const ip = getClientIP(req)
  const body = await req.json()
  const { email, password } = body

  // ── 1. Validate required fields ──────────────────────────────────────────
  const validation = validateRequired({ email, password })
  if (!validation.isValid) {
    return badRequest('Email and password are required.')
  }

  // ── 2. Clean and validate email ──────────────────────────────────────────
  const cleanEmailValue = cleanEmail(email)
  if (!validateEmail(cleanEmailValue)) {
    // Use generic message to prevent email enumeration
    return unauthorized('Invalid email or password.')
  }

  // ── 3. Check IP-based rate limiting ──────────────────────────────────────
  const ipRateLimit = checkLoginRateLimit(ip, cleanEmailValue)
  if (ipRateLimit) return ipRateLimit

  // ── 4. Check account lockout ─────────────────────────────────────────────
  const lockout = checkAccountLockout(cleanEmailValue, LOGIN_LOCKOUT)
  if (lockout.locked) {
    const remainingMinutes = Math.ceil((lockout.remainingMs || 0) / 60000)
    return forbidden(
      `Account temporarily locked due to too many failed attempts. Try again in ${remainingMinutes} minute${remainingMinutes > 1 ? 's' : ''}.`
    )
  }

  // ── 5. Authenticate with Supabase ────────────────────────────────────────
  // Supabase handles password verification using bcrypt internally
  const supabase = getSupabaseClient()
  const { data, error } = await supabase.auth.signInWithPassword({
    email: cleanEmailValue,
    password,
  })

  // ── 6. Handle authentication errors ──────────────────────────────────────
  if (error) {
    // Record failed attempt
    const lockoutResult = recordFailedLogin(cleanEmailValue, LOGIN_LOCKOUT)

    // NEVER reveal whether the email exists or the password was wrong
    if (error.message.includes('Invalid login') ||
        error.message.includes('invalid') ||
        error.message.includes('password') ||
        error.message.includes('Email not confirmed') ||
        error.message.includes('email not confirmed')) {

      if (lockoutResult.locked) {
        const remainingMinutes = Math.ceil(
          ((lockoutResult.lockedUntilMs || 0) - Date.now()) / 60000
        )
        return forbidden(
          `Account locked due to ${lockoutResult.attempts} failed attempts. Try again in ${remainingMinutes} minute${remainingMinutes > 1 ? 's' : ''}.`
        )
      }

      // Generic message - never reveal if email exists or password was wrong
      const remainingAttempts = LOGIN_LOCKOUT.maxAttempts - lockoutResult.attempts
      const attemptsMessage = remainingAttempts <= 2
        ? ` ${remainingAttempts} attempt${remainingAttempts !== 1 ? 's' : ''} remaining before account lockout.`
        : ''

      return unauthorized(`Invalid email or password.${attemptsMessage}`)
    }

    console.error('Login error:', error.message)
    return serverError('Login failed. Please try again later.')
  }

  // ── 7. Clear failed attempts on successful login ─────────────────────────
  clearFailedLogins(cleanEmailValue)

  // ── 8. Return success ────────────────────────────────────────────────────
  return successResponse(
    {
      user: {
        id: data.user.id,
        email: data.user.email,
        name: data.user.user_metadata?.full_name,
      },
      session: {
        access_token: data.session.access_token,
        refresh_token: data.session.refresh_token,
        expires_in: data.session.expires_in,
        expires_at: data.session.expires_at,
      },
    },
    'Login successful.',
  )
}

async function handleRefresh(req: Request): Promise<Response> {
  const body = await req.json()
  const { refresh_token } = body

  const validation = validateRequired({ refresh_token })
  if (!validation.isValid) {
    return badRequest('Refresh token is required.')
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase.auth.refreshSession({
    refresh_token,
  })

  if (error) {
    return badRequest('Invalid or expired refresh token.')
  }

  return successResponse(
    {
      session: {
        access_token: data.session?.access_token,
        refresh_token: data.session?.refresh_token,
        expires_in: data.session?.expires_in,
        expires_at: data.session?.expires_at,
      },
    },
    'Token refreshed successfully.',
  )
}

async function handleLogout(req: Request): Promise<Response> {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return noContentResponse()
  }

  const supabase = getSupabaseClient(authHeader)
  const { error } = await supabase.auth.signOut()
  if (error) {
    console.error('Logout error:', error)
  }

  return noContentResponse()
}

async function handleForgotPassword(req: Request): Promise<Response> {
  const ip = getClientIP(req)
  const body = await req.json()
  const { email } = body

  // Rate limit password reset requests
  const rateLimit = checkRateLimit(`forgot-pw:${ip}`, {
    windowMs: 60 * 1000,
    maxRequests: 3,
  })
  if (!rateLimit.allowed) {
    return rateLimited('Too many password reset requests. Please wait before trying again.')
  }

  const validation = validateRequired({ email })
  if (!validation.isValid) {
    return badRequest('Email is required.')
  }

  const cleanEmailValue = cleanEmail(email)
  if (!validateEmail(cleanEmailValue)) {
    // Always return success to prevent email enumeration
    return successResponse(
      null,
      'If the email exists, a password reset link has been sent.',
    )
  }

  const supabase = getSupabaseClient()
  const { error } = await supabase.auth.resetPasswordForEmail(cleanEmailValue, {
    redirectTo: `${Deno.env.get('APP_URL') || 'https://ailanguagecoach.com'}/reset-password`,
  })

  if (error) {
    console.error('Forgot password error:', error)
  }

  // Always return success to prevent email enumeration
  return successResponse(
    null,
    'If the email exists, a password reset link has been sent.',
  )
}

async function handleResetPassword(req: Request): Promise<Response> {
  const body = await req.json()
  const { access_token, refresh_token, new_password } = body

  const validation = validateRequired({ access_token, new_password })
  if (!validation.isValid) {
    return badRequest('Token and new password are required.')
  }

  // Validate new password strength
  const passwordValidation = validatePassword(new_password)
  if (!passwordValidation.isValid) {
    return badRequest('New password does not meet security requirements', passwordValidation.errors)
  }

  const supabase = getSupabaseClient()

  if (refresh_token) {
    const { error: sessionError } = await supabase.auth.setSession({
      access_token,
      refresh_token,
    })
    if (sessionError) {
      return badRequest('Invalid or expired token.')
    }
  }

  const { error } = await supabase.auth.updateUser({
    password: new_password,
  })

  if (error) {
    console.error('Reset password error:', error.message)
    return serverError('Password reset failed. Please request a new reset link.')
  }

  return successResponse(
    null,
    'Password reset successful. You can now log in with your new password.',
  )
}

async function handleVerifyEmail(req: Request): Promise<Response> {
  const body = await req.json()
  const { token, type } = body

  const validation = validateRequired({ token })
  if (!validation.isValid) {
    return badRequest('Verification token is required.')
  }

  const supabase = getSupabaseClient()
  const { error } = await supabase.auth.verifyOtp({
    token,
    type: (type as any) || 'signup',
  })

  if (error) {
    return badRequest('Invalid or expired verification token.')
  }

  return successResponse(null, 'Email verified successfully.')
}

// ─── Router ─────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const ip = getClientIP(req)

  // Global rate limit for all auth endpoints
  const globalRateLimit = checkAuthRateLimit(ip)
  if (globalRateLimit) return globalRateLimit

  const url = new URL(req.url)
  const path = url.pathname.split('/').pop() || ''

  try {
    // Method validation for all endpoints
    if (req.method !== 'POST') {
      return badRequest(`Method ${req.method} not allowed. Use POST.`)
    }

    switch (path) {
      case 'register':
        return await handleRegister(req)
      case 'login':
        return await handleLogin(req)
      case 'refresh':
        return await handleRefresh(req)
      case 'logout':
        return await handleLogout(req)
      case 'forgot-password':
        return await handleForgotPassword(req)
      case 'reset-password':
        return await handleResetPassword(req)
      case 'verify-email':
        return await handleVerifyEmail(req)
      default:
        return badRequest(`Unknown auth endpoint: ${path}`)
    }
  } catch (error) {
    console.error('Auth error:', error)
    return serverError('An unexpected error occurred. Please try again later.')
  }
})
