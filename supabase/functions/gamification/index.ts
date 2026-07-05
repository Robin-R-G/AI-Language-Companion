// supabase/functions/gamification/index.ts
// Section 21: Gamification APIs
// GET /xp, GET /badges, GET /achievements, GET /leaderboard
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  notFound,
  serverError,
} from '../shared/errors.ts'
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
    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const action = pathParts[pathParts.length - 1]

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('auth_user_id', userId)
      .single()

    if (!profile) {
      return notFound('User profile not found')
    }

    // GET /xp - Get XP and level info
    if (action === 'xp') {
      const { data: progress } = await supabase
        .from('user_progress')
        .select('xp, level')
        .eq('user_id', userId)
        .single()

      const xp = progress?.xp || 0
      const level = progress?.level || 1
      const xpForNextLevel = level * 500
      const xpProgress = xp % 500
      const progressPercent = Math.round((xpProgress / 500) * 100)

      return successResponse({
        total_xp: xp,
        level,
        xp_for_next_level: xpForNextLevel,
        xp_progress: xpProgress,
        progress_percent: progressPercent,
      }, 'XP data retrieved.')
    }

    // GET /badges - Get earned badges
    if (action === 'badges') {
      const { data: achievements } = await supabase
        .from('achievements')
        .select('*')
        .eq('user_id', userId)
        .order('unlocked_at', { ascending: false })

      const allBadges = [
        { id: 'first_steps', name: 'First Steps', description: 'Earn 100 XP', icon: '🌟', requirement: 100 },
        { id: 'week_warrior', name: 'Week Warrior', description: '7-day streak', icon: '🔥', requirement: 7 },
        { id: 'word_wizard', name: 'Word Wizard', description: 'Learn 50 words', icon: '📚', requirement: 50 },
        { id: 'grammar_guru', name: 'Grammar Guru', description: 'Complete 10 grammar lessons', icon: '✍️', requirement: 10 },
        { id: 'voice_virtuoso', name: 'Voice Virtuoso', description: 'Complete 20 voice sessions', icon: '🎤', requirement: 20 },
        { id: 'reading_champion', name: 'Reading Champion', description: 'Complete 15 reading exercises', icon: '📖', requirement: 15 },
        { id: 'exam_ready', name: 'Exam Ready', description: 'Score 80% on mock exam', icon: '🎯', requirement: 80 },
        { id: 'level_up', name: 'Level Up', description: 'Reach level 5', icon: '⬆️', requirement: 5 },
        { id: 'streak_master', name: 'Streak Master', description: '30-day streak', icon: '💪', requirement: 30 },
        { id: 'polyglot', name: 'Polyglot', description: 'Study 3 languages', icon: '🌍', requirement: 3 },
      ]

      const earned = achievements || []
      const earnedIds = earned.map((a: any) => a.achievement_name?.toLowerCase().replace(/\s+/g, '_'))

      const badges = allBadges.map((b) => ({
        ...b,
        earned: earnedIds.includes(b.id),
        unlocked_at: earned.find((e: any) => e.achievement_name?.toLowerCase().replace(/\s+/g, '_') === b.id)?.unlocked_at,
      }))

      return successResponse({
        badges,
        total_earned: earned.length,
        total_available: allBadges.length,
      }, 'Badges retrieved.')
    }

    // GET /achievements - Get all achievements with details
    if (action === 'achievements') {
      const { data: achievements } = await supabase
        .from('achievements')
        .select('*')
        .eq('user_id', userId)
        .order('unlocked_at', { ascending: false })

      // Check for new achievements
      const { data: progress } = await supabase
        .from('user_progress')
        .select('xp, vocabulary_score')
        .eq('user_id', userId)
        .single()

      const { data: streaks } = await supabase
        .from('streaks')
        .select('current_streak')
        .eq('user_id', userId)
        .single()

      const { data: lessons } = await supabase
        .from('lesson_progress')
        .select('id')
        .eq('user_id', profile.id)

      const newAchievements: any[] = []
      const existingNames = (achievements || []).map((a: any) => a.achievement_name)

      if ((progress?.xp || 0) >= 100 && !existingNames.includes('First Steps')) {
        newAchievements.push({
          user_id: userId,
          achievement_name: 'First Steps',
          badge: '🌟',
          xp_reward: 50,
        })
      }

      if ((streaks?.current_streak || 0) >= 7 && !existingNames.includes('Week Warrior')) {
        newAchievements.push({
          user_id: userId,
          achievement_name: 'Week Warrior',
          badge: '🔥',
          xp_reward: 100,
        })
      }

      if ((lessons?.length || 0) >= 10 && !existingNames.includes('Grammar Guru')) {
        newAchievements.push({
          user_id: userId,
          achievement_name: 'Grammar Guru',
          badge: '✍️',
          xp_reward: 75,
        })
      }

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
      }, 'Achievements retrieved.')
    }

    // GET /leaderboard - Get leaderboard
    if (action === 'leaderboard') {
      const period = url.searchParams.get('period') || 'weekly'
      const limit = parseInt(url.searchParams.get('limit') || '20')

      // Get top users by XP
      const { data: topUsers, error } = await supabase
        .from('user_progress')
        .select('user_id, xp, level')
        .order('xp', { ascending: false })
        .limit(limit)

      if (error) {
        console.error('Leaderboard error:', error)
        return serverError('Failed to fetch leaderboard')
      }

      // Get user profiles for the top users
      const userIds = (topUsers || []).map((u: any) => u.user_id)
      const { data: profiles } = await supabase
        .from('user_profiles')
        .select('auth_user_id, full_name, avatar_url')
        .in('auth_user_id', userIds)

      const profileMap = new Map((profiles || []).map((p: any) => [p.auth_user_id, p]))

      const leaderboard = (topUsers || []).map((u: any, index: number) => {
        const profile = profileMap.get(u.user_id)
        return {
          rank: index + 1,
          user_id: u.user_id,
          name: profile?.full_name || 'Anonymous',
          avatar_url: profile?.avatar_url,
          xp: u.xp || 0,
          level: u.level || 1,
          is_current_user: u.user_id === userId,
        }
      })

      // Get current user's rank
      const { count: totalUsers } = await supabase
        .from('user_progress')
        .select('*', { count: 'exact', head: true })
        .gt('xp', progress?.xp || 0)

      return successResponse({
        leaderboard,
        user_rank: (totalUsers || 0) + 1,
        period,
      }, 'Leaderboard retrieved.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Gamification error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
