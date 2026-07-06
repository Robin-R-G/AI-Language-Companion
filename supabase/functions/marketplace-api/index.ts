// supabase/functions/marketplace-api/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { successResponse, badRequest, forbidden, notFound, serverError, createdResponse } from '../shared/errors.ts'
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

  const url = new URL(req.url)
  const path = url.pathname.replace(/^\/marketplace-api/, '').replace(/^\/marketplace/, '')
  const params = url.searchParams

  try {
    switch (true) {
      // Disputes
      case path === '/disputes' && req.method === 'GET':
        return await handleGetDisputes(supabase, auth.user.id, params)
      case path === '/disputes' && req.method === 'POST':
        return await handleCreateDispute(supabase, auth.user.id, req)
      case path === '/disputes/messages' && req.method === 'GET':
        return await handleGetDisputeMessages(supabase, auth.user.id, params)
      case path === '/disputes/messages' && req.method === 'POST':
        return await handleAddDisputeMessage(supabase, auth.user.id, req)
      case path === '/disputes/resolve' && req.method === 'POST':
        return await handleResolveDispute(supabase, auth.user.id, req)

      // Reviews
      case path === '/reviews' && req.method === 'GET':
        return await handleGetTutorReviews(supabase, params)
      case path === '/reviews' && req.method === 'POST':
        return await handleCreateReview(supabase, auth.user.id, req)

      // Admin: Moderation
      case path === '/admin/reported-tutors' && req.method === 'GET':
        return await handleReportedTutors(supabase, params)
      case path === '/admin/reported-reviews' && req.method === 'GET':
        return await handleReportedReviews(supabase, params)
      case path === '/admin/featured-tutors' && req.method === 'GET':
        return await handleFeaturedTutors(supabase, params)
      case path === '/admin/hidden-tutors' && req.method === 'GET':
        return await handleHiddenTutors(supabase, params)
      case path === '/admin/blocked-tutors' && req.method === 'GET':
        return await handleBlockedTutors(supabase, params)
      case path === '/admin/moderation-stats' && req.method === 'GET':
        return await handleModerationStats(supabase)

      default:
        return badRequest('Invalid endpoint')
    }
  } catch (err) {
    console.error('Marketplace API error:', err)
    return serverError('An unexpected error occurred')
  }
})

// --- DISPUTES ---

async function handleGetDisputes(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const status = params.get('status')
  const role = params.get('role')

  const { data: profile } = await supabase.from('user_profiles').select('role').eq('auth_user_id', userId).single()

  let query = supabase
    .from('disputes')
    .select('*, user_profiles!filed_by(full_name, avatar_url), user_profiles!against_user(full_name), tutor_profiles!tutor_id(user_profiles(full_name))', { count: 'exact' })

  // Role-based filtering
  if (profile?.role === 'support_staff' || profile?.role === 'admin') {
    // Support/admin see all
  } else if (role === 'tutor') {
    const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
    if (tutor) query = query.eq('tutor_id', tutor.id)
  } else {
    query = query.eq('filed_by', userId)
  }

  if (status) query = query.eq('status', status)

  query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch disputes')
  return successResponse(data, 'Disputes retrieved', { total: count })
}

async function handleCreateDispute(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { dispute_type, against_user, booking_id, tutor_id, subject, description, evidence_urls } = body

  if (!dispute_type || !subject || !description) {
    return badRequest('dispute_type, subject, and description are required')
  }

  const { data, error } = await supabase
    .from('disputes')
    .insert({
      dispute_type,
      filed_by: userId,
      against_user,
      booking_id,
      tutor_id,
      subject,
      description,
      evidence_urls: evidence_urls || [],
    })
    .select()
    .single()

  if (error) return serverError('Failed to create dispute')

  // Create initial message
  await supabase.from('dispute_messages').insert({
    dispute_id: data.id,
    sender_id: userId,
    message: description,
    attachment_urls: evidence_urls || [],
  })

  await supabase.from('financial_audit_logs').insert({
    action: 'dispute_created',
    entity_type: 'dispute',
    entity_id: data.id,
    performed_by: userId,
    new_values: { dispute_type, subject },
  })

  return createdResponse(data, 'Dispute created')
}

async function handleGetDisputeMessages(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const disputeId = params.get('dispute_id')
  if (!disputeId) return badRequest('dispute_id is required')

  const { data, error } = await supabase
    .from('dispute_messages')
    .select('*, user_profiles!sender_id(full_name, avatar_url)')
    .eq('dispute_id', disputeId)
    .order('created_at', { ascending: true })

  if (error) return serverError('Failed to fetch dispute messages')
  return successResponse(data, 'Dispute messages retrieved')
}

async function handleAddDisputeMessage(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { dispute_id, message, attachment_urls, is_internal_note } = body

  if (!dispute_id || !message) return badRequest('dispute_id and message are required')

  const { data, error } = await supabase
    .from('dispute_messages')
    .insert({
      dispute_id,
      sender_id: userId,
      message,
      attachment_urls: attachment_urls || [],
      is_internal_note: is_internal_note || false,
    })
    .select()
    .single()

  if (error) return serverError('Failed to add message')

  // Update dispute status if it was resolved
  await supabase.from('disputes').update({ status: 'under_review' }).eq('id', disputeId).eq('status', 'open')

  return createdResponse(data, 'Message added')
}

async function handleResolveDispute(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { dispute_id, resolution, refund_amount_cents, refund_issued } = body

  const { data, error } = await supabase
    .from('disputes')
    .update({
      status: 'resolved',
      resolution,
      resolved_by: userId,
      resolved_at: new Date().toISOString(),
      refund_amount_cents: refund_amount_cents || 0,
      refund_issued: refund_issued || false,
    })
    .eq('id', dispute_id)
    .select()
    .single()

  if (error) return serverError('Failed to resolve dispute')

  // Add resolution message
  await supabase.from('dispute_messages').insert({
    dispute_id,
    sender_id: userId,
    message: `Dispute resolved: ${resolution}`,
    is_internal_note: false,
  })

  await supabase.from('financial_audit_logs').insert({
    action: 'dispute_resolved',
    entity_type: 'dispute',
    entity_id: dispute_id,
    performed_by: userId,
    new_values: { resolution, refund_amount_cents },
  })

  return successResponse(data, 'Dispute resolved')
}

// --- REVIEWS ---

async function handleGetTutorReviews(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const tutorId = params.get('tutor_id')

  if (!tutorId) return badRequest('tutor_id is required')

  const { data, count, error } = await supabase
    .from('tutor_reviews')
    .select('*, user_profiles!student_id(full_name, avatar_url)', { count: 'exact' })
    .eq('tutor_id', tutorId)
    .eq('is_approved', true)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch reviews')
  return successResponse(data, 'Reviews retrieved', { total: count })
}

async function handleCreateReview(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, booking_id, rating, review_text, is_anonymous } = body

  if (!tutor_id || !rating) return badRequest('tutor_id and rating are required')
  if (rating < 1 || rating > 5) return badRequest('Rating must be between 1 and 5')

  const { data, error } = await supabase
    .from('tutor_reviews')
    .insert({
      tutor_id,
      student_id: userId,
      booking_id,
      rating,
      review_text,
      is_anonymous: is_anonymous || false,
    })
    .select()
    .single()

  if (error) return serverError('Failed to create review')

  // Update tutor average rating
  const { data: reviews } = await supabase.from('tutor_reviews').select('rating').eq('tutor_id', tutor_id).eq('is_approved', true)
  if (reviews && reviews.length > 0) {
    const avgRating = reviews.reduce((sum: number, r: any) => sum + r.rating, 0) / reviews.length
    await supabase.from('tutor_profiles').update({ total_students: (await supabase.from('tutor_profiles').select('total_students').eq('id', tutor_id).single()).data?.total_students || 0 }).eq('id', tutor_id)
    // Update legacy tutors table
    await supabase.from('tutors').update({ rating: Math.round(avgRating * 100) / 100, review_count: reviews.length }).eq('id', tutor_id)
  }

  return createdResponse(data, 'Review submitted')
}

// --- ADMIN MODERATION ---

async function handleReportedTutors(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('tutor_profiles')
    .select('*, user_profiles(full_name, email), disputes(id, subject, status, filed_by)')
    .eq('is_blocked', true)
    .order('updated_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch reported tutors')
  return successResponse(data, 'Reported tutors retrieved', { total: count })
}

async function handleReportedReviews(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('tutor_reviews')
    .select('*, user_profiles!student_id(full_name), tutor_profiles!tutor_id(user_profiles(full_name))')
    .eq('is_approved', false)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch reported reviews')
  return successResponse(data, 'Reported reviews retrieved', { total: count })
}

async function handleFeaturedTutors(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('tutor_profiles')
    .select('*, user_profiles(full_name, avatar_url)')
    .eq('is_featured', true)
    .eq('status', 'approved')
    .order('featured_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch featured tutors')
  return successResponse(data, 'Featured tutors retrieved', { total: count })
}

async function handleHiddenTutors(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('tutor_profiles')
    .select('*, user_profiles(full_name, email)')
    .eq('is_hidden', true)
    .order('updated_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch hidden tutors')
  return successResponse(data, 'Hidden tutors retrieved', { total: count })
}

async function handleBlockedTutors(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('tutor_profiles')
    .select('*, user_profiles(full_name, email)')
    .eq('is_blocked', true)
    .order('updated_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch blocked tutors')
  return successResponse(data, 'Blocked tutors retrieved', { total: count })
}

async function handleModerationStats(
  supabase: ReturnType<typeof createClient>
): Promise<Response> {
  const [featuredRes, hiddenRes, blockedRes, openDisputesRes, pendingReviewsRes] = await Promise.all([
    supabase.from('tutor_profiles').select('id', { count: 'exact', head: true }).eq('is_featured', true),
    supabase.from('tutor_profiles').select('id', { count: 'exact', head: true }).eq('is_hidden', true),
    supabase.from('tutor_profiles').select('id', { count: 'exact', head: true }).eq('is_blocked', true),
    supabase.from('disputes').select('id', { count: 'exact', head: true }).in('status', ['open', 'under_review']),
    supabase.from('tutor_reviews').select('id', { count: 'exact', head: true }).eq('is_approved', false),
  ])

  return successResponse({
    featured_tutors: featuredRes.count || 0,
    hidden_tutors: hiddenRes.count || 0,
    blocked_tutors: blockedRes.count || 0,
    open_disputes: openDisputesRes.count || 0,
    pending_review_approvals: pendingReviewsRes.count || 0,
  }, 'Moderation stats retrieved')
}
