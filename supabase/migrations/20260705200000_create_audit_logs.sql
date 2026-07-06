-- Migration: 20260705200000_create_audit_logs.sql
-- Creates audit_logs table for tracking important events

ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';

-- ─── Audit Logs ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(auth_user_id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Audit logs should be immutable - no UPDATE or DELETE policies
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can read audit logs
CREATE POLICY "Admins can view audit logs"
  ON audit_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE auth_user_id = auth.uid()
        AND role = 'admin'
    )
  );

-- System can insert audit logs (via security definer function)
CREATE POLICY "System can insert audit logs"
  ON audit_logs FOR INSERT
  WITH CHECK (true);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ─── Audit Log Function ─────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION log_audit_event(
  p_user_id UUID,
  p_action VARCHAR,
  p_entity_type VARCHAR,
  p_entity_id UUID DEFAULT NULL,
  p_old_values JSONB DEFAULT NULL,
  p_new_values JSONB DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  log_id UUID;
BEGIN
  INSERT INTO audit_logs (
    user_id, action, entity_type, entity_id,
    old_values, new_values, ip_address, user_agent
  ) VALUES (
    p_user_id, p_action, p_entity_type, p_entity_id,
    p_old_values, p_new_values, p_ip_address, p_user_agent
  )
  RETURNING id INTO log_id;

  RETURN log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Audit Triggers ─────────────────────────────────────────────────────────

-- Profile changes audit
CREATE OR REPLACE FUNCTION audit_profile_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    PERFORM log_audit_event(
      NEW.auth_user_id,
      'profile_updated',
      'user_profiles',
      NEW.id,
      to_jsonb(OLD),
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM log_audit_event(
      OLD.auth_user_id,
      'profile_deleted',
      'user_profiles',
      OLD.id,
      to_jsonb(OLD),
      NULL
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_user_profiles
  AFTER UPDATE OR DELETE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION audit_profile_changes();

-- Subscription changes audit
CREATE OR REPLACE FUNCTION audit_subscription_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    PERFORM log_audit_event(
      NEW.user_id,
      'subscription_updated',
      'subscriptions',
      NEW.id,
      to_jsonb(OLD),
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'INSERT' THEN
    PERFORM log_audit_event(
      NEW.user_id,
      'subscription_created',
      'subscriptions',
      NEW.id,
      NULL,
      to_jsonb(NEW)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_subscriptions
  AFTER INSERT OR UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION audit_subscription_changes();

-- AI Memory changes audit
CREATE OR REPLACE FUNCTION audit_ai_memory_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM log_audit_event(
      NEW.user_id,
      'ai_memory_created',
      'ai_memory',
      NEW.id,
      NULL,
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM log_audit_event(
      OLD.user_id,
      'ai_memory_deleted',
      'ai_memory',
      OLD.id,
      to_jsonb(OLD),
      NULL
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_ai_memory
  AFTER INSERT OR DELETE ON ai_memory
  FOR EACH ROW
  EXECUTE FUNCTION audit_ai_memory_changes();
