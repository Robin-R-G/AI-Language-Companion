// supabase/functions/achievements/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const supabase = authResult.supabaseClient
    const userId = authResult.user.id

    // Get user achievements
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('auth_user_id', userId)
      .single()

    if (!profile) {
      return badRequest('User profile not found')
    }

    const { data: achievements } = await supabase
      .from('achievements')
      .select('*')
      .eq('user_id', userId)
      .order('unlocked_at', { ascending: false })

    // Check for new achievements based on user progress
    const { data: progress } = await supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', userId)
      .single()

    const { data: streaks } = await supabase
      .from('streaks')
      .select('*')
      .eq('user_id', userId)
      .single()

    const newAchievements: any[] = []

    if (progress?.xp >= 100 && !achievements?.find((a: any) => a.achievement_name === 'First Steps')) {
      newAchievements.push({
        user_id: userId,
        achievement_name: 'First Steps',
        badge: '🌟',
        xp_reward: 50,
      })
    }

    if (streaks?.current_streak >= 7 && !achievements?.find((a: any) => a.achievement_name === 'Week Warrior')) {
      newAchievements.push({
        user_id: userId,
        achievement_name: 'Week Warrior',
        badge: '🔥',
        xp_reward: 100,
      })
    }

    if (progress?.vocabulary_score >= 50 && !achievements?.find((a: any) => a.achievement_name === 'Word Wizard')) {
      newAchievements.push({
        user_id: userId,
        achievement_name: 'Word Wizard',
        badge: '📚',
        xp_reward: 75,
      })
    }

    // Insert new achievements
    if (newAchievements.length > 0) {
      await supabase.from('achievements').insert(newAchievements)
    }

    // Fetch updated list
    const { data: updatedAchievements } = await supabase
      .from('achievements')
      .select('*')
      .eq('user_id', userId)
      .order('unlocked_at', { ascending: false })

    return successResponse({
      achievements: updatedAchievements || [],
      new_unlocks: newAchievements.length,
    }, 'Achievements loaded')
  } catch (error) {
    console.error('Achievements error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
