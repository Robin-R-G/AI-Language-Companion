// supabase/functions/admin/index.ts
// Section 25: Admin APIs
// /admin/users, /admin/content, /admin/reports, /admin/analytics, /admin/logs
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  badRequest,
  forbidden,
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

    // Check admin privileges via user_profiles table
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('role')
      .eq('auth_user_id', userId)
      .single()

    if (profileError || !profile) {
      return forbidden('User profile not found')
    }

    const userRole = profile.role
    if (userRole !== 'admin' && userRole !== 'super_admin') {
      return forbidden('Admin access required')
    }

    // GET /admin/users - List all users
    if (req.method === 'GET' && action === 'users') {
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '20')
      const search = url.searchParams.get('search')

      let query = supabase
        .from('user_profiles')
        .select('id, full_name, avatar_url, native_language, target_language, proficiency_level, created_at', { count: 'exact' })

      if (search) {
        query = query.ilike('full_name', `%${search}%`)
      }

      const { data: users, error, count } = await query
        .order('created_at', { ascending: false })
        .range((page - 1) * limit, page * limit - 1)

      if (error) {
        console.error('Admin users error:', error)
        return serverError('Failed to fetch users')
      }

      const total = count || 0
      return successResponse({
        users: users || [],
        pagination: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Users retrieved.')
    }

    // GET /admin/content - List content (lessons, vocabulary)
    if (req.method === 'GET' && action === 'content') {
      const type = url.searchParams.get('type') || 'lessons'
      const page = parseInt(url.searchParams.get('page') || '1')
      const limit = parseInt(url.searchParams.get('limit') || '20')

      let data: any[] = []
      let total = 0

      if (type === 'lessons') {
        const result = await supabase
          .from('lessons')
          .select('*', { count: 'exact' })
          .order('created_at', { ascending: false })
          .range((page - 1) * limit, page * limit - 1)

        data = result.data || []
        total = result.count || 0
      } else if (type === 'vocabulary') {
        const result = await supabase
          .from('vocabulary')
          .select('*', { count: 'exact' })
          .order('word', { ascending: true })
          .range((page - 1) * limit, page * limit - 1)

        data = result.data || []
        total = result.count || 0
      }

      return successResponse({
        content: data,
        type,
        pagination: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit),
        },
      }, 'Content retrieved.')
    }

    // GET /admin/reports - Get reports
    if (req.method === 'GET' && action === 'reports') {
      const [usersResult, lessonsResult, sessionsResult] = await Promise.all([
        supabase.from('user_profiles').select('id', { count: 'exact', head: true }),
        supabase.from('lesson_progress').select('id', { count: 'exact', head: true }),
        supabase.from('voice_sessions').select('id', { count: 'exact', head: true }),
      ])

      return successResponse({
        total_users: usersResult.count || 0,
        total_lessons_completed: lessonsResult.count || 0,
        total_voice_sessions: sessionsResult.count || 0,
        generated_at: new Date().toISOString(),
      }, 'Reports generated.')
    }

    // GET /admin/analytics - Get analytics
    if (req.method === 'GET' && action === 'analytics') {
      // Get user growth (last 30 days)
      const thirtyDaysAgo = new Date()
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

      const { data: recentUsers } = await supabase
        .from('user_profiles')
        .select('created_at')
        .gte('created_at', thirtyDaysAgo.toISOString())

      // Group by day
      const dailySignups: Record<string, number> = {}
      ;(recentUsers || []).forEach((u: any) => {
        const day = new Date(u.created_at).toISOString().split('T')[0]
        dailySignups[day] = (dailySignups[day] || 0) + 1
      })

      // Get top languages
      const { data: langData } = await supabase
        .from('user_profiles')
        .select('target_language')

      const languageCounts: Record<string, number> = {}
      ;(langData || []).forEach((l: any) => {
        const lang = l.target_language || 'Unknown'
        languageCounts[lang] = (languageCounts[lang] || 0) + 1
      })

      const topLanguages = Object.entries(languageCounts)
        .sort(([, a], [, b]) => b - a)
        .slice(0, 10)
        .map(([language, count]) => ({ language, count }))

      return successResponse({
        user_growth: dailySignups,
        top_languages: topLanguages,
        period: 'last_30_days',
      }, 'Analytics retrieved.')
    }

    // GET /admin/logs - Get system logs
    if (req.method === 'GET' && action === 'logs') {
      const limit = parseInt(url.searchParams.get('limit') || '50')

      // Get recent analytics events as logs
      const { data: logs } = await supabase
        .from('analytics_events')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit)

      return successResponse({
        logs: logs || [],
        total: logs?.length || 0,
      }, 'Logs retrieved.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Admin error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
