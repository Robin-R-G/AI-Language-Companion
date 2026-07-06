// supabase/functions/tutor-payout-api/index.ts
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
  const path = url.pathname.replace(/^\/tutor-payout-api/, '').replace(/^\/tutor-payout/, '')
  const params = url.searchParams

  try {
    switch (true) {
      // Wallet
      case path === '/wallet' && req.method === 'GET':
        return await handleGetWallet(supabase, auth.user.id)
      case path === '/wallet/transactions' && req.method === 'GET':
        return await handleGetWalletTransactions(supabase, auth.user.id, params)

      // Payout Methods
      case path === '/payout-methods' && req.method === 'GET':
        return await handleGetPayoutMethods(supabase, auth.user.id)
      case path === '/payout-methods' && req.method === 'POST':
        return await handleAddPayoutMethod(supabase, auth.user.id, req)
      case path === '/payout-methods' && req.method === 'PUT':
        return await handleUpdatePayoutMethod(supabase, auth.user.id, req)
      case path === '/payout-methods/delete' && req.method === 'POST':
        return await handleDeletePayoutMethod(supabase, auth.user.id, req)

      // Withdrawals
      case path === '/withdraw' && req.method === 'POST':
        return await handleWithdraw(supabase, auth.user.id, req)
      case path === '/withdrawals' && req.method === 'GET':
        return await handleGetWithdrawals(supabase, auth.user.id, params)

      // Admin: Manage Payouts
      case path === '/admin/pending' && req.method === 'GET':
        return await handleAdminPendingPayouts(supabase, params)
      case path === '/admin/approve' && req.method === 'POST':
        return await handleAdminApprovePayout(supabase, auth.user.id, req)
      case path === '/admin/reject' && req.method === 'POST':
        return await handleAdminRejectPayout(supabase, auth.user.id, req)
      case path === '/admin/process' && req.method === 'POST':
        return await handleAdminProcessPayout(supabase, auth.user.id, req)
      case path === '/admin/all' && req.method === 'GET':
        return await handleAdminAllPayouts(supabase, params)

      default:
        return badRequest('Invalid endpoint')
    }
  } catch (err) {
    console.error('Tutor Payout API error:', err)
    return serverError('An unexpected error occurred')
  }
})

// --- WALLET ---

async function handleGetWallet(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data, error } = await supabase
    .from('tutor_wallets')
    .select('*')
    .eq('tutor_id', tutor.id)
    .single()

  if (error || !data) return notFound('Wallet not found')
  return successResponse(data, 'Wallet retrieved')
}

async function handleGetWalletTransactions(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const type = params.get('type')

  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data: wallet } = await supabase.from('tutor_wallets').select('id').eq('tutor_id', tutor.id).single()
  if (!wallet) return notFound('Wallet not found')

  let query = supabase
    .from('tutor_wallet_transactions')
    .select('*', { count: 'exact' })
    .eq('wallet_id', wallet.id)
    .order('created_at', { ascending: false })

  if (type) query = query.eq('type', type)

  query = query.range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch wallet transactions')
  return successResponse(data, 'Wallet transactions retrieved', { total: count })
}

// --- PAYOUT METHODS ---

async function handleGetPayoutMethods(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<Response> {
  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { data, error } = await supabase
    .from('tutor_payout_methods')
    .select('*')
    .eq('tutor_id', tutor.id)
    .order('is_default', { ascending: false })

  if (error) return serverError('Failed to fetch payout methods')
  return successResponse(data, 'Payout methods retrieved')
}

async function handleAddPayoutMethod(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { method_type, account_holder_name, account_number, ifsc_code, branch_name, upi_id, beneficiary_name } = body

  if (!method_type || !account_holder_name) {
    return badRequest('method_type and account_holder_name are required')
  }

  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  // Check if this is the first method (make it default)
  const { count } = await supabase
    .from('tutor_payout_methods')
    .select('id', { count: 'exact', head: true })
    .eq('tutor_id', tutor.id)

  const { data, error } = await supabase
    .from('tutor_payout_methods')
    .insert({
      tutor_id: tutor.id,
      method_type,
      account_holder_name,
      account_number,
      ifsc_code,
      branch_name,
      upi_id,
      beneficiary_name,
      is_default: (count || 0) === 0,
    })
    .select()
    .single()

  if (error) return serverError('Failed to add payout method')

  await supabase.from('financial_audit_logs').insert({
    action: 'payout_method_added',
    entity_type: 'tutor_payout_method',
    entity_id: data.id,
    performed_by: userId,
    new_values: { method_type, account_holder_name },
  })

  return createdResponse(data, 'Payout method added')
}

async function handleUpdatePayoutMethod(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id, is_default, ...updates } = body

  if (!id) return badRequest('id is required')

  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  // If setting as default, unset others
  if (is_default) {
    await supabase
      .from('tutor_payout_methods')
      .update({ is_default: false })
      .eq('tutor_id', tutor.id)
  }

  const { data, error } = await supabase
    .from('tutor_payout_methods')
    .update({ ...updates, is_default: is_default ?? false })
    .eq('id', id)
    .eq('tutor_id', tutor.id)
    .select()
    .single()

  if (error) return serverError('Failed to update payout method')
  return successResponse(data, 'Payout method updated')
}

async function handleDeletePayoutMethod(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id } = body

  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  const { error } = await supabase
    .from('tutor_payout_methods')
    .delete()
    .eq('id', id)
    .eq('tutor_id', tutor.id)

  if (error) return serverError('Failed to delete payout method')
  return successResponse(null, 'Payout method deleted')
}

// --- WITHDRAWALS ---

async function handleWithdraw(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { amount_cents, payout_method_id } = body

  if (!amount_cents || amount_cents <= 0) return badRequest('Valid amount_cents is required')

  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  // Check minimum withdrawal (e.g., 500 cents = $5)
  const MIN_WITHDRAWAL = 500
  if (amount_cents < MIN_WITHDRAWAL) {
    return badRequest(`Minimum withdrawal amount is ${MIN_WITHDRAWAL / 100}`)
  }

  // Check available balance
  const { data: wallet } = await supabase.from('tutor_wallets').select('*').eq('tutor_id', tutor.id).single()
  if (!wallet || wallet.available_balance_cents < amount_cents) {
    return badRequest('Insufficient available balance')
  }

  // Get payout method
  let payoutMethod = null
  if (payout_method_id) {
    const { data } = await supabase
      .from('tutor_payout_methods')
      .select('*')
      .eq('id', payout_method_id)
      .eq('tutor_id', tutor.id)
      .single()
    payoutMethod = data
  } else {
    const { data } = await supabase
      .from('tutor_payout_methods')
      .select('*')
      .eq('tutor_id', tutor.id)
      .eq('is_default', true)
      .single()
    payoutMethod = data
  }

  if (!payoutMethod) return badRequest('No payout method configured')

  // Calculate charges (e.g., 2% flat fee, min $0.50)
  const chargesCents = Math.max(Math.round(amount_cents * 0.02), 50)
  const netAmount = amount_cents - chargesCents

  // Create withdrawal request
  const { data: payout, error: payoutError } = await supabase
    .from('tutor_payouts')
    .insert({
      tutor_id: tutor.id,
      payout_method_id: payoutMethod.id,
      amount_cents,
      charges_cents: chargesCents,
      net_amount_cents: netAmount,
      status: 'pending',
    })
    .select()
    .single()

  if (payoutError) return serverError('Failed to create withdrawal request')

  // Deduct from available balance
  await supabase
    .from('tutor_wallets')
    .update({
      available_balance_cents: wallet.available_balance_cents - amount_cents,
      processing_balance_cents: wallet.processing_balance_cents + amount_cents,
      updated_at: new Date().toISOString(),
    })
    .eq('id', wallet.id)

  // Record wallet transaction
  await supabase.from('tutor_wallet_transactions').insert({
    wallet_id: wallet.id,
    amount_cents: -amount_cents,
    type: 'withdrawal',
    reference_id: payout.id,
    description: `Withdrawal request to ${payoutMethod.method_type}`,
  })

  await supabase.from('financial_audit_logs').insert({
    action: 'withdrawal_requested',
    entity_type: 'tutor_payout',
    entity_id: payout.id,
    performed_by: userId,
    new_values: { amount_cents, charges_cents, net_amount_cents: netAmount, method: payoutMethod.method_type },
  })

  return createdResponse(payout, 'Withdrawal request submitted for admin review')
}

async function handleGetWithdrawals(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const status = params.get('status')

  const { data: tutor } = await supabase.from('tutor_profiles').select('id').eq('user_id', userId).single()
  if (!tutor) return notFound('Tutor profile not found')

  let query = supabase
    .from('tutor_payouts')
    .select('*, tutor_payout_methods(method_type, account_holder_name, upi_id, account_number)', { count: 'exact' })
    .eq('tutor_id', tutor.id)
    .order('created_at', { ascending: false })

  if (status) query = query.eq('status', status)

  query = query.range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch withdrawals')
  return successResponse(data, 'Withdrawals retrieved', { total: count })
}

// --- ADMIN PAYOUT MANAGEMENT ---

async function handleAdminPendingPayouts(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('tutor_payouts')
    .select('*, tutor_profiles!tutor_id(id, user_id, user_profiles(full_name, email)), tutor_payout_methods(method_type, account_holder_name, upi_id, account_number, ifsc_code)', { count: 'exact' })
    .eq('status', 'pending')
    .order('created_at', { ascending: true })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch pending payouts')
  return successResponse(data, 'Pending payouts retrieved', { total: count })
}

async function handleAdminApprovePayout(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { payout_id } = body

  const { data, error } = await supabase
    .from('tutor_payouts')
    .update({
      status: 'approved',
      approved_by: adminId,
      approved_at: new Date().toISOString(),
    })
    .eq('id', payout_id)
    .eq('status', 'pending')
    .select()
    .single()

  if (error) return serverError('Failed to approve payout')

  await supabase.from('financial_audit_logs').insert({
    action: 'payout_approved',
    entity_type: 'tutor_payout',
    entity_id: payout_id,
    performed_by: adminId,
  })

  return successResponse(data, 'Payout approved')
}

async function handleAdminRejectPayout(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { payout_id, rejection_reason } = body

  const { data: payout } = await supabase.from('tutor_payouts').select('*').eq('id', payout_id).single()
  if (!payout) return notFound('Payout not found')

  const { data, error } = await supabase
    .from('tutor_payouts')
    .update({
      status: 'failed',
      rejection_reason,
    })
    .eq('id', payout_id)
    .select()
    .single()

  if (error) return serverError('Failed to reject payout')

  // Return funds to available balance
  const { data: wallet } = await supabase
    .from('tutor_wallets')
    .select('*')
    .eq('tutor_id', payout.tutor_id)
    .single()

  if (wallet) {
    await supabase
      .from('tutor_wallets')
      .update({
        available_balance_cents: wallet.available_balance_cents + payout.amount_cents,
        processing_balance_cents: Math.max(0, wallet.processing_balance_cents - payout.amount_cents),
        updated_at: new Date().toISOString(),
      })
      .eq('id', wallet.id)

    await supabase.from('tutor_wallet_transactions').insert({
      wallet_id: wallet.id,
      amount_cents: payout.amount_cents,
      type: 'withdrawal_reversed',
      reference_id: payout_id,
      description: `Withdrawal rejected: ${rejection_reason}`,
    })
  }

  await supabase.from('financial_audit_logs').insert({
    action: 'payout_rejected',
    entity_type: 'tutor_payout',
    entity_id: payout_id,
    performed_by: adminId,
    new_values: { rejection_reason },
  })

  return successResponse(data, 'Payout rejected - funds returned to wallet')
}

async function handleAdminProcessPayout(
  supabase: ReturnType<typeof createClient>,
  adminId: string,
  req: Request
): Promise(Response> {
  const body = await req.json()
  const { payout_id, transaction_reference } = body

  const { data: payout } = await supabase.from('tutor_payouts').select('*').eq('id', payout_id).single()
  if (!payout) return notFound('Payout not found')
  if (payout.status !== 'approved') return badRequest('Payout must be approved before processing')

  const { data, error } = await supabase
    .from('tutor_payouts')
    .update({
      status: 'processing',
      transaction_reference,
      processed_at: new Date().toISOString(),
    })
    .eq('id', payout_id)
    .select()
    .single()

  if (error) return serverError('Failed to update payout status')

  // Move from processing to completed (in real app, this would be webhook-driven)
  await supabase
    .from('tutor_payouts')
    .update({
      status: 'completed',
      completed_at: new Date().toISOString(),
    })
    .eq('id', payout_id)

  // Update wallet
  const { data: wallet } = await supabase
    .from('tutor_wallets')
    .select('*')
    .eq('tutor_id', payout.tutor_id)
    .single()

  if (wallet) {
    await supabase
      .from('tutor_wallets')
      .update({
        processing_balance_cents: Math.max(0, wallet.processing_balance_cents - payout.amount_cents),
        total_withdrawn_cents: wallet.total_withdrawn_cents + payout.amount_cents,
        updated_at: new Date().toISOString(),
      })
      .eq('id', wallet.id)
  }

  await supabase.from('financial_audit_logs').insert({
    action: 'payout_processed',
    entity_type: 'tutor_payout',
    entity_id: payout_id,
    performed_by: adminId,
    new_values: { transaction_reference },
  })

  return successResponse(data, 'Payout processed successfully')
}

async function handleAdminAllPayouts(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const status = params.get('status')
  const tutorId = params.get('tutor_id')

  let query = supabase
    .from('tutor_payouts')
    .select('*, tutor_profiles!tutor_id(id, user_id, user_profiles(full_name, email)), tutor_payout_methods(method_type, account_holder_name, upi_id)', { count: 'exact' })
    .order('created_at', { ascending: false })

  if (status) query = query.eq('status', status)
  if (tutorId) query = query.eq('tutor_id', tutorId)

  query = query.range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch all payouts')
  return successResponse(data, 'All payouts retrieved', { total: count })
}
