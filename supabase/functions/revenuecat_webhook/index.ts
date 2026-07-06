// supabase/functions/revenuecat_webhook/index.ts
// Handles RevenueCat webhook events for subscription lifecycle management.
//
// Events handled:
//   INITIAL_PURCHASE      → activate subscription + add monthly credits
//   RENEWAL               → renew subscription + add monthly credits
//   CANCELLATION          → mark subscription as cancelled (active until period end)
//   EXPIRATION            → expire subscription
//   PRODUCT_CHANGE        → update plan
//   BILLING_ISSUE         → notify user
//   REFUND                → revoke subscription + deduct credits

import { createClient } from 'npm:@supabase/supabase-js@2';
import { createHmac } from 'node:crypto';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

// Credit amounts per plan per billing period
const PLAN_CREDITS: Record<string, number> = {
  'premium_monthly':  500,
  'premium_annual':   6000,
  'pro_monthly':      2000,
  'pro_annual':       24000,
  'basic_monthly':    100,
  'basic_annual':     1200,
};

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  // ── 1. Verify webhook signature ─────────────────────────────────────────────
  const webhookSecret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET')!;
  const signature = req.headers.get('X-RevenueCat-Signature') ?? '';
  const body = await req.text();

  const expected = createHmac('sha1', webhookSecret)
    .update(body)
    .digest('hex');

  if (signature !== expected) {
    console.error('Invalid webhook signature');
    return new Response('Unauthorized', { status: 401 });
  }

  // ── 2. Parse event ──────────────────────────────────────────────────────────
  let event: any;
  try {
    event = JSON.parse(body);
  } catch {
    return new Response('Invalid JSON', { status: 400 });
  }

  const eventType = event.event?.type as string;
  const rcUserId = event.event?.app_user_id as string;
  const productId = event.event?.product_id as string;
  const periodType = event.event?.period_type as string; // TRIAL, INTRO, NORMAL
  const expiresAt = event.event?.expiration_at_ms
    ? new Date(event.event.expiration_at_ms).toISOString()
    : null;
  const purchasedAt = event.event?.purchased_at_ms
    ? new Date(event.event.purchased_at_ms).toISOString()
    : new Date().toISOString();
  const price = event.event?.price ?? 0;
  const currency = event.event?.currency ?? 'USD';
  const environment = event.event?.environment ?? 'PRODUCTION'; // SANDBOX or PRODUCTION

  console.log(`RevenueCat webhook: ${eventType} for user ${rcUserId}, product ${productId}`);

  // ── 3. Resolve user from RevenueCat user ID ─────────────────────────────────
  const { data: profile } = await supabase
    .from('user_profiles')
    .select('id, email, full_name')
    .eq('revenuecat_user_id', rcUserId)
    .maybeSingle();

  // Also try matching by auth UID (RevenueCat user ID = Supabase UID by default)
  const { data: authProfile } = !profile
    ? await supabase
        .from('user_profiles')
        .select('id, email, full_name')
        .eq('id', rcUserId)
        .maybeSingle()
    : { data: null };

  const user = profile ?? authProfile;

  if (!user) {
    console.warn(`User not found for RevenueCat ID: ${rcUserId}`);
    // Still return 200 to prevent RevenueCat retries for unknown users
    return new Response('OK', { status: 200 });
  }

  const userId = user.id;
  const credits = PLAN_CREDITS[productId] ?? 0;

  // ── 4. Handle event ─────────────────────────────────────────────────────────
  switch (eventType) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL': {
      // Activate / renew subscription
      await supabase.from('subscriptions').upsert({
        user_id: userId,
        plan_id: productId,
        status: 'active',
        period_type: periodType?.toLowerCase() ?? 'normal',
        starts_at: purchasedAt,
        expires_at: expiresAt,
        revenuecat_product_id: productId,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' });

      // Add monthly/annual credits
      if (credits > 0) {
        await supabase.rpc('add_ai_credits', {
          p_user_id: userId,
          p_credits: credits,
          p_source: eventType === 'INITIAL_PURCHASE' ? 'subscription_new' : 'subscription_renewal',
          p_description: `${productId} - ${eventType === 'INITIAL_PURCHASE' ? 'New subscription' : 'Renewal'}`,
        });
      }

      // Generate invoice
      const invoiceId = await _createInvoice({
        userId,
        productId,
        amount: price,
        currency,
        type: eventType === 'INITIAL_PURCHASE' ? 'subscription_new' : 'subscription_renewal',
        environment,
      });

      // Notify user
      await _sendNotification(userId, {
        title: eventType === 'INITIAL_PURCHASE'
          ? '🎉 Subscription Activated!'
          : '✅ Subscription Renewed!',
        body: `Your ${productId} plan is active. ${credits > 0 ? `${credits} AI credits added.` : ''}`,
        type: 'subscription',
        data: { invoice_id: invoiceId, plan: productId },
      });

      break;
    }

    case 'CANCELLATION': {
      // Mark as cancellation pending (still active until expires_at)
      await supabase.from('subscriptions').upsert({
        user_id: userId,
        status: 'cancelled',
        cancellation_reason: event.event?.cancel_reason ?? 'user_cancelled',
        cancelled_at: new Date().toISOString(),
        expires_at: expiresAt,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' });

      await _sendNotification(userId, {
        title: '📋 Subscription Cancelled',
        body: expiresAt
          ? `Your access continues until ${new Date(expiresAt).toLocaleDateString()}.`
          : 'Your subscription has been cancelled.',
        type: 'subscription',
      });
      break;
    }

    case 'EXPIRATION': {
      await supabase.from('subscriptions').upsert({
        user_id: userId,
        status: 'expired',
        expires_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' });

      await _sendNotification(userId, {
        title: '⚠️ Subscription Expired',
        body: 'Your subscription has expired. Renew to continue learning with AI.',
        type: 'subscription',
      });
      break;
    }

    case 'PRODUCT_CHANGE': {
      const newProductId = event.event?.new_product_id as string ?? productId;
      await supabase.from('subscriptions').upsert({
        user_id: userId,
        plan_id: newProductId,
        status: 'active',
        expires_at: expiresAt,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' });

      await _sendNotification(userId, {
        title: '🔄 Plan Updated',
        body: `Your plan has been changed to ${newProductId}.`,
        type: 'subscription',
      });
      break;
    }

    case 'BILLING_ISSUE': {
      await supabase.from('subscriptions').upsert({
        user_id: userId,
        status: 'billing_error',
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' });

      await _sendNotification(userId, {
        title: '⚠️ Billing Issue',
        body: 'There was a problem with your payment. Please update your payment method.',
        type: 'billing',
      });
      break;
    }

    case 'REFUND': {
      await supabase.from('subscriptions').upsert({
        user_id: userId,
        status: 'refunded',
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' });

      // Deduct the credits that were awarded
      if (credits > 0) {
        await supabase.rpc('deduct_ai_credits', {
          p_user_id: userId,
          p_credits: credits,
          p_source: 'subscription_refund',
          p_description: `Refund for ${productId}`,
        });
      }

      await _sendNotification(userId, {
        title: '💰 Refund Processed',
        body: 'Your refund has been processed. Credits have been adjusted.',
        type: 'billing',
      });
      break;
    }

    default:
      console.log(`Unhandled event type: ${eventType}`);
  }

  // ── 5. Log to audit table ───────────────────────────────────────────────────
  await supabase.from('subscription_audit_logs').insert({
    user_id: userId,
    event_type: eventType,
    product_id: productId,
    amount: price,
    currency,
    credits_awarded: ['INITIAL_PURCHASE', 'RENEWAL'].includes(eventType) ? credits : 0,
    environment,
    raw_event: event,
    created_at: new Date().toISOString(),
  });

  // ── 6. Update admin dashboard aggregate ────────────────────────────────────
  await supabase.rpc('refresh_revenue_aggregates').catch(() => null);

  return new Response('OK', { status: 200 });
});

// ── Helpers ───────────────────────────────────────────────────────────────────

async function _createInvoice(params: {
  userId: string;
  productId: string;
  amount: number;
  currency: string;
  type: string;
  environment: string;
}): Promise<string> {
  const invoiceNumber = `INV-${Date.now()}`;
  const { data } = await supabase.from('invoices').insert({
    user_id: params.userId,
    invoice_number: invoiceNumber,
    plan_id: params.productId,
    amount: params.amount,
    currency: params.currency,
    type: params.type,
    status: 'paid',
    environment: params.environment,
    issued_at: new Date().toISOString(),
    due_at: new Date().toISOString(),
  }).select('id').single();

  return data?.id ?? '';
}

async function _sendNotification(
  userId: string,
  notification: {
    title: string;
    body: string;
    type: string;
    data?: Record<string, any>;
  },
) {
  await supabase.from('notifications').insert({
    user_id: userId,
    title: notification.title,
    body: notification.body,
    type: notification.type,
    data: notification.data ?? {},
    is_read: false,
    created_at: new Date().toISOString(),
  });
}
