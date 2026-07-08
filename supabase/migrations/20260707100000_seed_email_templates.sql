-- =====================================================
-- EMAIL TEMPLATE SEED DATA
-- All 52 transactional email templates
-- =====================================================

-- ─── STUDENT EMAILS ──────────────────────────────────

INSERT INTO email_templates (name, slug, category, subject, html_body, text_body, variables, is_active, is_default, description) VALUES

-- 1. Welcome
('Welcome', 'student-welcome', 'student',
'Welcome to AI Language Coach, {{user_name}}!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#2563eb;font-size:28px;margin-bottom:16px;">Welcome to AI Language Coach!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">We are thrilled to have you join our community of language learners! You are about to embark on an exciting journey to master {{target_language}}.</p>
<div style="background:#f0f9ff;border-left:4px solid #2563eb;padding:16px;margin:24px 0;border-radius:0 8px 8px 0;">
<p style="margin:0;font-size:15px;color:#1e293b;"><strong>Here is what you can do to get started:</strong></p>
<ul style="margin:8px 0 0 0;padding-left:20px;font-size:15px;color:#475569;">
<li>Complete your profile and set learning goals</li>
<li>Take a placement test to find your level</li>
<li>Start your first AI conversation</li>
<li>Build your vocabulary with spaced repetition</li>
</ul>
</div>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your current level: <strong>{{proficiency_level}}</strong></p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/home" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Start Learning Now</a>
</div>
<p style="font-size:14px;color:#64748b;">If you need any help, reply to this email or contact us at support@ailanguagecoach.com</p>
</div>
</body></html>',
'Welcome to AI Language Coach, {{user_name}}!

Hi {{user_name}},

We are thrilled to have you join our community! You are about to embark on an exciting journey to master {{target_language}}.

Here is what you can do to get started:
- Complete your profile and set learning goals
- Take a placement test to find your level
- Start your first AI conversation
- Build your vocabulary with spaced repetition

Your current level: {{proficiency_level}}

Start Learning: https://ailanguagecoach.com/home

If you need any help, contact us at support@ailanguagecoach.com',
'["user_name","target_language","proficiency_level"]'::jsonb,
true, true, 'Sent when a new user completes registration'),

-- 2. Premium Activated
('Premium Activated', 'student-premium-activated', 'student',
'Your {{plan_name}} subscription is now active!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#22c55e;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:32px;">&#10003;</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;margin-bottom:16px;">Premium Activated!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Great news! Your <strong>{{plan_name}}</strong> subscription is now active. You have unlocked all premium features!</p>
<div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0 0 8px 0;font-size:15px;color:#166534;"><strong>Premium features unlocked:</strong></p>
<ul style="margin:0;padding-left:20px;font-size:14px;color:#15803d;">
<li>Unlimited AI conversations</li>
<li>Advanced grammar analysis</li>
<li>Premium vocabulary packs</li>
<li>Priority voice sessions</li>
<li>Detailed progress analytics</li>
<li>Certificate generation</li>
</ul>
</div>
<p style="font-size:14px;color:#64748b;">Valid until: <strong>{{expires_at}}</strong></p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/home" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Explore Premium Features</a>
</div>
</div>
</body></html>',
'Premium Activated!

Hi {{user_name}},

Great news! Your {{plan_name}} subscription is now active. You have unlocked all premium features!

Premium features unlocked:
- Unlimited AI conversations
- Advanced grammar analysis
- Premium vocabulary packs
- Priority voice sessions
- Detailed progress analytics
- Certificate generation

Valid until: {{expires_at}}

Start using premium features: https://ailanguagecoach.com/home',
'["user_name","plan_name","expires_at"]'::jsonb,
true, true, 'Sent when a user activates a premium subscription'),

-- 3. Premium Expiring Soon
('Premium Expiring Soon', 'student-premium-expiring', 'student',
'Your premium subscription expires in {{days_remaining}} days',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#f59e0b;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:28px;">!</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;margin-bottom:16px;">Subscription Expiring Soon</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your premium subscription will expire in <strong>{{days_remaining}} days</strong> on <strong>{{expires_at}}</strong>.</p>
<div style="background:#fffbeb;border:1px solid #fde68a;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:15px;color:#92400e;"><strong>After expiry, you will lose access to:</strong></p>
<ul style="margin:8px 0 0 0;padding-left:20px;font-size:14px;color:#a16207;">
<li>Unlimited AI conversations</li>
<li>Advanced grammar analysis</li>
<li>Priority voice sessions</li>
<li>Certificate generation</li>
</ul>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/subscription" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Renew Now & Save</a>
</div>
</div>
</body></html>',
'Your premium subscription expires in {{days_remaining}} days!

Hi {{user_name}},

Your premium subscription will expire in {{days_remaining}} days on {{expires_at}}.

After expiry, you will lose access to:
- Unlimited AI conversations
- Advanced grammar analysis
- Priority voice sessions
- Certificate generation

Renew now to keep your premium features: https://ailanguagecoach.com/subscription',
'["user_name","days_remaining","expires_at"]'::jsonb,
true, true, 'Sent 3 days before premium expiry'),

-- 4. Manual Payment Received
('Manual Payment Received', 'student-manual-payment-received', 'student',
'Payment received - Under review',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Payment Received</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">We have received your payment and it is currently being verified.</p>
<div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:20px;margin:24px 0;">
<table style="width:100%;font-size:14px;color:#475569;">
<tr><td style="padding:4px 0;">Amount:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{amount}}</td></tr>
<tr><td style="padding:4px 0;">Method:</td><td style="padding:4px 0;text-align:right;">{{payment_method}}</td></tr>
<tr><td style="padding:4px 0;">UTR Number:</td><td style="padding:4px 0;text-align:right;">{{utr_number}}</td></tr>
<tr><td style="padding:4px 0;">Status:</td><td style="padding:4px 0;text-align:right;"><span style="color:#f59e0b;font-weight:600;">Under Review</span></td></tr>
</table>
</div>
<p style="font-size:14px;color:#64748b;">We typically verify payments within 24 hours. You will receive another email once your payment is approved.</p>
</div>
</body></html>',
'Payment Received - Under review

Hi {{user_name}},

We have received your payment and it is currently being verified.

Amount: {{amount}}
Method: {{payment_method}}
UTR Number: {{utr_number}}
Status: Under Review

We typically verify payments within 24 hours. You will receive another email once your payment is approved.',
'["user_name","amount","payment_method","utr_number"]'::jsonb,
true, true, 'Sent when a manual payment is submitted'),

-- 5. Manual Payment Approved
('Manual Payment Approved', 'student-manual-payment-approved', 'student',
'Payment approved! Your {{plan_name}} is now active',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#22c55e;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:32px;">&#10003;</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;">Payment Approved!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Your payment of <strong>{{amount}}</strong> has been approved. Your <strong>{{plan_name}}</strong> subscription is now active!</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/home" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Start Learning</a>
</div>
</div>
</body></html>',
'Payment Approved!

Hi {{user_name}},

Your payment of {{amount}} has been approved. Your {{plan_name}} subscription is now active!

Start learning: https://ailanguagecoach.com/home',
'["user_name","amount","plan_name"]'::jsonb,
true, true, 'Sent when a manual payment is approved'),

-- 6. Manual Payment Rejected
('Manual Payment Rejected', 'student-manual-payment-rejected', 'student',
'Payment verification failed',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Payment Verification Failed</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Unfortunately, we could not verify your payment of <strong>{{amount}}</strong>.</p>
<div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#991b1b;"><strong>Reason:</strong> {{rejection_reason}}</p>
</div>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Please try again or contact our support team for assistance.</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/subscription" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Try Again</a>
&nbsp;&nbsp;
<a href="mailto:support@ailanguagecoach.com" style="background:#ffffff;color:#2563eb;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;border:1px solid #2563eb;">Contact Support</a>
</div>
</div>
</body></html>',
'Payment Verification Failed

Hi {{user_name}},

Unfortunately, we could not verify your payment of {{amount}}.

Reason: {{rejection_reason}}

Please try again or contact our support team.

Try again: https://ailanguagecoach.com/subscription
Contact support: support@ailanguagecoach.com',
'["user_name","amount","rejection_reason"]'::jsonb,
true, true, 'Sent when a manual payment is rejected'),

-- 7. Wallet Credits Added
('Wallet Credits Added', 'student-wallet-credits-added', 'student',
'{{credits_added}} credits added to your wallet!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Credits Added to Your Wallet</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;"><strong>{{credits_added}} credits</strong> have been added to your wallet.</p>
<div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;padding:20px;margin:24px 0;text-align:center;">
<p style="margin:0;font-size:14px;color:#166534;">Reason: {{reason}}</p>
<p style="margin:8px 0 0 0;font-size:24px;color:#166534;font-weight:700;">New Balance: {{new_balance}} credits</p>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/wallet" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Wallet</a>
</div>
</div>
</body></html>',
'Credits Added to Your Wallet

Hi {{user_name}},

{{credits_added}} credits have been added to your wallet.

Reason: {{reason}}
New Balance: {{new_balance}} credits

View wallet: https://ailanguagecoach.com/wallet',
'["user_name","credits_added","new_balance","reason"]'::jsonb,
true, true, 'Sent when wallet credits are added'),

-- 8. AI Credits Low
('AI Credits Low', 'student-ai-credits-low', 'student',
'Your AI credits are running low',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">AI Credits Running Low</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">You have only <strong>{{credits_remaining}} AI credits</strong> remaining. Top up to keep your AI learning experience uninterrupted.</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/subscription" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Get More Credits</a>
</div>
</div>
</body></html>',
'AI Credits Running Low

Hi {{user_name}},

You have only {{credits_remaining}} AI credits remaining. Top up to keep your AI learning experience uninterrupted.

Get more credits: https://ailanguagecoach.com/subscription',
'["user_name","credits_remaining"]'::jsonb,
true, true, 'Sent when AI credits drop below threshold'),

-- 9. Certificate Ready
('Certificate Ready', 'student-certificate-ready', 'student',
'Your {{certificate_type}} certificate is ready!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#2563eb;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:28px;">&#127942;</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;">Certificate Ready!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Congratulations! Your <strong>{{certificate_type}}</strong> certificate for <strong>{{course_name}}</strong> is ready to download.</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/certificates" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Download Certificate</a>
</div>
</div>
</body></html>',
'Certificate Ready!

Hi {{user_name}},

Congratulations! Your {{certificate_type}} certificate for {{course_name}} is ready to download.

Download: https://ailanguagecoach.com/certificates',
'["user_name","certificate_type","course_name"]'::jsonb,
true, true, 'Sent when a certificate is generated'),

-- 10. Weekly Learning Summary
('Weekly Learning Summary', 'student-weekly-summary', 'student',
'Your weekly learning report is here!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:8px;">Weekly Learning Report</h1>
<p style="font-size:16px;color:#64748b;margin-bottom:24px;">Hi {{user_name}}, here is your progress this week!</p>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:24px 0;">
<div style="background:#f0f9ff;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:28px;font-weight:700;color:#2563eb;">{{lessons_completed}}</div>
<div style="font-size:13px;color:#64748b;">Lessons Completed</div>
</div>
<div style="background:#f0fdf4;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:28px;font-weight:700;color:#22c55e;">{{words_learned}}</div>
<div style="font-size:13px;color:#64748b;">Words Learned</div>
</div>
<div style="background:#fefce8;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:28px;font-weight:700;color:#eab308;">{{xp_earned}}</div>
<div style="font-size:13px;color:#64748b;">XP Earned</div>
</div>
<div style="background:#fdf4ff;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:28px;font-weight:700;color:#a855f7;">{{streak_days}}</div>
<div style="font-size:13px;color:#64748b;">Day Streak</div>
</div>
</div>
<p style="font-size:14px;color:#64748b;text-align:center;">You practiced for <strong>{{minutes_practiced}} minutes</strong> this week. Keep it up!</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/progress" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Full Report</a>
</div>
</div>
</body></html>',
'Weekly Learning Report

Hi {{user_name}}, here is your progress this week!

Lessons Completed: {{lessons_completed}}
Words Learned: {{words_learned}}
XP Earned: {{xp_earned}}
Day Streak: {{streak_days}}
Minutes Practiced: {{minutes_practiced}}

View full report: https://ailanguagecoach.com/progress',
'["user_name","lessons_completed","words_learned","xp_earned","streak_days","minutes_practiced"]'::jsonb,
true, true, 'Sent every Monday with weekly progress'),

-- 11. Referral Reward
('Referral Reward', 'student-referral-reward', 'student',
'You earned {{credits_earned}} credits for referring a friend!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Referral Reward!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Great news! <strong>{{referred_name}}</strong> joined using your referral link. You have earned <strong>{{credits_earned}} credits</strong>!</p>
<div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;padding:20px;margin:24px 0;text-align:center;">
<p style="margin:0;font-size:20px;color:#166534;font-weight:700;">+{{credits_earned}} Credits</p>
</div>
<p style="font-size:14px;color:#64748b;">Keep sharing your referral link to earn more credits!</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/referrals" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Share Referral Link</a>
</div>
</div>
</body></html>',
'Referral Reward!

Hi {{user_name}},

{{referred_name}} joined using your referral link. You have earned {{credits_earned}} credits!

Keep sharing your referral link to earn more: https://ailanguagecoach.com/referrals',
'["user_name","referred_name","credits_earned"]'::jsonb,
true, true, 'Sent when a referred friend joins'),

-- 12. Achievement Unlocked
('Achievement Unlocked', 'student-achievement-unlocked', 'student',
'Achievement Unlocked: {{achievement_name}}!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#f59e0b;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:28px;">&#127942;</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;">Achievement Unlocked!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Hi {{user_name}},</p>
<p style="font-size:20px;color:#1e293b;font-weight:700;text-align:center;margin:16px 0;">{{achievement_name}}</p>
<p style="font-size:16px;color:#64748b;text-align:center;">You earned <strong>+{{xp_reward}} XP</strong> for this achievement!</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/achievements" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Achievements</a>
</div>
</div>
</body></html>',
'Achievement Unlocked: {{achievement_name}}!

Hi {{user_name}},

You have unlocked: {{achievement_name}}

You earned +{{xp_reward}} XP for this achievement!

View all achievements: https://ailanguagecoach.com/achievements',
'["user_name","achievement_name","xp_reward"]'::jsonb,
true, true, 'Sent when a user unlocks an achievement'),

-- 13. Booking Confirmation
('Booking Confirmation', 'student-booking-confirmation', 'student',
'Booking confirmed with {{tutor_name}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Booking Confirmed!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your session with <strong>{{tutor_name}}</strong> has been confirmed.</p>
<div style="background:#f0f9ff;border:1px solid #bfdbfe;border-radius:12px;padding:20px;margin:24px 0;">
<table style="width:100%;font-size:14px;color:#1e40af;">
<tr><td style="padding:4px 0;">Date:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{booking_date}}</td></tr>
<tr><td style="padding:4px 0;">Time:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{booking_time}}</td></tr>
</table>
</div>
{{#if meeting_link}}
<div style="text-align:center;margin:24px 0;">
<a href="{{meeting_link}}" style="background:#22c55e;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Join Meeting</a>
</div>
{{/if}}
<p style="font-size:14px;color:#64748b;">Please be on time. You can cancel up to 24 hours before the session.</p>
</div>
</body></html>',
'Booking Confirmed!

Hi {{user_name}},

Your session with {{tutor_name}} has been confirmed.

Date: {{booking_date}}
Time: {{booking_time}}

Join meeting: {{meeting_link}}

Please be on time. You can cancel up to 24 hours before the session.',
'["user_name","tutor_name","booking_date","booking_time","meeting_link"]'::jsonb,
true, true, 'Sent when a student booking is confirmed'),

-- 14. Booking Reminder
('Booking Reminder', 'student-booking-reminder', 'student',
'Reminder: Session with {{tutor_name}} in {{minutes_until}} minutes',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Session Starting Soon!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your session with <strong>{{tutor_name}}</strong> starts in <strong>{{minutes_until}} minutes</strong>.</p>
<div style="background:#f0f9ff;border:1px solid #bfdbfe;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#1e40af;">Date: <strong>{{booking_date}}</strong></p>
<p style="margin:4px 0 0 0;font-size:14px;color:#1e40af;">Time: <strong>{{booking_time}}</strong></p>
</div>
{{#if meeting_link}}
<div style="text-align:center;margin:24px 0;">
<a href="{{meeting_link}}" style="background:#22c55e;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Join Meeting</a>
</div>
{{/if}}
</div>
</body></html>',
'Session Starting Soon!

Hi {{user_name}},

Your session with {{tutor_name}} starts in {{minutes_until}} minutes.

Date: {{booking_date}}
Time: {{booking_time}}

Join meeting: {{meeting_link}}',
'["user_name","tutor_name","booking_date","booking_time","minutes_until","meeting_link"]'::jsonb,
true, true, 'Sent 30 minutes before a session'),

-- 15. Booking Cancelled (Student)
('Booking Cancelled', 'student-booking-cancelled', 'student',
'Your session with {{tutor_name}} has been cancelled',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Session Cancelled</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your session with <strong>{{tutor_name}}</strong> on <strong>{{booking_date}}</strong> has been cancelled.</p>
{{#if cancellation_reason}}
<div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:16px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#64748b;"><strong>Reason:</strong> {{cancellation_reason}}</p>
</div>
{{/if}}
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutors" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Book Another Session</a>
</div>
</div>
</body></html>',
'Session Cancelled

Hi {{user_name}},

Your session with {{tutor_name}} on {{booking_date}} has been cancelled.

Reason: {{cancellation_reason}}

Book another session: https://ailanguagecoach.com/tutors',
'["user_name","tutor_name","booking_date","cancellation_reason"]'::jsonb,
true, true, 'Sent when a student booking is cancelled'),

-- 16. Tutor Assigned
('Tutor Assigned', 'student-tutor-assigned', 'student',
'A tutor has been assigned to you!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Tutor Assigned!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;"><strong>{{tutor_name}}</strong> has been assigned as your tutor. You can now book sessions and start learning together!</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutors" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Tutor Profile</a>
</div>
</div>
</body></html>',
'Tutor Assigned!

Hi {{user_name}},

{{tutor_name}} has been assigned as your tutor. You can now book sessions and start learning together!

View tutor profile: https://ailanguagecoach.com/tutors',
'["user_name","tutor_name"]'::jsonb,
true, true, 'Sent when a tutor is assigned to a student'),

-- 17. New Message
('New Message', 'student-new-message', 'student',
'New message from {{sender_name}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">New Message</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;"><strong>{{sender_name}}</strong> sent you a message:</p>
<div style="background:#f8fafc;border-left:4px solid #2563eb;padding:16px;margin:24px 0;border-radius:0 8px 8px 0;">
<p style="margin:0;font-size:15px;color:#475569;font-style:italic;">"{{message_preview}}"</p>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/chat" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Reply</a>
</div>
</div>
</body></html>',
'New Message from {{sender_name}}

Hi {{user_name}},

{{sender_name}} sent you a message:

"{{message_preview}}"

Reply: https://ailanguagecoach.com/chat',
'["user_name","sender_name","message_preview"]'::jsonb,
true, true, 'Sent when a student receives a new message'),

-- 18. Security Alert
('Security Alert', 'student-security-alert', 'student',
'Security alert: {{event_type}} on your account',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#ef4444;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:28px;">&#128274;</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;">Security Alert</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">We detected <strong>{{event_type}}</strong> on your account.</p>
<div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0 0 4px 0;font-size:14px;color:#991b1b;">IP Address: <strong>{{ip_address}}</strong></p>
<p style="margin:0;font-size:14px;color:#991b1b;">Device: <strong>{{device_info}}</strong></p>
</div>
<p style="font-size:14px;color:#64748b;">If this was not you, please change your password immediately and contact support.</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/settings" style="background:#ef4444;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Review Account</a>
</div>
</div>
</body></html>',
'Security Alert

Hi {{user_name}},

We detected {{event_type}} on your account.

IP Address: {{ip_address}}
Device: {{device_info}}

If this was not you, please change your password immediately and contact support.

Review account: https://ailanguagecoach.com/settings',
'["user_name","event_type","ip_address","device_info"]'::jsonb,
true, true, 'Sent on suspicious account activity'),

-- 19. Account Deleted
('Account Deleted', 'student-account-deleted', 'student',
'Your account has been deleted',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Account Deleted</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your account has been successfully deleted. All your data has been removed in accordance with our privacy policy.</p>
<p style="font-size:14px;color:#64748b;">We are sorry to see you go. If you change your mind, you can always create a new account.</p>
<p style="font-size:14px;color:#64748b;">If you have any feedback, please let us know at support@ailanguagecoach.com</p>
</div>
</body></html>',
'Account Deleted

Hi {{user_name}},

Your account has been successfully deleted. All your data has been removed in accordance with our privacy policy.

We are sorry to see you go. If you change your mind, you can always create a new account.

Feedback: support@ailanguagecoach.com',
'["user_name"]'::jsonb,
true, true, 'Sent when a user account is deleted'),

-- ─── TUTOR EMAILS ────────────────────────────────────

-- 20. Tutor Application Received
('Tutor Application Received', 'tutor-application-received', 'tutor',
'We received your tutor application!',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Application Received</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Thank you for applying to become a tutor on AI Language Coach! We have received your application and our team will review it shortly.</p>
<div style="background:#f0f9ff;border:1px solid #bfdbfe;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#1e40af;"><strong>What happens next:</strong></p>
<ol style="margin:8px 0 0 0;padding-left:20px;font-size:14px;color:#1e3a8a;">
<li>Our team reviews your qualifications and documents</li>
<li>We verify your identity and credentials</li>
<li>You receive approval or feedback within 3-5 business days</li>
<li>Once approved, you can start accepting bookings</li>
</ol>
</div>
<p style="font-size:14px;color:#64748b;">We will notify you once a decision has been made.</p>
</div>
</body></html>',
'Application Received

Hi {{user_name}},

Thank you for applying to become a tutor on AI Language Coach! We have received your application.

What happens next:
1. Our team reviews your qualifications and documents
2. We verify your identity and credentials
3. You receive approval or feedback within 3-5 business days
4. Once approved, you can start accepting bookings

We will notify you once a decision has been made.',
'["user_name"]'::jsonb,
true, true, 'Sent when a tutor submits their application'),

-- 21. Tutor Approved
('Tutor Approved', 'tutor-approved', 'tutor',
'Congratulations! Your tutor application has been approved',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#22c55e;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:32px;">&#10003;</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;">Application Approved!</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Congratulations! Your tutor application has been approved. You are now a verified tutor on AI Language Coach!</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-dashboard" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Go to Dashboard</a>
</div>
</div>
</body></html>',
'Application Approved!

Hi {{user_name}},

Congratulations! Your tutor application has been approved. You are now a verified tutor on AI Language Coach!

Go to dashboard: https://ailanguagecoach.com/tutor-dashboard',
'["user_name"]'::jsonb,
true, true, 'Sent when a tutor application is approved'),

-- 22. Tutor Rejected
('Tutor Rejected', 'tutor-rejected', 'tutor',
'Update on your tutor application',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Application Update</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">After careful review, we are unable to approve your tutor application at this time.</p>
<div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#991b1b;"><strong>Reason:</strong> {{rejection_reason}}</p>
</div>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">You are welcome to reapply after addressing the feedback. If you have questions, please contact our support team.</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-registration" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Reapply</a>
</div>
</div>
</body></html>',
'Application Update

Hi {{user_name}},

After careful review, we are unable to approve your tutor application at this time.

Reason: {{rejection_reason}}

You are welcome to reapply after addressing the feedback.

Reapply: https://ailanguagecoach.com/tutor-registration',
'["user_name","rejection_reason"]'::jsonb,
true, true, 'Sent when a tutor application is rejected'),

-- 23. Tutor Booking Request
('Tutor Booking Request', 'tutor-booking-request', 'tutor',
'New booking request from {{student_name}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">New Booking Request</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;"><strong>{{student_name}}</strong> wants to book a session with you!</p>
<div style="background:#f0f9ff;border:1px solid #bfdbfe;border-radius:12px;padding:20px;margin:24px 0;">
<table style="width:100%;font-size:14px;color:#1e40af;">
<tr><td style="padding:4px 0;">Student:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{student_name}}</td></tr>
<tr><td style="padding:4px 0;">Date:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{booking_date}}</td></tr>
<tr><td style="padding:4px 0;">Time:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{booking_time}}</td></tr>
<tr><td style="padding:4px 0;">Subject:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{subject}}</td></tr>
</table>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-dashboard" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View & Respond</a>
</div>
</div>
</body></html>',
'New Booking Request

Hi {{user_name}},

{{student_name}} wants to book a session with you!

Student: {{student_name}}
Date: {{booking_date}}
Time: {{booking_time}}
Subject: {{subject}}

View and respond: https://ailanguagecoach.com/tutor-dashboard',
'["user_name","student_name","booking_date","booking_time","subject"]'::jsonb,
true, true, 'Sent when a student requests a booking'),

-- 24. Tutor Booking Cancelled
('Tutor Booking Cancelled', 'tutor-booking-cancelled', 'tutor',
'Session cancelled by {{student_name}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Session Cancelled</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;"><strong>{{student_name}}</strong> has cancelled their session on <strong>{{booking_date}}</strong>.</p>
{{#if cancellation_reason}}
<div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:16px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#64748b;"><strong>Reason:</strong> {{cancellation_reason}}</p>
</div>
{{/if}}
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-dashboard" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Schedule</a>
</div>
</div>
</body></html>',
'Session Cancelled

Hi {{user_name}},

{{student_name}} has cancelled their session on {{booking_date}}.

Reason: {{cancellation_reason}}

View schedule: https://ailanguagecoach.com/tutor-dashboard',
'["user_name","student_name","booking_date","cancellation_reason"]'::jsonb,
true, true, 'Sent when a student cancels a booking'),

-- 25. Tutor Payment Processed
('Tutor Payment Processed', 'tutor-payment-processed', 'tutor',
'Payment of {{amount}} has been processed',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Payment Processed</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your payment of <strong>{{amount}}</strong> for <strong>{{period}}</strong> has been processed and will be credited to your account shortly.</p>
<div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;padding:20px;margin:24px 0;text-align:center;">
<p style="margin:0;font-size:24px;color:#166534;font-weight:700;">{{amount}}</p>
<p style="margin:4px 0 0 0;font-size:14px;color:#166534;">{{period}}</p>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-earnings" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Earnings</a>
</div>
</div>
</body></html>',
'Payment Processed

Hi {{user_name}},

Your payment of {{amount}} for {{period}} has been processed.

View earnings: https://ailanguagecoach.com/tutor-earnings',
'["user_name","amount","period"]'::jsonb,
true, true, 'Sent when a tutor payout is processed'),

-- 26. Tutor Monthly Earnings
('Tutor Monthly Earnings', 'tutor-monthly-earnings', 'tutor',
'Your {{month}} earnings report is ready',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Monthly Earnings Report</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Here is your earnings summary for <strong>{{month}}</strong>:</p>
<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin:24px 0;">
<div style="background:#f0fdf4;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:20px;font-weight:700;color:#22c55e;">{{total_earnings}}</div>
<div style="font-size:12px;color:#64748b;">Total Earnings</div>
</div>
<div style="background:#f0f9ff;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:20px;font-weight:700;color:#2563eb;">{{total_sessions}}</div>
<div style="font-size:12px;color:#64748b;">Sessions</div>
</div>
<div style="background:#fefce8;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:20px;font-weight:700;color:#eab308;">{{avg_rating}}</div>
<div style="font-size:12px;color:#64748b;">Avg Rating</div>
</div>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-earnings" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Detailed Report</a>
</div>
</div>
</body></html>',
'Monthly Earnings Report

Hi {{user_name}},

Here is your earnings summary for {{month}}:

Total Earnings: {{total_earnings}}
Sessions: {{total_sessions}}
Average Rating: {{avg_rating}}

View detailed report: https://ailanguagecoach.com/tutor-earnings',
'["user_name","month","total_earnings","total_sessions","avg_rating"]'::jsonb,
true, true, 'Sent on the 1st of each month'),

-- 27. Tutor New Review
('Tutor New Review', 'tutor-new-review', 'tutor',
'New review from {{student_name}} - {{rating}} stars',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">New Review</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;"><strong>{{student_name}}</strong> left you a review:</p>
<div style="text-align:center;margin:24px 0;">
<span style="font-size:32px;color:#f59e0b;">{{rating_stars}}</span>
</div>
<div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:15px;color:#475569;font-style:italic;">"{{review_text}}"</p>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-reviews" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View All Reviews</a>
</div>
</div>
</body></html>',
'New Review

Hi {{user_name}},

{{student_name}} left you a review:

Rating: {{rating}} stars

"{{review_text}}"

View all reviews: https://ailanguagecoach.com/tutor-reviews',
'["user_name","student_name","rating","rating_stars","review_text"]'::jsonb,
true, true, 'Sent when a student leaves a review'),

-- 28. Tutor Account Suspension
('Tutor Account Suspension', 'tutor-account-suspended', 'tutor',
'Your tutor account has been suspended',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Account Suspended</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your tutor account has been suspended.</p>
<div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#991b1b;"><strong>Reason:</strong> {{suspension_reason}}</p>
</div>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">During suspension, you cannot accept new bookings. If you believe this is an error, please contact our support team.</p>
<div style="text-align:center;margin:32px 0;">
<a href="mailto:support@ailanguagecoach.com" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Contact Support</a>
</div>
</div>
</body></html>',
'Account Suspended

Hi {{user_name}},

Your tutor account has been suspended.

Reason: {{suspension_reason}}

During suspension, you cannot accept new bookings. If you believe this is an error, please contact support.

Contact support: support@ailanguagecoach.com',
'["user_name","suspension_reason"]'::jsonb,
true, true, 'Sent when a tutor account is suspended'),

-- 29. Tutor Verification Approved
('Tutor Verification Approved', 'tutor-verification-approved', 'tutor',
'Your identity verification has been approved',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#22c55e;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:32px;">&#10003;</div>
</div>
<h1 style="color:#1e293b;font-size:24px;text-align:center;">Verification Approved</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;text-align:center;">Your identity verification has been approved. Your profile now shows a verified badge!</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-dashboard" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Profile</a>
</div>
</div>
</body></html>',
'Verification Approved

Hi {{user_name}},

Your identity verification has been approved. Your profile now shows a verified badge!

View profile: https://ailanguagecoach.com/tutor-dashboard',
'["user_name"]'::jsonb,
true, true, 'Sent when tutor identity verification passes'),

-- 30. Tutor Verification Rejected
('Tutor Verification Rejected', 'tutor-verification-rejected', 'tutor',
'Your verification needs attention',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Verification Needs Attention</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Hi {{user_name}},</p>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Your identity verification could not be completed.</p>
<div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:20px;margin:24px 0;">
<p style="margin:0;font-size:14px;color:#991b1b;"><strong>Reason:</strong> {{rejection_reason}}</p>
</div>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">Please update your documents and try again.</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://ailanguagecoach.com/tutor-documents" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Update Documents</a>
</div>
</div>
</body></html>',
'Verification Needs Attention

Hi {{user_name}},

Your identity verification could not be completed.

Reason: {{rejection_reason}}

Please update your documents and try again.

Update documents: https://ailanguagecoach.com/tutor-documents',
'["user_name","rejection_reason"]'::jsonb,
true, true, 'Sent when tutor identity verification fails'),

-- ─── ADMIN EMAILS ────────────────────────────────────

-- 31. New Premium Purchase (Admin)
('New Premium Purchase', 'admin-new-purchase', 'admin',
'New purchase: {{user_name}} bought {{plan_name}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">New Premium Purchase</h1>
<div style="background:#f0f9ff;border:1px solid #bfdbfe;border-radius:12px;padding:20px;margin:24px 0;">
<table style="width:100%;font-size:14px;color:#1e40af;">
<tr><td style="padding:4px 0;">User:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{user_name}}</td></tr>
<tr><td style="padding:4px 0;">Plan:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{plan_name}}</td></tr>
<tr><td style="padding:4px 0;">Amount:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{amount}}</td></tr>
</table>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://admin.ailanguagecoach.com/subscriptions" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View in Admin</a>
</div>
</div>
</body></html>',
'New Premium Purchase

User: {{user_name}}
Plan: {{plan_name}}
Amount: {{amount}}

View in admin: https://admin.ailanguagecoach.com/subscriptions',
'["user_name","plan_name","amount"]'::jsonb,
true, true, 'Sent to admins on every premium purchase'),

-- 32. Manual Payment Pending (Admin)
('Manual Payment Pending', 'admin-manual-payment-pending', 'admin',
'Manual payment awaiting verification - {{amount}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Manual Payment Pending</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;">A new manual payment requires verification.</p>
<div style="background:#fffbeb;border:1px solid #fde68a;border-radius:12px;padding:20px;margin:24px 0;">
<table style="width:100%;font-size:14px;color:#92400e;">
<tr><td style="padding:4px 0;">User:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{user_name}}</td></tr>
<tr><td style="padding:4px 0;">Amount:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{amount}}</td></tr>
<tr><td style="padding:4px 0;">Method:</td><td style="padding:4px 0;text-align:right;">{{payment_method}}</td></tr>
<tr><td style="padding:4px 0;">UTR:</td><td style="padding:4px 0;text-align:right;">{{utr_number}}</td></tr>
</table>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://admin.ailanguagecoach.com/payments" style="background:#f59e0b;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Review Payment</a>
</div>
</div>
</body></html>',
'Manual Payment Pending

A new manual payment requires verification.

User: {{user_name}}
Amount: {{amount}}
Method: {{payment_method}}
UTR: {{utr_number}}

Review payment: https://admin.ailanguagecoach.com/payments',
'["user_name","amount","payment_method","utr_number"]'::jsonb,
true, true, 'Sent to admins when a manual payment is submitted'),

-- 33. Fraud Alert (Admin)
('Fraud Alert', 'admin-fraud-alert', 'admin',
'Fraud Alert: {{alert_type}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#ef4444;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:28px;">&#9888;</div>
</div>
<h1 style="color:#ef4444;font-size:24px;text-align:center;">Fraud Alert</h1>
<div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:20px;margin:24px 0;">
<table style="width:100%;font-size:14px;color:#991b1b;">
<tr><td style="padding:4px 0;">Type:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{alert_type}}</td></tr>
<tr><td style="padding:4px 0;">User:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{user_name}}</td></tr>
<tr><td style="padding:4px 0;">Details:</td><td style="padding:4px 0;text-align:right;">{{details}}</td></tr>
</table>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://admin.ailanguagecoach.com/audit-logs" style="background:#ef4444;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Investigate</a>
</div>
</div>
</body></html>',
'Fraud Alert

Type: {{alert_type}}
User: {{user_name}}
Details: {{details}}

Investigate: https://admin.ailanguagecoach.com/audit-logs',
'["user_name","alert_type","details"]'::jsonb,
true, true, 'Sent to admins on suspicious activity'),

-- 34. Tutor Waiting Approval (Admin)
('Tutor Waiting Approval', 'admin-tutor-waiting', 'admin',
'Tutor application awaiting review: {{tutor_name}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Tutor Application Pending</h1>
<p style="font-size:16px;color:#1e293b;line-height:1.6;"><strong>{{tutor_name}}</strong> submitted a tutor application on <strong>{{application_date}}</strong> and is waiting for review.</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://admin.ailanguagecoach.com/tutors" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">Review Application</a>
</div>
</div>
</body></html>',
'Tutor Application Pending

{{tutor_name}} submitted a tutor application on {{application_date}} and is waiting for review.

Review application: https://admin.ailanguagecoach.com/tutors',
'["tutor_name","application_date"]'::jsonb,
true, true, 'Sent when a tutor application has been pending for 48h'),

-- 35. Critical System Error (Admin)
('Critical System Error', 'admin-critical-error', 'admin',
'CRITICAL: {{error_type}} in {{service}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<div style="text-align:center;margin-bottom:24px;">
<div style="background:#ef4444;color:#ffffff;width:64px;height:64px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:28px;">&#9888;</div>
</div>
<h1 style="color:#ef4444;font-size:24px;text-align:center;">Critical System Error</h1>
<div style="background:#fef2f2;border:1px solid #fecaca;border-radius:12px;padding:20px;margin:24px 0;">
<table style="width:100%;font-size:14px;color:#991b1b;">
<tr><td style="padding:4px 0;">Service:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{service}}</td></tr>
<tr><td style="padding:4px 0;">Error Type:</td><td style="padding:4px 0;text-align:right;font-weight:600;">{{error_type}}</td></tr>
<tr><td style="padding:4px 0;">Message:</td><td style="padding:4px 0;text-align:right;">{{error_message}}</td></tr>
</table>
</div>
<div style="text-align:center;margin:32px 0;">
<a href="https://admin.ailanguagecoach.com/infrastructure" style="background:#ef4444;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Infrastructure</a>
</div>
</div>
</body></html>',
'CRITICAL: {{error_type}} in {{service}}

Error Type: {{error_type}}
Service: {{service}}
Message: {{error_message}}

View infrastructure: https://admin.ailanguagecoach.com/infrastructure',
'["service","error_type","error_message"]'::jsonb,
true, true, 'Sent on critical system errors'),

-- 36. Daily Business Report (Admin)
('Daily Business Report', 'admin-daily-report', 'admin',
'Daily Report for {{date}}',
'<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;">
<div style="max-width:600px;margin:0 auto;padding:32px;">
<h1 style="color:#1e293b;font-size:24px;margin-bottom:16px;">Daily Business Report</h1>
<p style="font-size:14px;color:#64748b;margin-bottom:24px;">{{date}}</p>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:24px 0;">
<div style="background:#f0f9ff;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:24px;font-weight:700;color:#2563eb;">{{new_users}}</div>
<div style="font-size:12px;color:#64748b;">New Users</div>
</div>
<div style="background:#f0fdf4;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:24px;font-weight:700;color:#22c55e;">{{active_users}}</div>
<div style="font-size:12px;color:#64748b;">Active Users</div>
</div>
<div style="background:#fefce8;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:24px;font-weight:700;color:#eab308;">{{revenue}}</div>
<div style="font-size:12px;color:#64748b;">Revenue</div>
</div>
<div style="background:#fdf4ff;border-radius:8px;padding:16px;text-align:center;">
<div style="font-size:24px;font-weight:700;color:#a855f7;">{{ai_cost}}</div>
<div style="font-size:12px;color:#64748b;">AI Cost</div>
</div>
</div>
<p style="font-size:14px;color:#64748b;text-align:center;">Emails sent today: {{emails_sent}}</p>
<div style="text-align:center;margin:32px 0;">
<a href="https://admin.ailanguagecoach.com/dashboard" style="background:#2563eb;color:#ffffff;padding:14px 32px;border-radius:8px;text-decoration:none;font-weight:600;font-size:16px;">View Dashboard</a>
</div>
</div>
</body></html>',
'Daily Business Report - {{date}}

New Users: {{new_users}}
Active Users: {{active_users}}
Revenue: {{revenue}}
AI Cost: {{ai_cost}}
Emails Sent: {{emails_sent}}

View dashboard: https://admin.ailanguagecoach.com/dashboard',
'["date","new_users","active_users","revenue","ai_cost","emails_sent"]'::jsonb,
true, true, 'Sent daily at 6 AM to all admins');
