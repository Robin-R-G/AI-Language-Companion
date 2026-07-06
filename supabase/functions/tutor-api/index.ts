// supabase/functions/tutor-api/index.ts
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
  const path = url.pathname.replace(/^\/tutor-api/, '').replace(/^\/tutor/, '')
  const params = url.searchParams

  try {
    switch (true) {
      // Tutor Registration & Profile
      case path === '/register' && req.method === 'POST':
        return await handleTutorRegistration(supabase, auth.user.id, req)
      case path === '/profile' && req.method === 'GET':
        return await handleGetTutorProfile(supabase, auth.user.id)
      case path === '/profile' && req.method === 'PUT':
        return await handleUpdateTutorProfile(supabase, auth.user.id, req)
      case path === '/submit' && req.method === 'POST':
        return await handleSubmitForReview(supabase, auth.user.id)

      // Documents
      case path === '/documents' && req.method === 'GET':
        return await handleGetDocuments(supabase, auth.user.id)
      case path === '/documents' && req.method === 'POST':
        return await handleUploadDocument(supabase, auth.user.id, req)

      // Availability
      case path === '/availability' && req.method === 'GET':
        return await handleGetAvailability(supabase, auth.user.id)
      case path === '/availability' && req.method === 'PUT':
        return await handleUpdateAvailability(supabase, auth.user.id, req)

      // Dashboard Data
      case path === '/dashboard' && req.method === 'GET':
        return await handleTutorDashboard(supabase, auth.user.id)
      case path === '/dashboard/today' && req.method === 'GET':
        return await handleTodayClasses(supabase, auth.user.id)
      case path === '/dashboard/upcoming' && req.method === 'GET':
        return await handleUpcomingClasses(supabase, auth.user.id)
      case path === '/dashboard/stats' && req.method === 'GET':
        return await handleTutorStats(supabase, auth.user.id)

      // Earnings
      case path === '/earnings' && req.method === 'GET':
        return await handleEarnings(supabase, auth.user.id, params)
      case path === '/earnings/summary' && req.method === 'GET':
        return await handleEarningsSummary(supabase, auth.user.id)

      // Students
      case path === '/students' && req.method === 'GET':
        return await handleStudentsList(supabase, auth.user.id, params)

      // Reviews
      case path === '/reviews' && req.method === 'GET':
        return await handleReviews(supabase, auth.user.id, params)

      // Price Change Request
      case path === '/price-request' && req.method === 'POST':
        return await handlePriceChangeRequest(supabase, auth.user.id, req)

      // Admin: List pending tutors
      case path === '/admin/pending' && req.method === 'GET':
        return await handleAdminListPending(supabase, params)
      case path === '/admin/approve' && req.method === 'POST':
        return await handleAdminApprove(supabase, auth.user.id, req)
      case path === '/admin/reject' && req.method === 'POST':
        return await handleAdminReject(supabase, auth.user.id, req)
      case path === '/admin/feature' && req.method === 'POST':
        return await handleAdminFeatureTutor(supabase, auth.user.id, req)
      case path === '/admin/hide' && req.method === 'POST':
        return await handleAdminHideTutor(supabase, auth.user.id, req)
      case path === '/admin/block' && req.method === 'POST':
        return await handleAdminBlockTutor(supabase, auth.user.id, req)

      // Marketplace search (public)
      case path === '/search' && req.method === 'GET':
        return await handleTutorSearch(supabase, params)

      default:
        return badRequest('Invalid endpoint')
    }
  } catch (err) {
    console.error('Tutor API error:', err)
    return serverError('An unexpected error occurred')
  }
})

// --- TUTOR REGISTRATION & PROFILE ---

async function handleTutorRegistration(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { bio, qualifications, languages, exams, experience_years, education, specializations, proposed_price_cents } = body

  // Validate price within bounds
  const { data: pricing } = await supabase.rpc('validate_tutor_price', { p_price_cents: proposed_price_cents || 2000 })

  // Create tutor profile
  const { data: tutorProfile, error } = await supabase
    .from('tutor_profiles')
    .upsert({
      user_id: userId,
      bio,
      qualifications,
      languages_spoken: languages || [],
      target_exams: exams || [],
      years_of_experience: experience_years || 0,
      education,
      specializations: specializations || [],
      proposed_price_cents: proposed_price_cents || 2000,
      status: 'draft',
    }, { onConflict: 'user_id' })
    .select()
    .single()

  if (error) {
    console.error('Tutor registration error:', error)
    return serverError('Failed to create tutor profile')
  }

  // Also update the tutors table for backward compatibility
  await supabase.from('tutors').upsert({
    user_id: userId,
    bio,
    qualifications,
    languages: languages || [],
    exams: exams || [],
    experience_years: experience_years || 0,
    price_per_hour_cents: proposed_price_cents || 2000,
  }, { onConflict: 'user_id' })

  // Create tutor wallet
  await supabase.from('tutor_wallets').upsert({
    tutor_id: tutorProfile.id,
  }, { onConflict: 'tutor_id' })

  // Update user role
  await supabase.from('user_profiles').update({ role: 'tutor' }).eq('auth_user_id', userId)

  // Audit log
  await supabase.from('financial_audit_logs').insert({
    action: 'tutor_registered',
    entity_type: 'tutor_profile',
    entity_id: tutorProfile.id,
    performed_by: userId,
    new_values: body,
  })

  return createdResponse(tutorProfile, 'Tutor profile created successfully')
}

async function handleGetTutorProfile(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data, error } = await supabase
    .from('tutor_profiles')
    .select('*, user_profiles(full_name, avatar_url, email)')
    .eq('user_id', userId)
    .single()

  if (error || !data) return notFound('Tutor profile not found')
  return successResponse(data, 'Tutor profile retrieved')
}

async function handleUpdateTutorProfile(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update(body)
    .eq('user_id', userId)
    .select()
    .single()

  if (error) return serverError('Failed to update tutor profile')
  return successResponse(data, 'Tutor profile updated')
}

async function handleSubmitForReview(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  // Verify all required documents exist
  const { data: tutor } = await supabase
    .from('tutor_profiles')
    .select('id, government_id_url, certificate_url, intro_video_url')
    .eq('user_id', userId)
    .single()

  if (!tutor) return notFound('Tutor profile not found')

  const missingDocs: string[] = []
  if (!tutor.government_id_url) missingDocs.push('Government ID')
  if (!tutor.certificate_url) missingDocs.push('Teaching Certificate')

  if (missingDocs.length > 0) {
    return badRequest(`Missing required documents: ${missingDocs.join(', ')}`)
  }

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({
      status: 'pending_review',
      submitted_at: new Date().toISOString(),
    })
    .eq('user_id', userId)
    .select()
    .single()

  if (error) return serverError('Failed to submit for review')

  await supabase.from('financial_audit_logs').insert({
    action: 'tutor_submitted_for_review',
    entity_type: 'tutor_profile',
    entity_id: tutor.id,
    performed_by: userId,
  })

  return successResponse(data, 'Profile submitted for admin review')
}

// --- DOCUMENTS ---

async function handleGetDocuments(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase
    .from('tutor_profiles')
    .select('id')
    .eq('user_id', userId)
    .single()

  if (!tutor) return notFound('Tutor profile not found')

  const { data, error } = await supabase
    .from('tutor_documents')
    .select('*')
    .eq('tutor_id', tutor.id)
    .order('uploaded_at', { ascending: false })

  if (error) return serverError('Failed to fetch documents')
  return successResponse(data, 'Documents retrieved')
}

async function handleUploadDocument(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { document_type, file_url, file_name, file_size_bytes, mime_type } = body

  if (!document_type || !file_url) {
    return badRequest('document_type and file_url are required')
  }

  const { data: tutor } = await supabase
    .from('tutor_profiles')
    .select('id')
    .eq('user_id', userId)
    .single()

  if (!tutor) return notFound('Tutor profile not found')

  const { data, error } = await supabase
    .from('tutor_documents')
    .insert({
      tutor_id: tutor.id,
      document_type,
      file_url,
      file_name,
      file_size_bytes,
      mime_type,
    })
    .select()
    .single()

  if (error) return serverError('Failed to upload document')

  // Update tutor profile flags
  const updateFields: Record<string, boolean> = {}
  if (document_type === 'government_id') updateFields.id_verified = false
  if (document_type === 'teaching_certificate') updateFields.certificate_uploaded = true
  if (document_type === 'intro_video') updateFields.intro_video_uploaded = true

  await supabase.from('tutor_profiles').update(updateFields).eq('id', tutor.id)

  return createdResponse(data, 'Document uploaded successfully')
}

// --- AVAILABILITY ---

async function handleGetAvailability(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase
    .from('tutor_profiles')
    .select('id')
    .eq('user_id', userId)
    .single()

  if (!tutor) return notFound('Tutor profile not found')

  const { data, error } = await supabase
    .from('tutor_availability')
    .select('*')
    .eq('tutor_id', tutor.id)
    .order('day_of_week')

  if (error) return serverError('Failed to fetch availability')
  return successResponse(data, 'Availability retrieved')
}

async function handleUpdateAvailability(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { availability } = body // Array of { day_of_week, start_time, end_time, is_active }

  const { data: tutor } = await supabase
    .from('tutor_profiles')
    .select('id')
    .eq('user_id', userId)
    .single()

  if (!tutor) return notFound('Tutor profile not found')

  // Delete existing and re-insert
  await supabase.from('tutor_availability').delete().eq('tutor_id', tutor.id)

  if (availability && availability.length > 0) {
    const slots = availability.map((slot: any) => ({
      tutor_id: tutor.id,
      day_of_week: slot.day_of_week,
      start_time: slot.start_time,
      end_time: slot.end_time,
      is_active: slot.is_active !== false,
    }))

    const { data, error } = await supabase.from('tutor_availability').insert(slots).select()
    if (error) return serverError('Failed to update availability')
    return successResponse(data, 'Availability updated')
  }

  return successResponse([], 'Availability cleared')
}

// --- DASHBOARD ---

async function handleTutorDashboard(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase
    .from('tutor_profiles')
    .select('id')
    .eq('user_id', userId)
    .single()

  if (!tutor) return notFound('Tutor profile not found')

  const now = new Date()
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
  const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1).toISOString()

  const [
    todayBookingsRes,
    upcomingBookingsRes,
    completedBookingsRes,
    walletRes,
    reviewsRes,
    studentsRes,
  ] = await Promise.all([
    supabase.from('bookings')
      .select('*, user_profiles!student_id(full_name, avatar_url)')
      .eq('tutor_id', tutor.id)
      .gte('start_time', todayStart)
      .lt('start_time', todayEnd)
      .in('status', ['confirmed', 'pending']),
    supabase.from('bookings')
      .select('*, user_profiles!student_id(full_name, avatar_url)')
      .eq('tutor_id', tutor.id)
      .gte('start_time', now.toISOString())
      .order('start_time')
      .limit(10),
    supabase.from('bookings')
      .select('id', { count: 'exact' })
      .eq('tutor_id', tutor.id)
      .eq('status', 'completed'),
    supabase.from('tutor_wallets').select('*').eq('tutor_id', tutor.id).single(),
    supabase.from('tutor_reviews').select('rating').eq('tutor_id', tutor.id),
    supabase.from('bookings')
      .select('student_id', { count: 'exact' })
      .eq('tutor_id', tutor.id)
      .eq('status', 'completed'),
  ])

  const ratings = (reviewsRes.data || []).map((r: any) => r.rating)
  const avgRating = ratings.length > 0 ? ratings.reduce((a: number, b: number) => a + b, 0) / ratings.length : 5.0
  const wallet = walletRes.data || { pending_balance_cents: 0, available_balance_cents: 0, total_earned_cents: 0 }

  const dashboard = {
    today_classes: todayBookingsRes.data || [],
    upcoming_classes: upcomingBookingsRes.data || [],
    completed_classes_count: completedBookingsRes.count || 0,
    revenue: {
      pending_cents: wallet.pending_balance_cents,
      available_cents: wallet.available_balance_cents,
      total_earned_cents: wallet.total_earned_cents,
    },
    rating: Math.round(avgRating * 100) / 100,
    review_count: ratings.length,
    total_students: studentsRes.count || 0,
  }

  return successResponse(dashboard, 'Tutor dashboard data retrieved')
}

async function handleTodayClasses(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const now = new Date()
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
  const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1).toISOString()

  const { data, error } = await supabase
    .from('bookings')
    .select('*, user_profiles!student_id(full_name, avatar_url)')
    .eq('tutor_id', tutor.id)
    .gte('start_time', todayStart)
    .lt('start_time', todayEnd)
    .order('start_time')

  if (error) return serverError('Failed to fetch today classes')
  return successResponse(data || [], 'Today classes retrieved')
}

async function handleUpcomingClasses(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data, error } = await supabase
    .from('bookings')
    .select('*, user_profiles!student_id(full_name, avatar_url)')
    .eq('tutor_id', tutor.id)
    .gte('start_time', new Date().toISOString())
    .in('status', ['confirmed', 'pending'])
    .order('start_time')
    .limit(20)

  if (error) return serverError('Failed to fetch upcoming classes')
  return successResponse(data || [], 'Upcoming classes retrieved')
}

async function handleTutorStats(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const [bookingsRes, reviewsRes, walletRes] = await Promise.all([
    supabase.from('bookings')
      .select('status, price_paid_cents, start_time, completed_at')
      .eq('tutor_id', tutor.id),
    supabase.from('tutor_reviews').select('rating, created_at').eq('tutor_id', tutor.id),
    supabase.from('tutor_wallets').select('*').eq('tutor_id', tutor.id).single(),
  ])

  const bookings = bookingsRes.data || []
  const completed = bookings.filter((b: any) => b.status === 'completed')
  const totalHours = completed.reduce((sum: number, b: any) => {
    if (b.completed_at && b.start_time) {
      const diff = new Date(b.completed_at).getTime() - new Date(b.start_time).getTime()
      return sum + diff / (1000 * 60 * 60)
    }
    return sum
  }, 0)

  const stats = {
    total_bookings: bookings.length,
    completed_bookings: completed.length,
    cancelled_bookings: bookings.filter((b: any) => b.status === 'cancelled').length,
    total_hours_taught: Math.round(totalHours * 10) / 10,
    total_revenue_cents: completed.reduce((sum: number, b: any) => sum + (b.price_paid_cents || 0), 0),
    wallet: walletRes.data || {},
    average_rating: reviewsRes.data?.length
      ? reviewsRes.data.reduce((sum: number, r: any) => sum + r.rating, 0) / reviewsRes.data.length
      : 5.0,
    review_count: reviewsRes.data?.length || 0,
  }

  return successResponse(stats, 'Tutor stats retrieved')
}

// --- EARNINGS ---

async function handleEarnings(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data, count, error } = await supabase
    .from('tutor_wallet_transactions')
    .select('*, tutor_wallets!inner(tutor_id)', { count: 'exact' })
    .eq('tutor_wallets.tutor_id', tutor.id)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch earnings')
  return successResponse(data, 'Earnings retrieved', { total: count })
}

async function handleEarningsSummary(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data: wallet } = await supabase.from('tutor_wallets').select('*').eq('tutor_id', tutor.id).single()

  const now = new Date()
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).toISOString()

  const { data: monthlyTransactions } = await supabase
    .from('tutor_wallet_transactions')
    .select('amount_cents, type')
    .eq('wallet_id', wallet?.id || '')
    .gte('created_at', monthStart)

  const monthlyEarnings = (monthlyTransactions || [])
    .filter((t: any) => ['booking_earned', 'bonus', 'tip'].includes(t.type))
    .reduce((sum: number, t: any) => sum + t.amount_cents, 0)

  return successResponse({
    wallet,
    monthly_earnings_cents: monthlyEarnings,
  }, 'Earnings summary retrieved')
}

// --- STUDENTS ---

async function handleStudentsList(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data, error } = await supabase
    .from('bookings')
    .select('student_id, user_profiles!student_id(full_name, avatar_url), start_time, status, rating')
    .eq('tutor_id', tutor.id)
    .eq('status', 'completed')

  if (error) return serverError('Failed to fetch students')

  // Deduplicate by student_id
  const studentMap = new Map()
  for (const booking of data || []) {
    const sid = booking.student_id
    if (!studentMap.has(sid)) {
      studentMap.set(sid, {
        student_id: sid,
        profile: booking.user_profiles,
        sessions: 0,
        last_session: booking.start_time,
        average_rating: 0,
        ratings: [],
      })
    }
    const student = studentMap.get(sid)
    student.sessions++
    if (booking.rating) student.ratings.push(booking.rating)
    if (booking.start_time > student.last_session) student.last_session = booking.start_time
  }

  const students = Array.from(studentMap.values()).map(s => ({
    ...s,
    average_rating: s.ratings.length > 0 ? s.ratings.reduce((a: number, b: number) => a + b, 0) / s.ratings.length : null,
    ratings: undefined,
  }))

  return successResponse(students.slice(offset, offset + limit), 'Students retrieved', { total: students.length })
}

// --- REVIEWS ---

async function handleReviews(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data, count, error } = await supabase
    .from('tutor_reviews')
    .select('*, user_profiles!student_id(full_name, avatar_url)', { count: 'exact' })
    .eq('tutor_id', tutor.id)
    .eq('is_approved', true)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch reviews')
  return successResponse(data, 'Reviews retrieved', { total: count })
}

// --- PRICE CHANGE REQUEST ---

async function handlePriceChangeRequest(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { new_price_cents } = body

  if (!new_price_cents) return badRequest('new_price_cents is required')

  const { data: tutor } = await supabase.from('tutor_profiles').select('id, proposed_price_cents').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data: isValid } = await supabase.rpc('validate_tutor_price', { p_price_cents: new_price_cents })
  if (!isValid) return badRequest('Price is outside allowed bounds')

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({
      proposed_price_cents: new_price_cents,
      price_change_requested: true,
      price_change_requested_at: new Date().toISOString(),
    })
    .eq('id', tutor.id)
    .select()
    .single()

  if (error) return serverError('Failed to submit price change request')

  await supabase.from('financial_audit_logs').insert({
    action: 'tutor_price_change_requested',
    entity_type: 'tutor_profile',
    entity_id: tutor.id,
    performed_by: userId,
    old_values: { proposed_price_cents: tutor.proposed_price_cents },
    new_values: { proposed_price_cents: new_price_cents },
  })

  return successResponse(data, 'Price change request submitted for admin approval')
}

// --- ADMIN ENDPOINTS ---

async function handleAdminListPending(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('tutor_profiles')
    .select('*, user_profiles(full_name, email, avatar_url)', { count: 'exact' })
    .in('status', ['pending_review', 'under_review'])
    .order('submitted_at', { ascending: true })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch pending tutors')
  return successResponse(data, 'Pending tutors retrieved', { total: count })
}

async function handleAdminApprove(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, approved_price_cents } = body

  if (!tutor_id) return badRequest('tutor_id is required')

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({
      status: 'approved',
      approved_by: adminId,
      approved_at: new Date().toISOString(),
      approved_price_cents: approved_price_cents,
      id_verified: true,
      background_check_passed: true,
    })
    .eq('id', tutor_id)
    .select()
    .single()

  if (error) return serverError('Failed to approve tutor')

  // Update legacy tutors table
  await supabase.from('tutors').update({
    is_verified: true,
    price_per_hour_cents: approved_price_cents,
  }).eq('id', (data as any)?.user_id ? undefined : tutor_id)

  await supabase.from('financial_audit_logs').insert({
    action: 'tutor_approved',
    entity_type: 'tutor_profile',
    entity_id: tutor_id,
    performed_by: adminId,
    new_values: { approved_price_cents },
  })

  return successResponse(data, 'Tutor approved successfully')
}

async function handleAdminReject(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, rejection_reason } = body

  if (!tutor_id || !rejection_reason) return badRequest('tutor_id and rejection_reason are required')

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({
      status: 'rejected',
      rejection_reason,
      approved_by: adminId,
      approved_at: new Date().toISOString(),
    })
    .eq('id', tutor_id)
    .select()
    .single()

  if (error) return serverError('Failed to reject tutor')

  await supabase.from('financial_audit_logs').insert({
    action: 'tutor_rejected',
    entity_type: 'tutor_profile',
    entity_id: tutor_id,
    performed_by: adminId,
    new_values: { rejection_reason },
  })

  return successResponse(data, 'Tutor rejected')
}

async function handleAdminFeatureTutor(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, is_featured } = body

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({
      is_featured,
      featured_at: is_featured ? new Date().toISOString() : null,
    })
    .eq('id', tutor_id)
    .select()
    .single()

  if (error) return serverError('Failed to update featured status')
  return successResponse(data, is_featured ? 'Tutor featured' : 'Tutor unfeatured')
}

async function handleAdminHideTutor(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, is_hidden } = body

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({ is_hidden })
    .eq('id', tutor_id)
    .select()
    .single()

  if (error) return serverError('Failed to update visibility')
  return successResponse(data, is_hidden ? 'Tutor hidden' : 'Tutor visible')
}

async function handleAdminBlockTutor(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, is_blocked, block_reason } = body

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({ is_blocked, block_reason })
    .eq('id', tutor_id)
    .select()
    .single()

  if (error) return serverError('Failed to update block status')

  await supabase.from('financial_audit_logs').insert({
    action: is_blocked ? 'tutor_blocked' : 'tutor_unblocked',
    entity_type: 'tutor_profile',
    entity_id: tutor_id,
    performed_by: adminId,
    new_values: { is_blocked, block_reason },
  })

  return successResponse(data, is_blocked ? 'Tutor blocked' : 'Tutor unblocked')
}

// --- MARKETPLACE SEARCH (PUBLIC) ---

async function handleTutorSearch(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const search = params.get('q')
  const language = params.get('language')
  const exam = params.get('exam')
  const minPrice = params.get('min_price')
  const maxPrice = params.get('max_price')
  const sortBy = params.get('sort') || 'rating'

  let query = supabase
    .from('tutor_profiles')
    .select('*, user_profiles(full_name, avatar_url)')
    .eq('status', 'approved')
    .eq('is_hidden', false)
    .eq('is_blocked', false)

  if (search) {
    query = query.or(`bio.ilike.%${search}%,qualifications.ilike.%${search}%`)
  }

  if (language) {
    query = query.contains('languages_spoken', [language])
  }

  if (exam) {
    query = query.contains('target_exams', [exam])
  }

  if (minPrice) {
    query = query.gte('approved_price_cents', parseInt(minPrice))
  }

  if (maxPrice) {
    query = query.lte('approved_price_cents', parseInt(maxPrice))
  }

  // Sort
  if (sortBy === 'price_low') query = query.order('approved_price_cents', { ascending: true })
  else if (sortBy === 'price_high') query = query.order('approved_price_cents', { ascending: false })
  else if (sortBy === 'experience') query = query.order('years_of_experience', { ascending: false })
  else query = query.order('total_students', { ascending: false })

  const { data, count, error } = await query.range(offset, offset + limit - 1)

  if (error) return serverError('Failed to search tutors')
  return successResponse(data, 'Tutors found', { total: count })
}
