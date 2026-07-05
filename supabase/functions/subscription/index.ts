// supabase/functions/subscription/index.ts
// Section 23: Subscription APIs
// GET /subscription, POST /subscription/checkout, POST /subscription/webhook, POST /subscription/cancel
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  badRequest,
  validationError,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { validateRequired } from '../shared/validator.ts'
import { corsHeaders } from '../shared/cors.ts'

const PLANS = {
  free: { name: 'Free', price: 0, features: ['5 lessons/day', 'Basic AI', '10 vocabulary/day'] },
  pro: { name: 'Pro', price: 9.99, features: ['Unlimited lessons', 'Advanced AI', 'Unlimited vocabulary', 'Voice sessions', 'Exam prep'] },
  premium: { name: 'Premium', price: 19.99, features: ['Everything in Pro', 'Priority AI', '1-on-1 tutoring', 'Custom curriculum', 'Offline access'] },
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const action = pathParts[pathParts.length - 1]

    // POST /subscription/webhook - RevenueCat webhook (no auth required)
    if (req.method === 'POST' && action === 'webhook') {
      const body = await req.json()
      const { event, app_user_id, product_id } = body

      // Verify webhook signature in production
      console.log('RevenueCat webhook:', event, app_user_id, product_id)

      // Update subscription in database
      if (app_user_id) {
        const supabase = createClient(
          Deno.env.get('SUPABASE_URL') ?? '',
          Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
        )

        const plan = product_id?.includes('pro') ? 'pro' : product_id?.includes('premium') ? 'premium' : 'free'
        const status = event === 'INITIAL_PURCHASE' || event === 'RENEWAL' ? 'active' : 'expired'

        await supabase
          .from('subscriptions')
          .upsert({
            user_id: app_user_id,
            provider: 'revenuecat',
            plan,
            status,
          }, { onConflict: 'user_id' })
      }

      return successResponse({ received: true }, 'Webhook processed.')
    }

    // All other endpoints require auth
    const authResult = await validateRequest(req)
    if (authResult.error) return authResult.error
    if (authResult.isPreflight) return authResult.response!

    const supabase = authResult.supabaseClient
    const userId = authResult.user.id

    // GET /subscription - Get current subscription
    if (req.method === 'GET' && action === 'subscription') {
      const { data: subscription, error } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single()

      if (error || !subscription) {
        return successResponse({
          plan: 'free',
          status: 'active',
          features: PLANS.free.features,
          available_plans: PLANS,
        }, 'Free plan active.')
      }

      const planFeatures = PLANS[subscription.plan as keyof typeof PLANS]?.features || PLANS.free.features

      return successResponse({
        ...subscription,
        features: planFeatures,
        available_plans: PLANS,
      }, 'Subscription retrieved.')
    }

    // POST /subscription/checkout - Create checkout session
    if (req.method === 'POST' && action === 'checkout') {
      const body = await req.json()
      const { plan } = body

      const validation = validateRequired({ plan })
      if (!validation.isValid) {
        return validationError('Validation failed', validation.errors)
      }

      if (!PLANS[plan as keyof typeof PLANS]) {
        return badRequest('Invalid plan. Choose: free, pro, or premium')
      }

      // In production, integrate with RevenueCat or Stripe
      // For now, return checkout URL placeholder
      return successResponse({
        checkout_url: `https://checkout.ailanguagecoach.com/subscribe?plan=${plan}&user=${userId}`,
        plan,
        price: PLANS[plan as keyof typeof PLANS].price,
      }, 'Checkout session created.')
    }

    // POST /subscription/cancel - Cancel subscription
    if (req.method === 'POST' && action === 'cancel') {
      const { data: subscription } = await supabase
        .from('subscriptions')
        .select('id, plan')
        .eq('user_id', userId)
        .eq('status', 'active')
        .single()

      if (!subscription) {
        return notFound('No active subscription found')
      }

      const { error } = await supabase
        .from('subscriptions')
        .update({ status: 'cancelled' })
        .eq('id', subscription.id)

      if (error) {
        console.error('Cancel subscription error:', error)
        return serverError('Failed to cancel subscription')
      }

      return successResponse({
        subscription_id: subscription.id,
        plan: subscription.plan,
        status: 'cancelled',
      }, 'Subscription cancelled. Access continues until end of billing period.')
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Subscription error:', error)
    return serverError(error.message || 'Internal server error')
  }
})

// Need to import createClient for webhook
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
