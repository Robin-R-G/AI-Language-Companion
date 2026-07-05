// supabase/functions/user-profile/index.ts
// Section 8: User APIs
// GET /users/me, PUT /users/me, POST /users/avatar, DELETE /users/me
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  noContentResponse,
  badRequest,
  validationError,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { validateString } from '../shared/validator.ts'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
      },
    })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const supabase = authResult.supabaseClient
    const userId = authResult.user.id

    // GET /users/me
    if (req.method === 'GET') {
      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('auth_user_id', userId)
        .single()

      if (profileError || !profile) {
        return notFound('User profile not found')
      }

      // Fetch additional data in parallel
      const [goalsResult, progressResult, streaksResult] = await Promise.all([
        supabase
          .from('user_goals')
          .select('*')
          .eq('user_id', profile.id)
          .single(),
        supabase
          .from('user_progress')
          .select('*')
          .eq('user_id', userId)
          .single(),
        supabase
          .from('streaks')
          .select('*')
          .eq('user_id', userId)
          .single(),
      ])

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
        xp: progressResult.data?.xp || profile.xp || 0,
        level: progressResult.data?.level || profile.level || 1,
        streak: streaksResult.data?.current_streak || 0,
        goals: goalsResult.data || null,
        created_at: profile.created_at,
        updated_at: profile.updated_at,
      }, 'Profile retrieved successfully.')
    }

    // PUT /users/me
    if (req.method === 'PUT') {
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

      // Validate optional fields if provided
      if (full_name !== undefined) {
        const nameValidation = validateString(full_name, 'full_name', { minLength: 1, maxLength: 100 })
        if (!nameValidation.isValid) {
          return validationError('Invalid full_name', nameValidation.errors)
        }
      }

      if (proficiency_level !== undefined) {
        const validLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
        if (!validLevels.includes(proficiency_level)) {
          return validationError('Invalid proficiency_level', [
            `Must be one of: ${validLevels.join(', ')}`,
          ])
        }
      }

      const updateData: Record<string, any> = {}
      if (full_name !== undefined) updateData.full_name = full_name
      if (native_language !== undefined) updateData.native_language = native_language
      if (target_language !== undefined) updateData.target_language = target_language
      if (proficiency_level !== undefined) updateData.proficiency_level = proficiency_level
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

    // POST /users/avatar
    if (req.method === 'POST') {
      const contentType = req.headers.get('content-type') || ''

      if (!contentType.includes('multipart/form-data')) {
        return badRequest('Content-Type must be multipart/form-data')
      }

      const formData = await req.formData()
      const file = formData.get('avatar') as File | null

      if (!file) {
        return badRequest('No avatar file provided')
      }

      // Validate file type
      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
      if (!allowedTypes.includes(file.type)) {
        return validationError('Invalid file type', [
          'Allowed types: JPEG, PNG, WebP, GIF',
        ])
      }

      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        return validationError('File too large', ['Maximum size is 5MB'])
      }

      // Get current profile to find existing avatar
      const { data: currentProfile } = await supabase
        .from('user_profiles')
        .select('id, avatar_url')
        .eq('auth_user_id', userId)
        .single()

      if (!currentProfile) {
        return notFound('User profile not found')
      }

      // Upload new avatar
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

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath)

      // Delete old avatar if exists
      if (currentProfile.avatar_url) {
        const oldPath = currentProfile.avatar_url.split('/avatars/')[1]
        if (oldPath) {
          await supabase.storage.from('avatars').remove([oldPath])
        }
      }

      // Update profile with new avatar URL
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

    // DELETE /users/me
    if (req.method === 'DELETE') {
      // Delete user data in reverse dependency order
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single()

      if (profile) {
        // Delete avatar from storage
        const { data: avatarData } = await supabase
          .from('user_profiles')
          .select('avatar_url')
          .eq('auth_user_id', userId)
          .single()

        if (avatarData?.avatar_url) {
          const avatarPath = avatarData.avatar_url.split('/avatars/')[1]
          if (avatarPath) {
            await supabase.storage.from('avatars').remove([avatarPath])
          }
        }
      }

      // Delete user from Supabase Auth (this will cascade via RLS)
      const { error: deleteError } = await supabase.auth.admin.deleteUser(userId)

      if (deleteError) {
        console.error('Account deletion error:', deleteError)
        return serverError('Failed to delete account')
      }

      return noContentResponse()
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('User profile error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
