-- Migration: 20260706010000_monetization_tables.sql
-- Creates complete monetization engine schema (wallets, tutors, bookings, affiliates, reports)

----------------------------------------------------
-- WALLETS & TRANSACTIONS
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.wallet (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES public.wallet(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL,
  type VARCHAR(30) NOT NULL CHECK (type IN ('monthly_grant', 'login_reward', 'lesson_reward', 'streak_reward', 'ad_reward', 'referral_bonus', 'purchase', 'spend', 'refund')),
  reference_id UUID,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- CREDIT PACKAGES
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.credit_packages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  credits_amount INTEGER NOT NULL,
  price_cents INTEGER NOT NULL,
  sku VARCHAR(50) UNIQUE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- REWARD HISTORY
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.reward_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  reward_type VARCHAR(50) NOT NULL,
  credits INTEGER NOT NULL,
  reference_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- REFERRALS
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  referred_email VARCHAR(150) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'joined' CHECK (status IN ('joined', 'studied_7d', 'premium_purchased')),
  reward_credits INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- TUTORS & BOOKINGS
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.tutors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  bio TEXT,
  qualifications TEXT,
  certificates TEXT[] DEFAULT '{}',
  languages TEXT[] DEFAULT '{}',
  exams TEXT[] DEFAULT '{}',
  experience_years INTEGER DEFAULT 0,
  availability JSONB DEFAULT '{}'::jsonb,
  price_per_hour_cents INTEGER NOT NULL DEFAULT 2000,
  rating NUMERIC(3,2) DEFAULT 5.0,
  review_count INTEGER DEFAULT 0,
  intro_video_url TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  tutor_id UUID NOT NULL REFERENCES public.tutors(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  price_paid_cents INTEGER NOT NULL,
  meeting_link TEXT,
  rating INTEGER,
  review TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- AFFILIATE PRODUCTS
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.affiliate_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  category VARCHAR(100) NOT NULL,
  description TEXT,
  image_url TEXT,
  buy_url TEXT UNIQUE NOT NULL,
  commission_percent INTEGER DEFAULT 10,
  price_cents INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.affiliate_clicks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  product_id UUID REFERENCES public.affiliate_products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.affiliate_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.user_profiles(auth_user_id) ON DELETE SET NULL,
  product_id UUID REFERENCES public.affiliate_products(id) ON DELETE CASCADE,
  click_id UUID REFERENCES public.affiliate_clicks(id) ON DELETE SET NULL,
  price_paid_cents INTEGER NOT NULL,
  commission_earned_cents INTEGER NOT NULL,
  status VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- SPONSORED CONTENT
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.sponsored_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sponsor_name VARCHAR(150) NOT NULL,
  type VARCHAR(30) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  image_url TEXT,
  external_link TEXT,
  content_payload JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- CERTIFICATES
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(auth_user_id) ON DELETE CASCADE,
  type VARCHAR(30) NOT NULL,
  title VARCHAR(255) NOT NULL,
  recipient_name VARCHAR(150) NOT NULL,
  grade VARCHAR(10),
  issuer VARCHAR(150) NOT NULL DEFAULT 'AI Language Coach',
  verify_code VARCHAR(50) UNIQUE NOT NULL,
  signature_hash TEXT,
  paid_verification BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- BUSINESS REPORTS
----------------------------------------------------

CREATE TABLE IF NOT EXISTS public.business_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_date DATE NOT NULL UNIQUE,
  mrr_cents INTEGER NOT NULL DEFAULT 0,
  arr_cents INTEGER NOT NULL DEFAULT 0,
  total_subscribers INTEGER NOT NULL DEFAULT 0,
  churn_rate NUMERIC(5,2) DEFAULT 0.0,
  credit_consumption INTEGER NOT NULL DEFAULT 0,
  ai_cost_cents INTEGER NOT NULL DEFAULT 0,
  net_profit_cents INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

----------------------------------------------------
-- WALLET INITIALIZATION TRIGGERS
----------------------------------------------------

CREATE OR REPLACE FUNCTION public.initialize_wallet()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.wallet (user_id, balance)
  VALUES (NEW.auth_user_id, 100)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_profile_created_wallet ON public.user_profiles;
CREATE TRIGGER on_profile_created_wallet
  AFTER INSERT ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.initialize_wallet();

-- Backfill wallets for existing profiles
INSERT INTO public.wallet (user_id, balance)
SELECT auth_user_id, 100 FROM public.user_profiles
ON CONFLICT (user_id) DO NOTHING;

----------------------------------------------------
-- ROW LEVEL SECURITY (RLS) & GRANTS
----------------------------------------------------

ALTER TABLE public.wallet ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliate_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliate_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliate_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sponsored_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_reports ENABLE ROW LEVEL SECURITY;

-- Helper check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin_check()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE auth_user_id = auth.uid()
      AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Wallet Policies
CREATE POLICY "Users can view own wallet" ON public.wallet FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins have full access on wallets" ON public.wallet FOR ALL USING (public.is_admin_check());

-- Wallet Transactions Policies
CREATE POLICY "Users can view own transactions" ON public.wallet_transactions FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.wallet w WHERE w.id = wallet_transactions.wallet_id AND w.user_id = auth.uid()));
CREATE POLICY "Admins have full access on transactions" ON public.wallet_transactions FOR ALL USING (public.is_admin_check());

-- Credit Packages Policies
CREATE POLICY "Anyone can view active credit packages" ON public.credit_packages FOR SELECT USING (is_active = true);
CREATE POLICY "Admins have full access on credit packages" ON public.credit_packages FOR ALL USING (public.is_admin_check());

-- Reward History Policies
CREATE POLICY "Users can view own rewards" ON public.reward_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins have full access on rewards" ON public.reward_history FOR ALL USING (public.is_admin_check());

-- Referrals Policies
CREATE POLICY "Users can view own referrals" ON public.referrals FOR SELECT USING (auth.uid() = referrer_id);
CREATE POLICY "Admins have full access on referrals" ON public.referrals FOR ALL USING (public.is_admin_check());

-- Tutors Policies
CREATE POLICY "Anyone can view verified tutors" ON public.tutors FOR SELECT USING (is_verified = true OR auth.uid() = user_id);
CREATE POLICY "Tutors can update own details" ON public.tutors FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Tutors can insert own details" ON public.tutors FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins have full access on tutors" ON public.tutors FOR ALL USING (public.is_admin_check());

-- Bookings Policies
CREATE POLICY "Users can view own bookings" ON public.bookings FOR SELECT
  USING (auth.uid() = student_id OR EXISTS (SELECT 1 FROM public.tutors t WHERE t.id = bookings.tutor_id AND t.user_id = auth.uid()));
CREATE POLICY "Students can create bookings" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Parties can update booking status" ON public.bookings FOR UPDATE
  USING (auth.uid() = student_id OR EXISTS (SELECT 1 FROM public.tutors t WHERE t.id = bookings.tutor_id AND t.user_id = auth.uid()));
CREATE POLICY "Admins have full access on bookings" ON public.bookings FOR ALL USING (public.is_admin_check());

-- Affiliate Products Policies
CREATE POLICY "Anyone can view active products" ON public.affiliate_products FOR SELECT USING (is_active = true);
CREATE POLICY "Admins have full access on affiliate products" ON public.affiliate_products FOR ALL USING (public.is_admin_check());

-- Affiliate Clicks/Sales Policies
CREATE POLICY "Users can view own clicks" ON public.affiliate_clicks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own clicks" ON public.affiliate_clicks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view own sales" ON public.affiliate_sales FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins have full access on clicks/sales" ON public.affiliate_clicks FOR ALL USING (public.is_admin_check());
CREATE POLICY "Admins have full access on sales" ON public.affiliate_sales FOR ALL USING (public.is_admin_check());

-- Sponsored Content Policies
CREATE POLICY "Anyone can view active sponsored content" ON public.sponsored_content FOR SELECT USING (is_active = true);
CREATE POLICY "Admins have full access on sponsored content" ON public.sponsored_content FOR ALL USING (public.is_admin_check());

-- Certificates Policies
CREATE POLICY "Users can view own certificates" ON public.certificates FOR SELECT USING (auth.uid() = user_id OR paid_verification = true);
CREATE POLICY "Admins have full access on certificates" ON public.certificates FOR ALL USING (public.is_admin_check());

-- Business Reports Policies
CREATE POLICY "Admins can view business reports" ON public.business_reports FOR SELECT USING (public.is_admin_check());
CREATE POLICY "Admins have full access on business reports" ON public.business_reports FOR ALL USING (public.is_admin_check());

-- Schema Role Permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;

----------------------------------------------------
-- SEED MOCK DATA
----------------------------------------------------

-- Seed Credit Packages
INSERT INTO public.credit_packages (name, credits_amount, price_cents, sku) VALUES
('Starter Pack', 100, 499, 'credits_pack_small'),
('Value Pack', 250, 999, 'credits_pack_medium'),
('Power Pack', 600, 1999, 'credits_pack_large'),
('Unlimited Boost', 1500, 3999, 'credits_pack_ultimate')
ON CONFLICT (sku) DO NOTHING;

-- Seed Affiliate Products
INSERT INTO public.affiliate_products (title, category, description, image_url, buy_url, commission_percent, price_cents) VALUES
('Official IELTS Practice Materials', 'Books', 'Comprehensive course guide for academic and general exam tests.', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=150', 'https://amazon.com', 12, 2999),
('Sony Wireless Noise Cancelling Headphones', 'Hardware', 'Superior audio quality with dual microphone technology.', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=150', 'https://bestbuy.com', 8, 14999),
('Cambridge Advanced Learner Dictionary', 'Books', 'Must-have resource for high-level English grammar reference.', 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=150', 'https://amazon.com', 15, 3450),
('Study Abroad Counseling Program', 'Services', 'Complete visa and college guidance for UK, US, and Canada.', 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=150', 'https://studyabroad.org', 5, 49900)
ON CONFLICT (buy_url) DO NOTHING;

-- Seed Sponsored Content
INSERT INTO public.sponsored_content (sponsor_name, type, title, description, image_url, external_link) VALUES
('University of Oxford', 'scholarship', 'Oxford English Honors Program', 'Explore scholarship pathways and degree certifications.', 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=150', 'https://ox.ac.uk'),
('Duolingo English Test', 'exam_referral', 'Official Duolingo Certificate Registration', 'Book your verified online exam with a 10% platform discount.', 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=150', 'https://englishtest.duolingo.com')
ON CONFLICT DO NOTHING;

-- Seed Tutors
INSERT INTO public.tutors (user_id, bio, qualifications, price_per_hour_cents, rating, review_count, is_verified, languages, exams)
SELECT 
  auth_user_id,
  'Hello! I am a certified TEFL tutor with 8 years of experience helping students master English conversation and IELTS exam preparations.',
  'BA in English Literature, TEFL Certified',
  2500,
  4.9,
  14,
  true,
  ARRAY['English', 'Spanish'],
  ARRAY['IELTS', 'TOEFL']
FROM public.user_profiles
LIMIT 1
ON CONFLICT (user_id) DO NOTHING;

-- Seed Business Reports
INSERT INTO public.business_reports (report_date, mrr_cents, arr_cents, total_subscribers, churn_rate, credit_consumption, ai_cost_cents, net_profit_cents) VALUES
(CURRENT_DATE - INTERVAL '30 days', 850000, 10200000, 420, 2.50, 142000, 210000, 640000),
(CURRENT_DATE - INTERVAL '15 days', 920000, 11040000, 460, 2.30, 154000, 230000, 690000),
(CURRENT_DATE, 985000, 11820000, 495, 2.10, 168000, 245000, 740000)
ON CONFLICT (report_date) DO NOTHING;
