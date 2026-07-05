// supabase/functions/users/index.ts
// Section 8: User APIs
// GET /users/me, PUT /users/me, POST /users/avatar, DELETE /users/me
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  noContentResponse,
  badRequest,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequired, sanitizeString } from '../shared/validator.ts'

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const supabase = authResult.supabaseClient
    const userId = authResult.user.id
    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const action = pathParts[pathParts.length - 1]

    // GET /users/me - Get current user profile
    if (req.method === 'GET' && action === 'me') {
      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('auth_user_id', userId)
        .single()

      if (profileError || !profile) {
        return notFound('User profile not found')
      }

      return successResponse({
        id: profile.id,
        auth_user_id: profile.auth_user_id,
        full_name: profile.full_name,
        avatar_url: profile.avatar_url,
        native_language: profile.native_language,
        target_language: profile.target_language,
        proficiency_level: profile.proficiency_level,
        target_exam: profile.target_exam,
        timezone: profile.timezone,
        onboarding_completed: profile.onboarding_completed,
        xp: profile.xp || 0,
        level: profile.level || 1,
        created_at: profile.created_at,
        updated_at: profile.updated_at,
      }, 'Profile retrieved successfully.')
    }

    // PUT /users/me - Update current user profile
    if (req.method === 'PUT' && action === 'me') {
      const body = await req.json()
      const {
        full_name,
        native_language,
        target_language,
        proficiency_level,
        target_exam,
        timezone,
        onboarding_completed,
      } = body

      const updateData: Record<string, unknown> = {}

      if (full_name !== undefined) {
        const sanitized = sanitizeString(full_name)
        const validation = validateRequired({ full_name: sanitized })
        if (!validation.isValid) {
          return badRequest('Invalid full_name', validation.errors)
        }
        if (sanitized.length > 100) {
          return badRequest('full_name must be 100 characters or less')
        }
        updateData.full_name = sanitized
      }

      if (proficiency_level !== undefined) {
        const validLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
        if (!validLevels.includes(proficiency_level)) {
          return badRequest(`proficiency_level must be one of: ${validLevels.join(', ')}`)
        }
        updateData.proficiency_level = proficiency_level
      }

      if (native_language !== undefined) updateData.native_language = native_language
      if (target_language !== undefined) updateData.target_language = target_language
      if (target_exam !== undefined) updateData.target_exam = target_exam
      if (timezone !== undefined) updateData.timezone = timezone
      if (onboarding_completed !== undefined) updateData.onboarding_completed = onboarding_completed

      if (Object.keys(updateData).length === 0) {
        return badRequest('No fields to update')
      }

      const { data: profile, error: updateError } = await supabase
        .from('user_profiles')
        .update(updateData)
        .eq('auth_user_id', userId)
        .select('*')
        .single()

      if (updateError) {
        console.error('Profile update error:', updateError)
        return serverError('Failed to update profile')
      }

      return successResponse(profile, 'Profile updated successfully.')
    }

    // POST /users/avatar - Upload user avatar
    if (req.method === 'POST' && action === 'avatar') {
      const contentType = req.headers.get('content-type') || ''

      if (!contentType.includes('multipart/form-data')) {
        return badRequest('Content-Type must be multipart/form-data')
      }

      const formData = await req.formData()
      const file = formData.get('avatar') as File | null

      if (!file) {
        return badRequest('No avatar file provided')
      }

      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
      if (!allowedTypes.includes(file.type)) {
        return badRequest('Invalid file type. Allowed: JPEG, PNG, WebP, GIF')
      }

      if (file.size > 5 * 1024 * 1024) {
        return badRequest('File too large. Maximum size is 5MB')
      }

      const { data: currentProfile } = await supabase
        .from('user_profiles')
        .select('id, avatar_url')
        .eq('auth_user_id', userId)
        .single()

      if (!currentProfile) {
        return notFound('User profile not found')
      }

      const fileExt = file.name.split('.').pop() || 'jpg'
      const filePath = `avatars/${currentProfile.id}/${Date.now()}.${fileExt}`

      const arrayBuffer = await file.arrayBuffer()
      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(filePath, arrayBuffer, {
          contentType: file.type,
          upsert: true,
        })

      if (uploadError) {
        console.error('Avatar upload error:', uploadError)
        return serverError('Failed to upload avatar')
      }

      const { data: urlData } = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath)

      if (currentProfile.avatar_url) {
        const oldPath = currentProfile.avatar_url.split('/avatars/')[1]
        if (oldPath) {
          await supabase.storage.from('avatars').remove([oldPath])
        }
      }

      const { error: updateError } = await supabase
        .from('user_profiles')
        .update({ avatar_url: urlData.publicUrl })
        .eq('auth_user_id', userId)

      if (updateError) {
        console.error('Profile avatar update error:', updateError)
        return serverError('Failed to update profile with new avatar')
      }

      return successResponse({
        avatar_url: urlData.publicUrl,
      }, 'Avatar uploaded successfully.')
    }

    // DELETE /users/me - Delete current user account
    if (req.method === 'DELETE' && action === 'me') {
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id, avatar_url')
        .eq('auth_user_id', userId)
        .single()

      if (profile?.avatar_url) {
        const avatarPath = profile.avatar_url.split('/avatars/')[1]
        if (avatarPath) {
          await supabase.storage.from('avatars').remove([avatarPath])
        }
      }

      const { error: deleteError } = await supabase.auth.admin.deleteUser(userId)

      if (deleteError) {
        console.error('Account deletion error:', deleteError)
        return serverError('Failed to delete account')
      }

      return noContentResponse()
    }

    return badRequest('Endpoint not found')
  } catch (error) {
    console.error('Users error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
