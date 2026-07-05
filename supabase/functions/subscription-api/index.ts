// supabase/functions/subscription-api/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { successResponse, badRequest, notFound, serverError } from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { validateRequired } from '../shared/validator.ts'

const PLANS: Record<string, { name: string; price: number; features: string[] }> = {
  free: {
    name: 'Free',
    price: 0,
    features: ['5 lessons/day', 'Basic AI', '10 vocabulary/day'],
  },
  pro: {
    name: 'Pro',
    price: 9.99,
    features: ['Unlimited lessons', 'Advanced AI', 'Unlimited vocabulary', 'Voice sessions', 'Exam prep'],
  },
  premium: {
    name: 'Premium',
    price: 19.99,
    features: ['Everything in Pro', 'Priority AI', '1-on-1 tutoring', 'Custom curriculum', 'Offline access'],
  },
}

function createServiceClient() {
  return createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  )
}

async function handleGetCurrent(req: Request): Promise<Response> {
  const auth = await validateRequest(req)
  if (auth.error) return auth.error
  if (auth.isPreflight) return auth.response!

  const supabase = auth.supabaseClient
  const userId = auth.user.id

  const { data: subscription, error } = await supabase
    .from('subscriptions')
    .select('*')
    .eq('user_id', userId)
    .in('status', ['active', 'trialing'])
    .order('created_at', { ascending: false })
    .limit(1)
    .single()

  if (error || !subscription) {
    return successResponse(
      {
        plan: 'free',
        status: 'active',
        features: PLANS.free.features,
        available_plans: PLANS,
      },
      'Free plan active.',
    )
  }

  const planFeatures = PLANS[subscription.plan]?.features || PLANS.free.features

  return successResponse(
    {
      ...subscription,
      features: planFeatures,
      available_plans: PLANS,
    },
    'Subscription retrieved.',
  )
}

async function handleCheckout(req: Request): Promise<Response> {
  const auth = await validateRequest(req)
  if (auth.error) return auth.error
  if (auth.isPreflight) return auth.response!

  const userId = auth.user.id
  const body = await req.json()
  const { plan, platform } = body

  const validation = validateRequired({ plan })
  if (!validation.isValid) {
    return badRequest('Validation failed', validation.errors)
  }

  if (!PLANS[plan]) {
    return badRequest('Invalid plan. Choose: free, pro, or premium.')
  }

  if (plan === 'free') {
    return badRequest('You are already on the free plan.')
  }

  const revenuecatApiKey = Deno.env.get('REVENUECAT_API_KEY')
  const stripeApiKey = Deno.env.get('STRIPE_SECRET_KEY')

  if (platform === 'revenuecat' && revenuecatApiKey) {
    try {
      const response = await fetch('https://api.revenuecat.com/v1/subscribers/' + userId + '/entitlements/' + plan + '/purchase', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${revenuecatApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          product_id: `com.ailanguagecoach.${plan}`,
        }),
      })

      if (!response.ok) {
        const err = await response.text()
        console.error('RevenueCat checkout error:', err)
        return serverError('Failed to create checkout session with RevenueCat.')
      }

      const data = await response.json()
      return successResponse(
        {
          checkout_url: data.url || `https://checkout.ailanguagecoach.com/subscribe?plan=${plan}&user=${userId}`,
          provider: 'revenuecat',
          plan,
          price: PLANS[plan].price,
        },
        'Checkout session created.',
      )
    } catch (err) {
      console.error('RevenueCat error:', err)
      return serverError('Failed to create checkout session.')
    }
  }

  if (platform === 'stripe' && stripeApiKey) {
    try {
      const response = await fetch('https://api.stripe.com/v1/checkout/sessions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${stripeApiKey}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          'mode': 'subscription',
          'line_items[0][price_data][currency]': 'usd',
          'line_items[0][price_data][product_data][name]': `${PLANS[plan].name} Plan`,
          'line_items[0][price_data][unit_amount]': String(Math.round(PLANS[plan].price * 100)),
          'line_items[0][price_data][recurring][interval]': 'month',
          'line_items[0][quantity]': '1',
          'success_url': `https://ailanguagecoach.com/subscription?session_id={CHECKOUT_SESSION_ID}`,
          'cancel_url': 'https://ailanguagecoach.com/subscription?cancelled=true',
          'metadata[user_id]': userId,
          'metadata[plan]': plan,
        }),
      })

      if (!response.ok) {
        const err = await response.text()
        console.error('Stripe checkout error:', err)
        return serverError('Failed to create checkout session with Stripe.')
      }

      const data = await response.json()
      return successResponse(
        {
          checkout_url: data.url,
          provider: 'stripe',
          session_id: data.id,
          plan,
          price: PLANS[plan].price,
        },
        'Checkout session created.',
      )
    } catch (err) {
      console.error('Stripe error:', err)
      return serverError('Failed to create checkout session.')
    }
  }

  return successResponse(
    {
      checkout_url: `https://checkout.ailanguagecoach.com/subscribe?plan=${plan}&user=${userId}`,
      plan,
      price: PLANS[plan].price,
    },
    'Checkout session created.',
  )
}

async function handleWebhook(req: Request): Promise<Response> {
  const body = await req.json()
  const { event, app_user_id, product_id, event_timestamp } = body

  if (!event || !app_user_id) {
    return badRequest('Missing required fields: event, app_user_id.')
  }

  console.log('Webhook received:', { event, app_user_id, product_id, event_timestamp })

  const supabase = createServiceClient()

  const plan = product_id?.includes('premium')
    ? 'premium'
    : product_id?.includes('pro')
    ? 'pro'
    : 'free'

  let status: string
  switch (event) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'BILLING_ISSUE_RECOVERED':
      status = 'active'
      break
    case 'CANCELLATION':
    case 'UNCANCELLATION':
    case 'EXPIRATION':
    case 'BILLING_ISSUE':
      status = event === 'CANCELLATION' ? 'cancelled' : 'expired'
      break
    case 'SUBSCRIBER_ALIAS_CHANGED':
      status = 'active'
      break
    default:
      status = 'active'
  }

  const { error } = await supabase
    .from('subscriptions')
    .upsert(
      {
        user_id: app_user_id,
        provider: 'revenuecat',
        plan,
        status,
        product_id,
        event_type: event,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id' },
    )

  if (error) {
    console.error('Webhook DB error:', error)
    return serverError('Failed to process webhook.')
  }

  return successResponse({ received: true, event, status }, 'Webhook processed.')
}

async function handleCancel(req: Request): Promise<Response> {
  const auth = await validateRequest(req)
  if (auth.error) return auth.error
  if (auth.isPreflight) return auth.response!

  const supabase = auth.supabaseClient
  const userId = auth.user.id

  const { data: subscription, error: fetchError } = await supabase
    .from('subscriptions')
    .select('id, plan, status')
    .eq('user_id', userId)
    .eq('status', 'active')
    .single()

  if (fetchError || !subscription) {
    return notFound('No active subscription found.')
  }

  const { error: updateError } = await supabase
    .from('subscriptions')
    .update({
      status: 'cancelled',
      cancelled_at: new Date().toISOString(),
    })
    .eq('id', subscription.id)

  if (updateError) {
    console.error('Cancel subscription error:', updateError)
    return serverError('Failed to cancel subscription.')
  }

  return successResponse(
    {
      subscription_id: subscription.id,
      plan: subscription.plan,
      status: 'cancelled',
    },
    'Subscription cancelled. Access continues until end of billing period.',
  )
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const url = new URL(req.url)
  const pathParts = url.pathname.split('/').filter(Boolean)
  const lastSegment = pathParts[pathParts.length - 1]

  try {
    if (req.method === 'GET' && lastSegment === 'subscription') {
      return await handleGetCurrent(req)
    }

    if (req.method === 'POST' && lastSegment === 'webhook') {
      return await handleWebhook(req)
    }

    if (req.method === 'POST' && lastSegment === 'checkout') {
      return await handleCheckout(req)
    }

    if (req.method === 'POST' && lastSegment === 'cancel') {
      return await handleCancel(req)
    }

    return badRequest('Method not allowed for this endpoint.')
  } catch (error) {
    console.error('Subscription API error:', error)
    return serverError(error instanceof Error ? error.message : 'Internal server error.')
  }
})
