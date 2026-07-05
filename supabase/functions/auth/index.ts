// supabase/functions/auth/index.ts
// Section 7: Authentication APIs
// POST /auth/register, /auth/login, /auth/refresh, /auth/logout,
//       /auth/forgot-password, /auth/reset-password, /auth/verify-email
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { corsHeaders } from '../shared/cors.ts'
import {
  successResponse,
  createdResponse,
  badRequest,
  validationError,
  serverError,
} from '../shared/errors.ts'
import { validateRequired, validateString } from '../shared/validator.ts'

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

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const url = new URL(req.url)
  const path = url.pathname.split('/').pop() || ''

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization') || undefined)

    switch (path) {
      case 'register': {
        if (req.method !== 'POST') return badRequest('Method not allowed')

        const body = await req.json()
        const { email, password, name } = body

        const validation = validateRequired({ email, password })
        if (!validation.isValid) {
          return validationError('Validation failed', validation.errors)
        }

        const emailValidation = validateString(email, 'email', {
          pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
        })
        if (!emailValidation.isValid) {
          return validationError('Invalid email format', emailValidation.errors)
        }

        const passwordValidation = validateString(password, 'password', { minLength: 8 })
        if (!passwordValidation.isValid) {
          return validationError('Password too short', passwordValidation.errors)
        }

        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: { full_name: name || '' },
          },
        })

        if (error) {
          if (error.message.includes('already registered')) {
            return badRequest('Email already registered')
          }
          return serverError(error.message)
        }

        return createdResponse({
          user: data.user ? {
            id: data.user.id,
            email: data.user.email,
            name: data.user.user_metadata?.full_name,
          } : null,
          session: data.session ? {
            access_token: data.session.access_token,
            refresh_token: data.session.refresh_token,
            expires_in: data.session.expires_in,
            expires_at: data.session.expires_at,
          } : null,
        }, 'Registration successful. Please check your email for verification.')
      }

      case 'login': {
        if (req.method !== 'POST') return badRequest('Method not allowed')

        const body = await req.json()
        const { email, password } = body

        const validation = validateRequired({ email, password })
        if (!validation.isValid) {
          return validationError('Validation failed', validation.errors)
        }

        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })

        if (error) {
          if (error.message.includes('Invalid login')) {
            return badRequest('Invalid email or password')
          }
          return serverError(error.message)
        }

        return successResponse({
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
        }, 'Login successful.')
      }

      case 'refresh': {
        if (req.method !== 'POST') return badRequest('Method not allowed')

        const body = await req.json()
        const { refresh_token } = body

        const validation = validateRequired({ refresh_token })
        if (!validation.isValid) {
          return validationError('Validation failed', validation.errors)
        }

        const { data, error } = await supabase.auth.refreshSession({
          refresh_token,
        })

        if (error) {
          return badRequest('Invalid or expired refresh token')
        }

        return successResponse({
          session: {
            access_token: data.session?.access_token,
            refresh_token: data.session?.refresh_token,
            expires_in: data.session?.expires_in,
            expires_at: data.session?.expires_at,
          },
        }, 'Token refreshed successfully.')
      }

      case 'logout': {
        if (req.method !== 'POST') return badRequest('Method not allowed')

        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
          return successResponse(null, 'Logged out successfully.')
        }

        const { error } = await supabase.auth.signOut()
        if (error) {
          console.error('Logout error:', error)
        }

        return successResponse(null, 'Logged out successfully.')
      }

      case 'forgot-password': {
        if (req.method !== 'POST') return badRequest('Method not allowed')

        const body = await req.json()
        const { email } = body

        const validation = validateRequired({ email })
        if (!validation.isValid) {
          return validationError('Validation failed', validation.errors)
        }

        const { error } = await supabase.auth.resetPasswordForEmail(email, {
          redirectTo: `${Deno.env.get('APP_URL') || 'https://ailanguagecoach.com'}/reset-password`,
        })

        if (error) {
          console.error('Forgot password error:', error)
        }

        // Always return success to prevent email enumeration
        return successResponse(null, 'If the email exists, a password reset link has been sent.')
      }

      case 'reset-password': {
        if (req.method !== 'POST') return badRequest('Method not allowed')

        const body = await req.json()
        const { access_token, refresh_token, new_password } = body

        const validation = validateRequired({ access_token, new_password })
        if (!validation.isValid) {
          return validationError('Validation failed', validation.errors)
        }

        const passwordValidation = validateString(new_password, 'new_password', { minLength: 8 })
        if (!passwordValidation.isValid) {
          return validationError('Password too short', passwordValidation.errors)
        }

        // If refresh_token is provided, use it to set the session
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

        return successResponse(null, 'Password reset successful. You can now log in with your new password.')
      }

      case 'verify-email': {
        if (req.method !== 'POST') return badRequest('Method not allowed')

        const body = await req.json()
        const { token, type } = body

        const validation = validateRequired({ token })
        if (!validation.isValid) {
          return validationError('Validation failed', validation.errors)
        }

        const { error } = await supabase.auth.verifyOtp({
          token,
          type: (type as any) || 'signup',
        })

        if (error) {
          return badRequest('Invalid or expired verification token')
        }

        return successResponse(null, 'Email verified successfully.')
      }

      default:
        return badRequest(`Unknown auth endpoint: ${path}`)
    }
  } catch (error) {
    console.error('Auth error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
