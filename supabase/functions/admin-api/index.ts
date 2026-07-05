// supabase/functions/admin-api/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { successResponse, badRequest, forbidden, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { parsePagination } from '../shared/validator.ts'

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  const auth = await validateRequest(req)
  if (auth.isPreflight) return auth.response!
  if (auth.error) return auth.error

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

  const supabase = createClient(supabaseUrl, supabaseServiceKey)

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('user_id', auth.user.id)
    .single()

  if (profileError || !profile || profile.role !== 'admin') {
    return forbidden('Admin privileges required')
  }

  const url = new URL(req.url)
  const path = url.pathname.replace(/^\/admin-api\/admin/, '').replace(/^\/admin/, '')
  const params = url.searchParams

  try {
    switch (true) {
      case path === '/users' && req.method === 'GET':
        return await handleListUsers(supabase, params)
      case path === '/content' && req.method === 'GET':
        return await handleListContent(supabase, params)
      case path === '/content' && req.method === 'PUT':
        return await handleUpdateContent(supabase, req)
      case path === '/reports' && req.method === 'GET':
        return await handleReports(supabase)
      case path === '/analytics' && req.method === 'GET':
        return await handleAnalytics(supabase)
      case path === '/logs' && req.method === 'GET':
        return await handleLogs(supabase, params)
      default:
        return badRequest('Invalid endpoint')
    }
  } catch (err) {
    console.error('Admin API error:', err)
    return serverError('An unexpected error occurred')
  }
})

async function handleListUsers(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const status = params.get('status')

  let query = supabase
    .from('user_profiles')
    .select('*, users:user_profiles!user_id(*)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (status) {
    query = query.eq('status', status)
  }

  const { data, count, error } = await query

  if (error) {
    console.error('List users error:', error)
    return serverError('Failed to fetch users')
  }

  return successResponse(data, 'Users retrieved successfully', {
    total: count,
    limit,
    offset,
  })
}

async function handleListContent(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const type = params.get('type')

  let query = supabase
    .from('learning_content')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (type) {
    query = query.eq('content_type', type)
  }

  const { data, count, error } = await query

  if (error) {
    console.error('List content error:', error)
    return serverError('Failed to fetch content')
  }

  return successResponse(data, 'Content retrieved successfully', {
    total: count,
    limit,
    offset,
  })
}

async function handleUpdateContent(
  supabase: ReturnType<typeof createClient>,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id, ...updates } = body

  if (!id) {
    return badRequest('Content ID is required')
  }

  const { data, error } = await supabase
    .from('learning_content')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  if (error) {
    console.error('Update content error:', error)
    return serverError('Failed to update content')
  }

  return successResponse(data, 'Content updated successfully')
}

async function handleReports(
  supabase: ReturnType<typeof createClient>
): Promise<Response> {
  const [usersResult, contentResult, sessionsResult] = await Promise.all([
    supabase.from('user_profiles').select('*', { count: 'exact', head: true }),
    supabase.from('learning_content').select('*', { count: 'exact', head: true }),
    supabase.from('learning_sessions').select('*', { count: 'exact', head: true }),
  ])

  const reports = {
    total_users: usersResult.count ?? 0,
    total_content: contentResult.count ?? 0,
    total_sessions: sessionsResult.count ?? 0,
    generated_at: new Date().toISOString(),
  }

  return successResponse(reports, 'Reports generated successfully')
}

async function handleAnalytics(
  supabase: ReturnType<typeof createClient>
): Promise<Response> {
  const now = new Date()
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
  const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)

  const [totalUsers, newUsers30d, activeUsers7d, sessionsResult] = await Promise.all([
    supabase.from('user_profiles').select('*', { count: 'exact', head: true }),
    supabase
      .from('user_profiles')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', thirtyDaysAgo.toISOString()),
    supabase
      .from('learning_sessions')
      .select('user_id', { count: 'exact', head: true })
      .gte('created_at', sevenDaysAgo.toISOString()),
    supabase
      .from('learning_sessions')
      .select('score, duration_minutes')
      .gte('created_at', thirtyDaysAgo.toISOString()),
  ])

  const sessions = sessionsResult.data ?? []
  const avgScore =
    sessions.length > 0
      ? sessions.reduce((sum, s) => sum + (s.score ?? 0), 0) / sessions.length
      : 0
  const totalMinutes =
    sessions.length > 0
      ? sessions.reduce((sum, s) => sum + (s.duration_minutes ?? 0), 0)
      : 0

  const analytics = {
    total_users: totalUsers.count ?? 0,
    new_users_30d: newUsers30d.count ?? 0,
    active_users_7d: activeUsers7d.count ?? 0,
    avg_score_30d: Math.round(avgScore * 100) / 100,
    total_learning_minutes_30d: totalMinutes,
    generated_at: now.toISOString(),
  }

  return successResponse(analytics, 'Analytics retrieved successfully')
}

async function handleLogs(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const level = params.get('level')

  let query = supabase
    .from('system_logs')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (level) {
    query = query.eq('level', level)
  }

  const { data, count, error } = await query

  if (error) {
    console.error('List logs error:', error)
    return serverError('Failed to fetch logs')
  }

  return successResponse(data, 'Logs retrieved successfully', {
    total: count,
    limit,
    offset,
  })
}
