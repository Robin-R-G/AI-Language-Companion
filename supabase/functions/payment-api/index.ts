// supabase/functions/payment-api/index.ts
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
  const path = url.pathname.replace(/^\/payment-api/, '').replace(/^\/payment/, '')
  const params = url.searchParams

  try {
    switch (true) {
      // Student Payment Flow
      case path === '/checkout' && req.method === 'POST':
        return await handleCheckout(supabase, auth.user.id, req)
      case path === '/confirm' && req.method === 'POST':
        return await handleConfirmPayment(supabase, auth.user.id, req)

      // Bookings
      case path === '/bookings' && req.method === 'GET':
        return await handleGetBookings(supabase, auth.user.id, params)
      case path === '/bookings' && req.method === 'POST':
        return await handleCreateBooking(supabase, auth.user.id, req)
      case path === '/bookings/cancel' && req.method === 'POST':
        return await handleCancelBooking(supabase, auth.user.id, req)
      case path === '/bookings/complete' && req.method === 'POST':
        return await handleCompleteBooking(supabase, auth.user.id, req)

      // Settlements
      case path === '/settlements' && req.method === 'GET':
        return await handleGetSettlements(supabase, auth.user.id, params)
      case path === '/settlements/batches' && req.method === 'GET':
        return await handleGetSettlementBatches(supabase, params)
      case path === '/settlements/batches' && req.method === 'POST':
        return await handleCreateSettlementBatch(supabase, auth.user.id, req)

      // Admin: Platform Accounts
      case path === '/admin/platform-accounts' && req.method === 'GET':
        return await handleGetPlatformAccounts(supabase)
      case path === '/admin/platform-accounts' && req.method === 'POST':
        return await handleCreatePlatformAccount(supabase, auth.user.id, req)
      case path === '/admin/platform-accounts' && req.method === 'PUT':
        return await handleUpdatePlatformAccount(supabase, auth.user.id, req)

      // Admin: Commission Rules
      case path === '/admin/commissions' && req.method === 'GET':
        return await handleGetCommissionRules(supabase)
      case path === '/admin/commissions' && req.method === 'POST':
        return await handleCreateCommissionRule(supabase, auth.user.id, req)
      case path === '/admin/commissions' && req.method === 'PUT':
        return await handleUpdateCommissionRule(supabase, auth.user.id, req)

      // Admin: Pricing Config
      case path === '/admin/pricing' && req.method === 'GET':
        return await handleGetPricingConfig(supabase)
      case path === '/admin/pricing' && req.method === 'POST':
        return await handleCreatePricingConfig(supabase, auth.user.id, req)
      case path === '/admin/pricing' && req.method === 'PUT':
        return await handleUpdatePricingConfig(supabase, auth.user.id, req)

      // Admin: Approve tutor price
      case path === '/admin/approve-price' && req.method === 'POST':
        return await handleAdminApprovePrice(supabase, auth.user.id, req)

      // Admin: Refunds
      case path === '/admin/refund' && req.method === 'POST':
        return await handleAdminRefund(supabase, auth.user.id, req)

      // Student: Request refund
      case path === '/refund-request' && req.method === 'POST':
        return await handleRefundRequest(supabase, auth.user.id, req)

      // Invoices & Receipts
      case path === '/invoices' && req.method === 'GET':
        return await handleGetInvoices(supabase, auth.user.id, params)
      case path === '/invoices' && req.method === 'POST':
        return await handleGenerateInvoice(supabase, auth.user.id, req)

      // Coupons
      case path === '/coupons/validate' && req.method === 'POST':
        return await handleValidateCoupon(supabase, auth.user.id, req)

      default:
        return badRequest('Invalid endpoint')
    }
  } catch (err) {
    console.error('Payment API error:', err)
    return serverError('An unexpected error occurred')
  }
})

// --- STUDENT PAYMENT FLOW ---

async function handleCheckout(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, start_time, end_time, payment_method, coupon_code } = body

  if (!tutor_id || !start_time || !end_time) {
    return badRequest('tutor_id, start_time, and end_time are required')
  }

  // Get tutor info
  const { data: tutor, error: tutorError } = await supabase
    .from('tutor_profiles')
    .select('id, user_id, approved_price_cents, status')
    .eq('id', tutor_id)
    .single()

  if (tutorError || !tutor) return notFound('Tutor not found')
  if (tutor.status !== 'approved') return badRequest('Tutor is not approved')

  let totalCents = tutor.approved_price_cents || 2000

  // Apply coupon if provided
  let discountCents = 0
  if (coupon_code) {
    const { data: coupon } = await supabase
      .from('coupons')
      .select('*')
      .eq('code', coupon_code)
      .eq('is_active', true)
      .single()

    if (coupon && (!coupon.valid_until || new Date(coupon.valid_until) > new Date())) {
      if (!coupon.usage_limit || coupon.used_count < coupon.usage_limit) {
        if (coupon.discount_type === 'percentage') {
          discountCents = Math.round(totalCents * Number(coupon.discount_value) / 100)
          if (coupon.max_discount_cents) {
            discountCents = Math.min(discountCents, coupon.max_discount_cents)
          }
        } else {
          discountCents = Math.min(Number(coupon.discount_value), totalCents)
        }
        // Record coupon usage
        await supabase.from('coupon_usages').insert({
          coupon_id: coupon.id,
          user_id: userId,
          discount_amount_cents: discountCents,
        })
        await supabase.from('coupons').update({ used_count: coupon.used_count + 1 }).eq('id', coupon.id)
      }
    }
  }

  const finalAmount = totalCents - discountCents

  // Calculate commission
  const { data: commission } = await supabase.rpc('calculate_commission', {
    p_amount_cents: finalAmount,
    p_tutor_id: tutor_id,
  })

  const commissionResult = commission?.[0] || { commission_cents: Math.round(finalAmount * 0.20), commission_percent: 20, net_amount_cents: Math.round(finalAmount * 0.80) }

  // Create booking (pending payment confirmation)
  const { data: booking, error: bookingError } = await supabase
    .from('bookings')
    .insert({
      student_id: userId,
      tutor_id,
      start_time,
      end_time,
      status: 'pending',
      price_paid_cents: finalAmount,
      platform_commission_cents: commissionResult.commission_cents,
      tutor_payout_cents: commissionResult.net_amount_cents,
      payment_method: payment_method || 'platform_wallet',
      notes: discountCents > 0 ? `Discount applied: ${discountCents} cents` : null,
    })
    .select()
    .single()

  if (bookingError) return serverError('Failed to create booking')

  return createdResponse({
    booking,
    amount: finalAmount,
    discount_cents: discountCents,
    commission_cents: commissionResult.commission_cents,
    commission_percent: commissionResult.commission_percent,
    net_tutor_amount_cents: commissionResult.net_amount_cents,
  }, 'Checkout session created - awaiting payment confirmation')
}

async function handleConfirmPayment(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { booking_id, transaction_id, payment_provider } = body

  if (!booking_id) return badRequest('booking_id is required')

  // Verify booking belongs to user
  const { data: booking, error: bookingError } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', booking_id)
    .eq('student_id', userId)
    .single()

  if (bookingError || !booking) return notFound('Booking not found')
  if (booking.status !== 'pending') return badRequest('Booking is not in pending status')

  // Update booking to confirmed
  const { data: updated, error: updateError } = await supabase
    .from('bookings')
    .update({
      status: 'confirmed',
      transaction_id: transaction_id,
      payment_method: payment_provider || booking.payment_method,
    })
    .eq('id', booking_id)
    .select()
    .single()

  if (updateError) return serverError('Failed to confirm payment')

  // Create audit log
  await supabase.from('financial_audit_logs').insert({
    action: 'payment_confirmed',
    entity_type: 'booking',
    entity_id: booking_id,
    performed_by: userId,
    new_values: { transaction_id, payment_provider },
  })

  return successResponse(updated, 'Payment confirmed and booking active')
}

// --- BOOKINGS ---

async function handleGetBookings(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const role = params.get('role') || 'student'
  const status = params.get('status')

  let query = supabase
    .from('bookings')
    .select('*, tutor_profiles!tutor_id(*, user_profiles(full_name, avatar_url)), user_profiles!student_id(full_name, avatar_url)', { count: 'exact' })

  if (role === 'tutor') {
    // Get tutor_id from user_id
    const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
    if (tutor) query = query.eq('tutor_id', tutor.id)
  } else {
    query = query.eq('student_id', userId)
  }

  if (status) query = query.eq('status', status)

  query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch bookings')
  return successResponse(data, 'Bookings retrieved', { total: count })
}

async function handleCreateBooking(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, start_time, end_time } = body

  if (!tutor_id || !start_time || !end_time) {
    return badRequest('tutor_id, start_time, and end_time are required')
  }

  // Redirect to checkout
  return handleCheckout(supabase, userId, req)
}

async function handleCancelBooking(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { booking_id, cancellation_reason } = body

  const { data: booking, error: bookingError } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', booking_id)
    .single()

  if (bookingError || !booking) return notFound('Booking not found')

  // Verify user is student or tutor
  const isStudent = booking.student_id === userId
  let isTutor = false
  if (!isStudent) {
    const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
    isTutor = tutor?.id === booking.tutor_id
  }

  if (!isStudent && !isTutor) return forbidden('Not authorized to cancel this booking')

  const { data, error } = await supabase
    .from('bookings')
    .update({
      status: 'cancelled',
      cancellation_reason,
      cancelled_by: userId,
    })
    .eq('id', booking_id)
    .select()
    .single()

  if (error) return serverError('Failed to cancel booking')

  await supabase.from('financial_audit_logs').insert({
    action: 'booking_cancelled',
    entity_type: 'booking',
    entity_id: booking_id,
    performed_by: userId,
    new_values: { cancellation_reason },
  })

  return successResponse(data, 'Booking cancelled')
}

async function handleCompleteBooking(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { booking_id, rating, review } = body

  const { data: booking } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', booking_id)
    .single()

  if (!booking) return notFound('Booking not found')

  // Verify user is the tutor
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor || tutor.id !== booking.tutor_id) return forbidden('Only the tutor can mark a session as completed')

  const { data, error } = await supabase
    .from('bookings')
    .update({
      status: 'completed',
      completed_at: new Date().toISOString(),
      rating,
      review,
    })
    .eq('id', booking_id)
    .select()
    .single()

  if (error) return serverError('Failed to complete booking')

  // If student left a review, create tutor review
  if (rating && booking.student_id) {
    await supabase.from('tutor_reviews').insert({
      tutor_id: booking.tutor_id,
      student_id: booking.student_id,
      booking_id,
      rating,
      review_text: review,
    })
  }

  return successResponse(data, 'Booking completed - settlement will be processed')
}

// --- SETTLEMENTS ---

async function handleGetSettlements(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const status = params.get('status')

  // Check if admin
  const { data: profile } = await supabase.from('user_profiles').select('role').eq('auth_user_id', userId).single()

  let query = supabase
    .from('payment_settlements')
    .select('*, tutor_profiles!tutor_id(*, user_profiles(full_name, email)), user_profiles!student_id(full_name)', { count: 'exact' })

  if (profile?.role !== 'admin') {
    // Non-admin: only see own settlements
    const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
    if (tutor) {
      query = query.eq('tutor_id', tutor.id)
    } else {
      query = query.eq('student_id', userId)
    }
  }

  if (status) query = query.eq('settlement_status', status)

  query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch settlements')
  return successResponse(data, 'Settlements retrieved', { total: count })
}

async function handleGetSettlementBatches(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('settlement_batches')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch settlement batches')
  return successResponse(data, 'Settlement batches retrieved', { total: count })
}

async function handleCreateSettlementBatch(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { batch_type } = body

  // Get all pending settlements
  const { data: settlements } = await supabase
    .from('payment_settlements')
    .select('*')
    .eq('settlement_status', 'pending')

  if (!settlements || settlements.length === 0) {
    return badRequest('No pending settlements to batch')
  }

  const totalAmount = settlements.reduce((sum: number, s: any) => sum + s.amount_paid_cents, 0)
  const totalCommission = settlements.reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0)
  const totalTutorPayouts = settlements.reduce((sum: number, s: any) => sum + s.net_tutor_amount_cents, 0)

  // Create batch
  const { data: batch, error: batchError } = await supabase
    .from('settlement_batches')
    .insert({
      batch_type: batch_type || 'daily',
      status: 'processing',
      total_settlements: settlements.length,
      total_amount_cents: totalAmount,
      total_commission_cents: totalCommission,
      total_tutor_payouts_cents: totalTutorPayouts,
      processed_by: userId,
    })
    .select()
    .single()

  if (batchError) return serverError('Failed to create settlement batch')

  // Mark settlements as settled
  const settlementIds = settlements.map((s: any) => s.id)
  await supabase
    .from('payment_settlements')
    .update({
      settlement_status: 'settled',
      settled_at: new Date().toISOString(),
      settlement_batch_id: batch.id,
    })
    .in('id', settlementIds)

  // Move pending wallet balances to available
  for (const settlement of settlements) {
    const { data: wallet } = await supabase
      .from('tutor_wallets')
      .select('id, pending_balance_cents')
      .eq('tutor_id', settlement.tutor_id)
      .single()

    if (wallet && wallet.pending_balance_cents > 0) {
      const transferAmount = Math.min(wallet.pending_balance_cents, settlement.net_tutor_amount_cents)
      await supabase
        .from('tutor_wallets')
        .update({
          pending_balance_cents: wallet.pending_balance_cents - transferAmount,
          available_balance_cents: wallet.available_balance_cents + transferAmount,
          updated_at: new Date().toISOString(),
        })
        .eq('id', wallet.id)

      await supabase.from('tutor_wallet_transactions').insert({
        wallet_id: wallet.id,
        amount_cents: transferAmount,
        type: 'bonus',
        reference_id: batch.id,
        description: `Settlement batch ${batch.id.toString().slice(0, 8)} - funds available for withdrawal`,
      })
    }
  }

  await supabase.from('settlement_batches').update({ status: 'completed', processed_at: new Date().toISOString() }).eq('id', batch.id)

  await supabase.from('financial_audit_logs').insert({
    action: 'settlement_batch_created',
    entity_type: 'settlement_batch',
    entity_id: batch.id,
    performed_by: userId,
    new_values: { total_settlements: settlements.length, total_amount_cents: totalAmount },
  })

  return createdResponse(batch, `Settlement batch created with ${settlements.length} settlements`)
}

// --- PLATFORM ACCOUNTS (ADMIN) ---

async function handleGetPlatformAccounts(supabase: ReturnType<typeof createClient>): Promise<Response> {
  const { data, error } = await supabase
    .from('platform_accounts')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) return serverError('Failed to fetch platform accounts')
  return successResponse(data, 'Platform accounts retrieved')
}

async function handleCreatePlatformAccount(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()

  const { data, error } = await supabase
    .from('platform_accounts')
    .insert({ ...body, created_by: userId })
    .select()
    .single()

  if (error) return serverError('Failed to create platform account')

  await supabase.from('financial_audit_logs').insert({
    action: 'platform_account_created',
    entity_type: 'platform_account',
    entity_id: data.id,
    performed_by: userId,
    new_values: { provider: body.provider, account_name: body.account_name },
  })

  return createdResponse(data, 'Platform account created')
}

async function handleUpdatePlatformAccount(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id, ...updates } = body

  if (!id) return badRequest('id is required')

  const { data, error } = await supabase
    .from('platform_accounts')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  if (error) return serverError('Failed to update platform account')
  return successResponse(data, 'Platform account updated')
}

// --- COMMISSION RULES (ADMIN) ---

async function handleGetCommissionRules(supabase: ReturnType<typeof createClient>): Promise<Response> {
  const { data, error } = await supabase
    .from('commission_rules')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) return serverError('Failed to fetch commission rules')
  return successResponse(data, 'Commission rules retrieved')
}

async function handleCreateCommissionRule(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()

  const { data, error } = await supabase
    .from('commission_rules')
    .insert({ ...body, created_by: userId })
    .select()
    .single()

  if (error) return serverError('Failed to create commission rule')

  await supabase.from('financial_audit_logs').insert({
    action: 'commission_rule_created',
    entity_type: 'commission_rule',
    entity_id: data.id,
    performed_by: userId,
    new_values: body,
  })

  return createdResponse(data, 'Commission rule created')
}

async function handleUpdateCommissionRule(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id, ...updates } = body

  if (!id) return badRequest('id is required')

  const { data: old } = await supabase.from('commission_rules').select('*').eq('id', id).single()

  const { data, error } = await supabase
    .from('commission_rules')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single()

  if (error) return serverError('Failed to update commission rule')

  await supabase.from('financial_audit_logs').insert({
    action: 'commission_rule_updated',
    entity_type: 'commission_rule',
    entity_id: id,
    performed_by: userId,
    old_values: old,
    new_values: updates,
  })

  return successResponse(data, 'Commission rule updated')
}

// --- PRICING CONFIG (ADMIN) ---

async function handleGetPricingConfig(supabase: ReturnType<typeof createClient>): Promise<Response> {
  const { data, error } = await supabase
    .from('pricing_config')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) return serverError('Failed to fetch pricing config')
  return successResponse(data, 'Pricing config retrieved')
}

async function handleCreatePricingConfig(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()

  const { data, error } = await supabase
    .from('pricing_config')
    .insert({ ...body, created_by: userId })
    .select()
    .single()

  if (error) return serverError('Failed to create pricing config')

  await supabase.from('financial_audit_logs').insert({
    action: 'pricing_config_created',
    entity_type: 'pricing_config',
    entity_id: data.id,
    performed_by: userId,
    new_values: body,
  })

  return createdResponse(data, 'Pricing config created')
}

async function handleUpdatePricingConfig(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id, ...updates } = body

  if (!id) return badRequest('id is required')

  const { data: old } = await supabase.from('pricing_config').select('*').eq('id', id).single()

  const { data, error } = await supabase
    .from('pricing_config')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single()

  if (error) return serverError('Failed to update pricing config')

  await supabase.from('financial_audit_logs').insert({
    action: 'pricing_config_updated',
    entity_type: 'pricing_config',
    entity_id: id,
    performed_by: userId,
    old_values: old,
    new_values: updates,
  })

  return successResponse(data, 'Pricing config updated')
}

// --- ADMIN APPROVE TUTOR PRICE ---

async function handleAdminApprovePrice(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { tutor_id, approved_price_cents } = body

  const { data, error } = await supabase
    .from('tutor_profiles')
    .update({
      approved_price_cents,
      price_change_requested: false,
      updated_at: new Date().toISOString(),
    })
    .eq('id', tutor_id)
    .select()
    .single()

  if (error) return serverError('Failed to approve price')

  // Update legacy tutors table
  await supabase.from('tutors').update({ price_per_hour_cents: approved_price_cents }).eq('user_id', (data as any)?.user_id)

  await supabase.from('financial_audit_logs').insert({
    action: 'tutor_price_approved',
    entity_type: 'tutor_profile',
    entity_id: tutor_id,
    performed_by: userId,
    new_values: { approved_price_cents },
  })

  return successResponse(data, 'Tutor price approved')
}

// --- REFUND ---

async function handleRefundRequest(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { booking_id, reason } = body

  const { data: booking } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', booking_id)
    .eq('student_id', userId)
    .single()

  if (!booking) return notFound('Booking not found')

  const { data, error } = await supabase
    .from('bookings')
    .update({
      refund_status: 'requested',
      refund_reason: reason,
      refund_requested_at: new Date().toISOString(),
    })
    .eq('id', booking_id)
    .select()
    .single()

  if (error) return serverError('Failed to request refund')

  // Create dispute automatically
  const { data: dispute } = await supabase.from('disputes').insert({
    dispute_type: 'refund_request',
    filed_by: userId,
    booking_id,
    tutor_id: booking.tutor_id,
    subject: `Refund request for booking ${booking_id}`,
    description: reason,
    priority: 'medium',
  }).select().single()

  if (dispute) {
    await supabase.from('bookings').update({ dispute_id: dispute.id }).eq('id', booking_id)
  }

  await supabase.from('financial_audit_logs').insert({
    action: 'refund_requested',
    entity_type: 'booking',
    entity_id: booking_id,
    performed_by: userId,
    new_values: { reason },
  })

  return successResponse(data, 'Refund request submitted')
}

async function handleAdminRefund(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { booking_id, refund_amount_cents, approve } = body

  const { data: booking } = await supabase.from('bookings').select('*').eq('id', booking_id).single()
  if (!booking) return notFound('Booking not found')

  if (approve) {
    const { data, error } = await supabase
      .from('bookings')
      .update({
        status: 'cancelled',
        refund_status: 'refunded',
        refund_amount_cents: refund_amount_cents || booking.price_paid_cents,
        refund_processed_at: new Date().toISOString(),
      })
      .eq('id', booking_id)
      .select()
      .single()

    if (error) return serverError('Failed to process refund')

    // Update settlement
    await supabase
      .from('payment_settlements')
      .update({ settlement_status: 'refunded' })
      .eq('booking_id', booking_id)

    await supabase.from('financial_audit_logs').insert({
      action: 'refund_approved',
      entity_type: 'booking',
      entity_id: booking_id,
      performed_by: userId,
      new_values: { refund_amount_cents },
    })

    return successResponse(data, 'Refund approved and processed')
  } else {
    const { data, error } = await supabase
      .from('bookings')
      .update({ refund_status: 'denied' })
      .eq('id', booking_id)
      .select()
      .single()

    if (error) return serverError('Failed to deny refund')

    await supabase.from('financial_audit_logs').insert({
      action: 'refund_denied',
      entity_type: 'booking',
      entity_id: booking_id,
      performed_by: userId,
    })

    return successResponse(data, 'Refund denied')
  }
}

// --- INVOICES ---

async function handleGetInvoices(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const type = params.get('type')

  let query = supabase
    .from('business_documents')
    .select('*', { count: 'exact' })
    .eq('recipient_id', userId)

  if (type) query = query.eq('document_type', type)

  query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch invoices')
  return successResponse(data, 'Invoices retrieved', { total: count })
}

async function handleGenerateInvoice(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { booking_id, document_type } = body

  const { data: booking } = await supabase.from('bookings').select('*').eq('id', booking_id).single()
  if (!booking) return notFound('Booking not found')

  // Generate invoice number
  const invoiceCount = await supabase.from('business_documents').select('id', { count: 'exact', head: true })
  const invoiceNumber = `INV-${(invoiceCount.count || 0) + 1001}`

  const { data, error } = await supabase
    .from('business_documents')
    .insert({
      document_type: document_type || 'invoice',
      reference_id: booking_id,
      reference_type: 'booking',
      recipient_id: userId,
      document_number: invoiceNumber,
      amount_cents: booking.price_paid_cents,
      tax_cents: 0,
      total_cents: booking.price_paid_cents,
    })
    .select()
    .single()

  if (error) return serverError('Failed to generate invoice')
  return createdResponse(data, 'Invoice generated')
}

// --- COUPONS ---

async function handleValidateCoupon(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { code, booking_amount_cents } = body

  const { data: coupon, error } = await supabase
    .from('coupons')
    .select('*')
    .eq('code', code)
    .eq('is_active', true)
    .single()

  if (error || !coupon) return notFound('Invalid coupon code')
  if (coupon.valid_until && new Date(coupon.valid_until) < new Date()) return badRequest('Coupon has expired')
  if (coupon.usage_limit && coupon.used_count >= coupon.usage_limit) return badRequest('Coupon usage limit reached')
  if (booking_amount_cents && booking_amount_cents < coupon.min_booking_amount_cents) {
    return badRequest(`Minimum booking amount is ${coupon.min_booking_amount_cents} cents`)
  }

  let discountCents = 0
  if (coupon.discount_type === 'percentage') {
    discountCents = Math.round((booking_amount_cents || 0) * Number(coupon.discount_value) / 100)
    if (coupon.max_discount_cents) discountCents = Math.min(discountCents, coupon.max_discount_cents)
  } else {
    discountCents = Number(coupon.discount_value)
  }

  return successResponse({
    coupon_id: coupon.id,
    code: coupon.code,
    discount_type: coupon.discount_type,
    discount_value: coupon.discount_value,
    discount_cents: discountCents,
  }, 'Coupon is valid')
}
