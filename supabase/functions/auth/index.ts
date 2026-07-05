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
  noContentResponse,
  serverError,
} from '../shared/errors.ts'
import {
  validateRequired,
  validateEmail,
  validatePassword,
  sanitizeString,
} from '../shared/validator.ts'

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

async function handleRegister(req: Request): Promise<Response> {
  const body = await req.json()
  const { email, password, name } = body

  const validation = validateRequired({ email, password })
  if (!validation.isValid) {
    return badRequest('Validation failed', validation.errors)
  }

  if (!validateEmail(email)) {
    return badRequest('Invalid email format')
  }

  const passwordValidation = validatePassword(password)
  if (!passwordValidation.isValid) {
    return badRequest('Password validation failed', passwordValidation.errors)
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase.auth.signUp({
    email: sanitizeString(email),
    password,
    options: {
      data: { full_name: name ? sanitizeString(name) : '' },
    },
  })

  if (error) {
    if (error.message.includes('already registered')) {
      return conflict('Email already registered')
    }
    return serverError(error.message)
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
  const body = await req.json()
  const { email, password } = body

  const validation = validateRequired({ email, password })
  if (!validation.isValid) {
    return badRequest('Validation failed', validation.errors)
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    if (error.message.includes('Invalid login')) {
      return unauthorized('Invalid email or password')
    }
    return serverError(error.message)
  }

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
    return badRequest('Validation failed', validation.errors)
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase.auth.refreshSession({
    refresh_token,
  })

  if (error) {
    return badRequest('Invalid or expired refresh token')
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
  const body = await req.json()
  const { email } = body

  const validation = validateRequired({ email })
  if (!validation.isValid) {
    return badRequest('Validation failed', validation.errors)
  }

  if (!validateEmail(email)) {
    return badRequest('Invalid email format')
  }

  const supabase = getSupabaseClient()
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${Deno.env.get('APP_URL') || 'https://ailanguagecoach.com'}/reset-password`,
  })

  if (error) {
    console.error('Forgot password error:', error)
  }

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
    return badRequest('Validation failed', validation.errors)
  }

  const passwordValidation = validatePassword(new_password)
  if (!passwordValidation.isValid) {
    return badRequest('Password validation failed', passwordValidation.errors)
  }

  const supabase = getSupabaseClient()

  if (refresh_token) {
    const { error: sessionError } = await supabase.auth.setSession({
      access_token,
      refresh_token,
    })
    if (sessionError) {
      return badRequest('Invalid or expired token')
    }
  }

  const { error } = await supabase.auth.updateUser({
    password: new_password,
  })

  if (error) {
    return serverError(error.message)
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
    return badRequest('Validation failed', validation.errors)
  }

  const supabase = getSupabaseClient()
  const { error } = await supabase.auth.verifyOtp({
    token,
    type: (type as any) || 'signup',
  })

  if (error) {
    return badRequest('Invalid or expired verification token')
  }

  return successResponse(null, 'Email verified successfully.')
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const url = new URL(req.url)
  const path = url.pathname.split('/').pop() || ''

  try {
    switch (path) {
      case 'register':
        if (req.method !== 'POST') return badRequest('Method not allowed')
        return await handleRegister(req)

      case 'login':
        if (req.method !== 'POST') return badRequest('Method not allowed')
        return await handleLogin(req)

      case 'refresh':
        if (req.method !== 'POST') return badRequest('Method not allowed')
        return await handleRefresh(req)

      case 'logout':
        if (req.method !== 'POST') return badRequest('Method not allowed')
        return await handleLogout(req)

      case 'forgot-password':
        if (req.method !== 'POST') return badRequest('Method not allowed')
        return await handleForgotPassword(req)

      case 'reset-password':
        if (req.method !== 'POST') return badRequest('Method not allowed')
        return await handleResetPassword(req)

      case 'verify-email':
        if (req.method !== 'POST') return badRequest('Method not allowed')
        return await handleVerifyEmail(req)

      default:
        return badRequest(`Unknown auth endpoint: ${path}`)
    }
  } catch (error) {
    console.error('Auth error:', error)
    return serverError(error instanceof Error ? error.message : 'Internal server error')
  }
})
