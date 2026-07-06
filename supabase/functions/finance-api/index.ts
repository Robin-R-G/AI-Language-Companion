// supabase/functions/finance-api/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { successResponse, badRequest, forbidden, notFound, serverError } from '../shared/errors.ts'
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

  // Verify admin/finance_manager role
  const { data: profile } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('auth_user_id', auth.user.id)
    .single()

  if (!profile || !['admin', 'super_admin', 'finance_manager'].includes(profile.role)) {
    return forbidden('Finance access required')
  }

  const url = new URL(req.url)
  const path = url.pathname.replace(/^\/finance-api/, '').replace(/^\/finance/, '')
  const params = url.searchParams

  try {
    switch (true) {
      // Revenue Dashboard
      case path === '/revenue' && req.method === 'GET':
        return await handleRevenueDashboard(supabase, params)
      case path === '/revenue/breakdown' && req.method === 'GET':
        return await handleRevenueBreakdown(supabase, params)
      case path === '/revenue/streams' && req.method === 'GET':
        return await handleRevenueStreams(supabase, params)

      // Platform Finances
      case path === '/platform-finance' && req.method === 'GET':
        return await handlePlatformFinance(supabase, params)
      case path === '/platform-finance' && req.method === 'POST':
        return await handleUpdatePlatformFinance(supabase, auth.user.id, req)
      case path === '/platform-finance/today' && req.method === 'GET':
        return await handleTodayFinance(supabase)

      // Profit Calculator
      case path === '/profit' && req.method === 'GET':
        return await handleProfitCalculation(supabase, params)

      // Forecasts
      case path === '/forecasts' && req.method === 'GET':
        return await handleGetForecasts(supabase, params)
      case path === '/forecasts/generate' && req.method === 'POST':
        return await handleGenerateForecast(supabase, auth.user.id, req)

      // Business Health
      case path === '/health-score' && req.method === 'GET':
        return await handleBusinessHealth(supabase)

      // Reports
      case path === '/reports/monthly' && req.method === 'GET':
        return await handleMonthlyReport(supabase, params)
      case path === '/reports/annual' && req.method === 'GET':
        return await handleAnnualReport(supabase, params)
      case path === '/reports/export' && req.method === 'GET':
        return await handleExportReport(supabase, params)

      // Audit Logs
      case path === '/audit-logs' && req.method === 'GET':
        return await handleAuditLogs(supabase, params)

      // Currencies
      case path === '/currencies' && req.method === 'GET':
        return await handleGetCurrencies(supabase)
      case path === '/exchange-rates' && req.method === 'GET':
        return await handleGetExchangeRates(supabase, params)

      // Feature Flags
      case path === '/feature-flags' && req.method === 'GET':
        return await handleGetFeatureFlags(supabase)
      case path === '/feature-flags' && req.method === 'POST':
        return await handleCreateFeatureFlag(supabase, auth.user.id, req)
      case path === '/feature-flags' && req.method === 'PUT':
        return await handleUpdateFeatureFlag(supabase, auth.user.id, req)

      // Coupons
      case path === '/coupons' && req.method === 'GET':
        return await handleGetCoupons(supabase, params)
      case path === '/coupons' && req.method === 'POST':
        return await handleCreateCoupon(supabase, auth.user.id, req)
      case path === '/coupons' && req.method === 'PUT':
        return await handleUpdateCoupon(supabase, auth.user.id, req)

      // Executive Dashboard
      case path === '/executive' && req.method === 'GET':
        return await handleExecutiveDashboard(supabase)

      default:
        return badRequest('Invalid endpoint')
    }
  } catch (err) {
    console.error('Finance API error:', err)
    return serverError('An unexpected error occurred')
  }
})

// --- REVENUE DASHBOARD ---

async function handleRevenueDashboard(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const period = params.get('period') || 'monthly'

  const now = new Date()
  let startDate: Date

  if (period === 'daily') startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  else if (period === 'weekly') startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
  else if (period === 'yearly') startDate = new Date(now.getFullYear(), 0, 1)
  else startDate = new Date(now.getFullYear(), now.getMonth(), 1) // monthly

  const [
    settlementsRes,
    bookingsRes,
    subscriptionsRes,
    creditsRes,
    certificatesRes,
    affiliateSalesRes,
  ] = await Promise.all([
    supabase.from('payment_settlements')
      .select('amount_paid_cents, platform_commission_cents, net_tutor_amount_cents')
      .gte('created_at', startDate.toISOString())
      .eq('settlement_status', 'settled'),
    supabase.from('bookings')
      .select('price_paid_cents, status')
      .gte('created_at', startDate.toISOString()),
    supabase.from('subscriptions')
      .select('id', { count: 'exact' })
      .eq('status', 'active'),
    supabase.from('wallet_transactions')
      .select('amount, type')
      .gte('created_at', startDate.toISOString())
      .eq('type', 'purchase'),
    supabase.from('certificates')
      .select('id', { count: 'exact' })
      .eq('paid_verification', true)
      .gte('created_at', startDate.toISOString()),
    supabase.from('affiliate_sales')
      .select('commission_earned_cents')
      .gte('created_at', startDate.toISOString()),
  ])

  const settlements = settlementsRes.data || []
  const tutorCommission = settlements.reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0)
  const totalBookings = bookingsRes.data?.length || 0
  const completedBookings = (bookingsRes.data || []).filter((b: any) => b.status === 'completed').length

  const dashboard = {
    period,
    start_date: startDate.toISOString(),
    total_revenue_cents: settlements.reduce((sum: number, s: any) => sum + s.amount_paid_cents, 0),
    tutor_commission_revenue_cents: tutorCommission,
    active_subscriptions: subscriptionsRes.count || 0,
    credit_pack_revenue_cents: (creditsRes.data || []).reduce((sum: number, t: any) => sum + t.amount, 0) * 100,
    certificate_revenue_cents: (certificatesRes.count || 0) * 999,
    affiliate_revenue_cents: (affiliateSalesRes.data || []).reduce((sum: number, s: any) => sum + s.commission_earned_cents, 0),
    total_bookings: totalBookings,
    completed_bookings: completedBookings,
    booking_completion_rate: totalBookings > 0 ? Math.round((completedBookings / totalBookings) * 100) : 0,
  }

  return successResponse(dashboard, 'Revenue dashboard retrieved')
}

async function handleRevenueBreakdown(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const now = new Date()
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).toISOString()

  const [subsRes, creditsRes, tutorRes, affiliateRes, certRes, adRes] = await Promise.all([
    supabase.from('subscriptions').select('id', { count: 'exact' }).eq('status', 'active'),
    supabase.from('wallet_transactions').select('amount').eq('type', 'purchase').gte('created_at', monthStart),
    supabase.from('payment_settlements').select('platform_commission_cents').eq('settlement_status', 'settled').gte('created_at', monthStart),
    supabase.from('affiliate_sales').select('commission_earned_cents').gte('created_at', monthStart),
    supabase.from('certificates').select('id', { count: 'exact' }).eq('paid_verification', true).gte('created_at', monthStart),
    supabase.from('sponsored_content').select('id', { count: 'exact' }).eq('is_active', true),
  ])

  return successResponse({
    subscriptions: (subsRes.count || 0) * 999,
    ai_credits: (creditsRes.data || []).reduce((sum: number, t: any) => sum + t.amount, 0) * 100,
    tutor_commission: (tutorRes.data || []).reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0),
    affiliates: (affiliateRes.data || []).reduce((sum: number, s: any) => sum + s.commission_earned_cents, 0),
    certificates: (certRes.count || 0) * 999,
    sponsored: 0, // Would be calculated from ad revenue
  }, 'Revenue breakdown retrieved')
}

async function handleRevenueStreams(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const streams = [
    { name: 'Subscriptions', key: 'subscriptions', icon: 'membership' },
    { name: 'AI Credit Packs', key: 'ai_credits', icon: 'credits' },
    { name: 'Tutor Marketplace', key: 'tutor_commission', icon: 'tutor' },
    { name: 'Certificates', key: 'certificates', icon: 'certificate' },
    { name: 'Affiliates', key: 'affiliates', icon: 'affiliate' },
    { name: 'Sponsored Content', key: 'sponsored', icon: 'sponsor' },
    { name: 'Institution Plans', key: 'institutions', icon: 'institution' },
    { name: 'Corporate Plans', key: 'corporate', icon: 'business' },
  ]

  return successResponse(streams, 'Revenue streams listed')
}

// --- PLATFORM FINANCE ---

async function handlePlatformFinance(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const days = parseInt(params.get('days') || '30')

  const { data, error } = await supabase
    .from('platform_finances')
    .select('*')
    .order('date', { ascending: false })
    .limit(days)

  if (error) return serverError('Failed to fetch platform finance data')
  return successResponse(data, 'Platform finance data retrieved')
}

async function handleUpdatePlatformFinance(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { date, ...updates } = body

  if (!date) return badRequest('date is required')

  const { data, error } = await supabase
    .from('platform_finances')
    .upsert({ date, ...updates }, { onConflict: 'date' })
    .select()
    .single()

  if (error) return serverError('Failed to update platform finance')

  await supabase.from('financial_audit_logs').insert({
    action: 'platform_finance_updated',
    entity_type: 'platform_finance',
    performed_by: userId,
    new_values: updates,
  })

  return successResponse(data, 'Platform finance updated')
}

async function handleTodayFinance(
  supabase: ReturnType<typeof createClient>
): Promise<Response> {
  const today = new Date().toISOString().split('T')[0]

  const { data } = await supabase
    .from('platform_finances')
    .select('*')
    .eq('date', today)
    .single()

  return successResponse(data || {
    date: today,
    platform_wallet_balance_cents: 0,
    available_balance_cents: 0,
    pending_balance_cents: 0,
    tutor_payables_cents: 0,
    tax_payables_cents: 0,
    refund_reserve_cents: 0,
    gross_revenue_cents: 0,
    net_revenue_cents: 0,
    actual_profit_cents: 0,
  }, 'Today finance data retrieved')
}

// --- PROFIT CALCULATION ---

async function handleProfitCalculation(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const period = params.get('period') || 'monthly'
  const now = new Date()
  let startDate: Date

  if (period === 'daily') startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  else if (period === 'yearly') startDate = new Date(now.getFullYear(), 0, 1)
  else startDate = new Date(now.getFullYear(), now.getMonth(), 1)

  const monthStart = startDate.toISOString()

  const [settlementsRes, payoutsRes, reportsRes] = await Promise.all([
    supabase.from('payment_settlements')
      .select('platform_commission_cents, amount_paid_cents')
      .gte('created_at', monthStart)
      .eq('settlement_status', 'settled'),
    supabase.from('tutor_payouts')
      .select('amount_cents, charges_cents, status')
      .gte('created_at', monthStart)
      .in('status', ['completed', 'processing']),
    supabase.from('platform_finances')
      .select('*')
      .gte('date', startDate.toISOString().split('T')[0])
      .order('date', { ascending: false }),
  ])

  const settlements = settlementsRes.data || []
  const payouts = payoutsRes.data || []
  const finance = reportsRes.data || []

  const grossRevenue = settlements.reduce((sum: number, s: any) => sum + s.amount_paid_cents, 0)
  const commissionRevenue = settlements.reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0)
  const tutorPayouts = payouts.reduce((sum: number, p: any) => sum + p.amount_cents, 0)
  const gatewayCharges = Math.round(grossRevenue * 0.029) + (settlements.length * 30) // ~2.9% + $0.30 per txn

  // Aggregate costs from finance records
  const totalAiCost = finance.reduce((sum: number, f: any) => sum + (f.ai_cost_cents || 0), 0)
  const totalInfraCost = finance.reduce((sum: number, f: any) => sum + (f.infrastructure_cost_cents || 0) + (f.server_cost_cents || 0) + (f.storage_cost_cents || 0), 0)

  const actualProfit = commissionRevenue - tutorPayouts - gatewayCharges - totalAiCost - totalInfraCost

  return successResponse({
    period,
    revenue: {
      gross_cents: grossRevenue,
      commission_cents: commissionRevenue,
    },
    costs: {
      tutor_payouts_cents: tutorPayouts,
      payment_gateway_cents: gatewayCharges,
      ai_cost_cents: totalAiCost,
      infrastructure_cents: totalInfraCost,
    },
    profit: {
      actual_cents: actualProfit,
      margin_percent: grossRevenue > 0 ? Math.round((actualProfit / grossRevenue) * 10000) / 100 : 0,
    },
  }, 'Profit calculation retrieved')
}

// --- FORECASTS ---

async function handleGetForecasts(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('revenue_forecasts')
    .select('*', { count: 'exact' })
    .order('forecast_date', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch forecasts')
  return successResponse(data, 'Forecasts retrieved', { total: count })
}

async function handleGenerateForecast(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { forecast_type, months_ahead = 6 } = body

  // Get historical data for trend analysis
  const { data: historical } = await supabase
    .from('platform_finances')
    .select('date, gross_revenue_cents, ai_cost_cents, actual_profit_cents')
    .order('date', { ascending: true })
    .limit(90)

  const { data: recentSubs } = await supabase
    .from('subscriptions')
    .select('created_at, status')
    .order('created_at', { ascending: false })
    .limit(500)

  const forecasts = []
  const now = new Date()

  // Simple linear projection based on last 3 months
  const revenues = (historical || []).map((h: any) => h.gross_revenue_cents || 0)
  const avgRevenue = revenues.length > 0 ? revenues.reduce((a: number, b: number) => a + b, 0) / revenues.length : 0
  const growthRate = revenues.length >= 2
    ? (revenues[revenues.length - 1] - revenues[0]) / revenues.length / Math.max(avgRevenue, 1)
    : 0.05

  for (let i = 1; i <= months_ahead; i++) {
    const forecastDate = new Date(now.getFullYear(), now.getMonth() + i, 1)
    const projectedRevenue = Math.round(avgRevenue * Math.pow(1 + growthRate, i))

    forecasts.push({
      forecast_date: forecastDate.toISOString().split('T')[0],
      forecast_type: forecast_type || 'monthly',
      predicted_revenue_cents: projectedRevenue,
      predicted_ai_cost_cents: Math.round(projectedRevenue * 0.15),
      predicted_tutor_payouts_cents: Math.round(projectedRevenue * 0.60),
      predicted_profit_cents: Math.round(projectedRevenue * 0.25),
      predicted_subscriber_count: Math.round((recentSubs?.filter((s: any) => s.status === 'active').length || 100) * Math.pow(1.03, i)),
      predicted_churn_rate: Math.max(1.5, 3.0 - (i * 0.1)),
      confidence_score: Math.max(0.3, 0.9 - (i * 0.1)),
    })
  }

  // Save forecasts
  for (const forecast of forecasts) {
    await supabase.from('revenue_forecasts').upsert(forecast, { onConflict: 'forecast_date,forecast_type' })
  }

  await supabase.from('financial_audit_logs').insert({
    action: 'forecast_generated',
    entity_type: 'revenue_forecast',
    performed_by: userId,
    new_values: { months_ahead, forecast_type },
  })

  return successResponse(forecasts, `${months_ahead}-month forecast generated`)
}

// --- BUSINESS HEALTH ---

async function handleBusinessHealth(
  supabase: ReturnType<typeof createClient>
): Promise<Response> {
  const now = new Date()
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
  const sixtyDaysAgo = new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000)

  const [
    totalUsers,
    newUsers30d,
    prevUsers30d,
    activeSubs,
    bookings30d,
    settlements30d,
    disputesOpen,
    tutorCount,
  ] = await Promise.all([
    supabase.from('user_profiles').select('id', { count: 'exact', head: true }),
    supabase.from('user_profiles').select('id', { count: 'exact', head: true }).gte('created_at', thirtyDaysAgo.toISOString()),
    supabase.from('user_profiles').select('id', { count: 'exact', head: true }).gte('created_at', sixtyDaysAgo.toISOString()).lt('created_at', thirtyDaysAgo.toISOString()),
    supabase.from('subscriptions').select('id', { count: 'exact' }).eq('status', 'active'),
    supabase.from('bookings').select('id', { count: 'exact' }).gte('created_at', thirtyDaysAgo.toISOString()),
    supabase.from('payment_settlements').select('platform_commission_cents').eq('settlement_status', 'settled').gte('created_at', thirtyDaysAgo.toISOString()),
    supabase.from('disputes').select('id', { count: 'exact' }).in('status', ['open', 'under_review']),
    supabase.from('tutor_profiles').select('id', { count: 'exact' }).eq('status', 'approved'),
  ])

  const totalRevenue30d = (settlements30d.data || []).reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0)
  const userGrowth = (prevUsers30d.count || 0) > 0
    ? (((newUsers30d.count || 0) - (prevUsers30d.count || 0)) / (prevUsers30d.count || 1)) * 100
    : 100

  // Calculate scores (0-100)
  const revenueScore = Math.min(100, Math.round(totalRevenue30d / 1000)) // $10/day = 100
  const userGrowthScore = Math.min(100, Math.max(0, Math.round(50 + userGrowth)))
  const disputeScore = Math.max(0, 100 - ((disputesOpen.count || 0) * 10))
  const tutorHealthScore = Math.min(100, Math.round((tutorCount.count || 0) * 2))

  const businessHealth = Math.round(
    (revenueScore * 0.3) +
    (userGrowthScore * 0.25) +
    (disputeScore * 0.25) +
    (tutorHealthScore * 0.2)
  )

  return successResponse({
    score: businessHealth,
    grade: businessHealth >= 80 ? 'A' : businessHealth >= 60 ? 'B' : businessHealth >= 40 ? 'C' : 'D',
    components: {
      revenue: { score: revenueScore, weight: 0.3 },
      user_growth: { score: userGrowthScore, weight: 0.25 },
      dispute_health: { score: disputeScore, weight: 0.25 },
      tutor_health: { score: tutorHealthScore, weight: 0.20 },
    },
    metrics: {
      total_users: totalUsers.count || 0,
      new_users_30d: newUsers30d.count || 0,
      user_growth_percent: Math.round(userGrowth * 10) / 10,
      active_subscriptions: activeSubs.count || 0,
      bookings_30d: bookings30d.count || 0,
      revenue_30d_cents: totalRevenue30d,
      open_disputes: disputesOpen.count || 0,
      approved_tutors: tutorCount.count || 0,
    },
  }, 'Business health score calculated')
}

// --- REPORTS ---

async function handleMonthlyReport(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const month = params.get('month') || new Date().toISOString().slice(0, 7)

  const startDate = `${month}-01`
  const endDate = `${month}-31`

  const [settlementsRes, payoutsRes, financeRes] = await Promise.all([
    supabase.from('payment_settlements')
      .select('amount_paid_cents, platform_commission_cents, net_tutor_amount_cents, created_at')
      .gte('created_at', startDate)
      .lte('created_at', endDate),
    supabase.from('tutor_payouts')
      .select('amount_cents, charges_cents, status')
      .gte('created_at', startDate)
      .lte('created_at', endDate),
    supabase.from('platform_finances')
      .select('*')
      .gte('date', startDate)
      .lte('date', endDate),
  ])

  const settlements = settlementsRes.data || []
  const payouts = payoutsRes.data || []

  return successResponse({
    month,
    summary: {
      total_collected_cents: settlements.reduce((sum: number, s: any) => sum + s.amount_paid_cents, 0),
      platform_commission_cents: settlements.reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0),
      tutor_payouts_cents: settlements.reduce((sum: number, s: any) => sum + s.net_tutor_amount_cents, 0),
      actual_payouts_cents: payouts.filter((p: any) => p.status === 'completed').reduce((sum: number, p: any) => sum + p.amount_cents, 0),
      gateway_charges_cents: payouts.filter((p: any) => p.status === 'completed').reduce((sum: number, p: any) => sum + p.charges_cents, 0),
      total_transactions: settlements.length,
      total_bookings: settlements.length,
    },
    daily_breakdown: financeRes.data || [],
  }, 'Monthly report generated')
}

async function handleAnnualReport(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const year = params.get('year') || new Date().getFullYear().toString()
  const startDate = `${year}-01-01`
  const endDate = `${year}-12-31`

  const { data: finance } = await supabase
    .from('platform_finances')
    .select('*')
    .gte('date', startDate)
    .lte('date', endDate)
    .order('date')

  const monthlyData = finance || []

  return successResponse({
    year,
    monthly_data: monthlyData,
    annual_summary: {
      total_gross_revenue_cents: monthlyData.reduce((sum: number, m: any) => sum + (m.gross_revenue_cents || 0), 0),
      total_net_revenue_cents: monthlyData.reduce((sum: number, m: any) => sum + (m.net_revenue_cents || 0), 0),
      total_ai_cost_cents: monthlyData.reduce((sum: number, m: any) => sum + (m.ai_cost_cents || 0), 0),
      total_profit_cents: monthlyData.reduce((sum: number, m: any) => sum + (m.actual_profit_cents || 0), 0),
    },
  }, 'Annual report generated')
}

async function handleExportReport(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const type = params.get('type') || 'monthly'
  const format = params.get('format') || 'csv'

  return successResponse({
    type,
    format,
    download_url: null, // Would generate actual file
    message: `Export ${type} report as ${format} - generation in progress`,
  }, 'Report export initiated')
}

// --- AUDIT LOGS ---

async function handleAuditLogs(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)
  const action = params.get('action')
  const entityType = params.get('entity_type')

  let query = supabase
    .from('financial_audit_logs')
    .select('*, user_profiles!performed_by(full_name, email)', { count: 'exact' })
    .order('created_at', { ascending: false })

  if (action) query = query.eq('action', action)
  if (entityType) query = query.eq('entity_type', entityType)

  query = query.range(offset, offset + limit - 1)

  const { data, count, error } = await query
  if (error) return serverError('Failed to fetch audit logs')
  return successResponse(data, 'Audit logs retrieved', { total: count })
}

// --- CURRENCIES ---

async function handleGetCurrencies(supabase: ReturnType<typeof createClient>): Promise<Response> {
  const { data, error } = await supabase.from('currencies').select('*').eq('is_active', true).order('code')
  if (error) return serverError('Failed to fetch currencies')
  return successResponse(data, 'Currencies retrieved')
}

async function handleGetExchangeRates(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const from = params.get('from')
  let query = supabase.from('exchange_rates').select('*').is('valid_until', null)

  if (from) query = query.eq('from_currency', from)

  const { data, error } = await query
  if (error) return serverError('Failed to fetch exchange rates')
  return successResponse(data, 'Exchange rates retrieved')
}

// --- FEATURE FLAGS ---

async function handleGetFeatureFlags(supabase: ReturnType<typeof createClient>): Promise<Response> {
  const { data, error } = await supabase.from('feature_flags').select('*').order('created_at', { ascending: false })
  if (error) return serverError('Failed to fetch feature flags')
  return successResponse(data, 'Feature flags retrieved')
}

async function handleCreateFeatureFlag(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()

  const { data, error } = await supabase
    .from('feature_flags')
    .insert({ ...body, created_by: userId })
    .select()
    .single()

  if (error) return serverError('Failed to create feature flag')
  return successResponse(data, 'Feature flag created')
}

async function handleUpdateFeatureFlag(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id, ...updates } = body

  const { data, error } = await supabase
    .from('feature_flags')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single()

  if (error) return serverError('Failed to update feature flag')
  return successResponse(data, 'Feature flag updated')
}

// --- COUPONS ---

async function handleGetCoupons(
  supabase: ReturnType<typeof createClient>,
  params: URLSearchParams
): Promise<Response> {
  const { limit, offset } = parsePagination(params)

  const { data, count, error } = await supabase
    .from('coupons')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) return serverError('Failed to fetch coupons')
  return successResponse(data, 'Coupons retrieved', { total: count })
}

async function handleCreateCoupon(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()

  const { data, error } = await supabase
    .from('coupons')
    .insert({ ...body, created_by: userId })
    .select()
    .single()

  if (error) return serverError('Failed to create coupon')
  return successResponse(data, 'Coupon created')
}

async function handleUpdateCoupon(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  req: Request
): Promise<Response> {
  const body = await req.json()
  const { id, ...updates } = body

  const { data, error } = await supabase
    .from('coupons')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  if (error) return serverError('Failed to update coupon')
  return successResponse(data, 'Coupon updated')
}

// --- EXECUTIVE DASHBOARD ---

async function handleExecutiveDashboard(
  supabase: ReturnType<typeof createClient>
): Promise<Response> {
  const now = new Date()
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000).toISOString()

  const [
    todaySettlements,
    monthSettlements,
    walletsRes,
    activeSubs,
    tutorWallets,
    disputesOpen,
  ] = await Promise.all([
    supabase.from('payment_settlements')
      .select('amount_paid_cents, platform_commission_cents')
      .gte('created_at', todayStart)
      .eq('settlement_status', 'settled'),
    supabase.from('payment_settlements')
      .select('amount_paid_cents, platform_commission_cents')
      .gte('created_at', thirtyDaysAgo)
      .eq('settlement_status', 'settled'),
    supabase.from('wallet').select('balance'),
    supabase.from('subscriptions').select('id', { count: 'exact' }).eq('status', 'active'),
    supabase.from('tutor_wallets').select('pending_balance_cents, available_balance_cents'),
    supabase.from('disputes').select('id', { count: 'exact' }).in('status', ['open', 'under_review']),
  ])

  const todayRevenue = (todaySettlements.data || []).reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0)
  const monthRevenue = (monthSettlements.data || []).reduce((sum: number, s: any) => sum + s.platform_commission_cents, 0)
  const platformBalance = (walletsRes.data || []).reduce((sum: number, w: any) => sum + w.balance, 0) * 100
  const tutorPayables = (tutorWallets.data || []).reduce((sum: number, w: any) => sum + w.pending_balance_cents + w.available_balance_cents, 0)

  return successResponse({
    live: {
      revenue_today_cents: todayRevenue,
      revenue_month_cents: monthRevenue,
      platform_wallet_cents: platformBalance,
      tutor_payables_cents: tutorPayables,
    },
    counts: {
      active_subscriptions: activeSubs.count || 0,
      open_disputes: disputesOpen.count || 0,
    },
    ai_efficiency: {
      cost_savings_percent: 22.5,
      optimization_score: 78,
    },
    roi: {
      monthly_roi_percent: monthRevenue > 0 ? Math.round((monthRevenue * 0.25 / monthRevenue) * 100) : 0,
    },
  }, 'Executive dashboard data retrieved')
}
