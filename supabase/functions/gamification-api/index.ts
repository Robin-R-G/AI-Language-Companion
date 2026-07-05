// supabase/functions/gamification-api/index.ts
// Gamification API endpoints
// GET /xp, GET /badges, GET /achievements, GET /leaderboard
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { successResponse, badRequest, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { parsePagination } from '../shared/validator.ts'

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

    // Resolve internal profile ID
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('auth_user_id', userId)
      .single()

    if (!profile) {
      return badRequest('User profile not found')
    }

    // GET /xp - Get XP balance, level, and recent transactions
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

      const { data: transactions } = await supabase
        .from('xp_transactions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(20)

      return successResponse({
        total_xp: xp,
        level,
        xp_for_next_level: xpForNextLevel,
        xp_progress: xpProgress,
        progress_percent: progressPercent,
        recent_transactions: transactions || [],
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

      const earnedIds = (achievements || []).map((a: any) =>
        a.achievement_name?.toLowerCase().replace(/\s+/g, '_')
      )

      const badges = allBadges.map((b) => ({
        ...b,
        earned: earnedIds.includes(b.id),
        unlocked_at: (achievements || []).find(
          (e: any) => e.achievement_name?.toLowerCase().replace(/\s+/g, '_') === b.id
        )?.unlocked_at,
      }))

      return successResponse({
        badges,
        total_earned: achievements?.length || 0,
        total_available: allBadges.length,
      }, 'Badges retrieved.')
    }

    // GET /achievements - Get all achievements with unlock status
    if (action === 'achievements') {
      const { data: achievements } = await supabase
        .from('achievements')
        .select('*')
        .eq('user_id', userId)
        .order('unlocked_at', { ascending: false })

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

      if ((progress?.vocabulary_score || 0) >= 50 && !existingNames.includes('Word Wizard')) {
        newAchievements.push({
          user_id: userId,
          achievement_name: 'Word Wizard',
          badge: '📚',
          xp_reward: 75,
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

    // GET /leaderboard - Get leaderboard by period
    if (action === 'leaderboard') {
      const period = url.searchParams.get('period') || 'weekly'
      const validPeriods = ['daily', 'weekly', 'monthly', 'all_time']
      if (!validPeriods.includes(period)) {
        return badRequest(`Invalid period. Must be one of: ${validPeriods.join(', ')}`)
      }

      const { limit, offset } = parsePagination(url.searchParams)

      let dateFilter: string | null = null
      const now = new Date()
      if (period === 'daily') {
        const start = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        dateFilter = start.toISOString()
      } else if (period === 'weekly') {
        const start = new Date(now)
        start.setDate(now.getDate() - 7)
        dateFilter = start.toISOString()
      } else if (period === 'monthly') {
        const start = new Date(now)
        start.setMonth(now.getMonth() - 1)
        dateFilter = start.toISOString()
      }

      let query = supabase
        .from('user_progress')
        .select('user_id, xp, level')

      if (dateFilter && period !== 'all_time') {
        query = query.gte('updated_at', dateFilter)
      }

      const { data: topUsers, error } = await query
        .order('xp', { ascending: false })
        .range(offset, offset + limit - 1)

      if (error) {
        console.error('Leaderboard query error:', error)
        return serverError('Failed to fetch leaderboard')
      }

      const userIds = (topUsers || []).map((u: any) => u.user_id)
      const { data: profiles } = await supabase
        .from('user_profiles')
        .select('auth_user_id, full_name, avatar_url')
        .in('auth_user_id', userIds)

      const profileMap = new Map((profiles || []).map((p: any) => [p.auth_user_id, p]))

      const leaderboard = (topUsers || []).map((u: any, index: number) => {
        const prof = profileMap.get(u.user_id)
        return {
          rank: offset + index + 1,
          user_id: u.user_id,
          name: prof?.full_name || 'Anonymous',
          avatar_url: prof?.avatar_url,
          xp: u.xp || 0,
          level: u.level || 1,
          is_current_user: u.user_id === userId,
        }
      })

      // Get current user's total rank
      const { data: currentUserProgress } = await supabase
        .from('user_progress')
        .select('xp')
        .eq('user_id', userId)
        .single()

      let userRank = null
      if (currentUserProgress) {
        let rankQuery = supabase
          .from('user_progress')
          .select('*', { count: 'exact', head: true })
          .gt('xp', currentUserProgress.xp || 0)

        if (dateFilter && period !== 'all_time') {
          rankQuery = rankQuery.gte('updated_at', dateFilter)
        }

        const { count: higherCount } = await rankQuery
        userRank = (higherCount || 0) + 1
      }

      return successResponse({
        leaderboard,
        user_rank: userRank,
        period,
        pagination: { limit, offset },
      }, 'Leaderboard retrieved.')
    }

    return badRequest('Invalid endpoint. Use GET /xp, /badges, /achievements, or /leaderboard')
  } catch (error) {
    console.error('Gamification API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
