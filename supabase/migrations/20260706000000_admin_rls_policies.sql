-- Migration: 20260706000000_admin_rls_policies.sql
-- Enables full access for admin users on all system tables

-- Helper function to check if the current user is an admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE auth_user_id = auth.uid()
      AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Admin Policies for User Profiles ───────────────────────────────────────
CREATE POLICY "Admins have full access on user_profiles"
  ON public.user_profiles FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for User Goals ──────────────────────────────────────────
CREATE POLICY "Admins have full access on user_goals"
  ON public.user_goals FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Lessons ─────────────────────────────────────────────
CREATE POLICY "Admins have full access on lessons"
  ON public.lessons FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Lesson Progress ──────────────────────────────────────
CREATE POLICY "Admins have full access on lesson_progress"
  ON public.lesson_progress FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for AI Conversations ─────────────────────────────────────
CREATE POLICY "Admins have full access on ai_conversations"
  ON public.ai_conversations FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Chat Messages ────────────────────────────────────────
CREATE POLICY "Admins have full access on chat_messages"
  ON public.chat_messages FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Vocabulary ──────────────────────────────────────────
CREATE POLICY "Admins have full access on vocabulary"
  ON public.vocabulary FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Vocabulary History ───────────────────────────────────
CREATE POLICY "Admins have full access on vocabulary_history"
  ON public.vocabulary_history FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Voice Sessions ───────────────────────────────────────
CREATE POLICY "Admins have full access on voice_sessions"
  ON public.voice_sessions FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Exam Attempts ────────────────────────────────────────
CREATE POLICY "Admins have full access on exam_attempts"
  ON public.exam_attempts FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Exam Scores ──────────────────────────────────────────
CREATE POLICY "Admins have full access on exam_scores"
  ON public.exam_scores FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Exam Feedback ────────────────────────────────────────
CREATE POLICY "Admins have full access on exam_feedback"
  ON public.exam_feedback FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for AI Memory ────────────────────────────────────────────
CREATE POLICY "Admins have full access on ai_memory"
  ON public.ai_memory FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Subscriptions ────────────────────────────────────────
CREATE POLICY "Admins have full access on subscriptions"
  ON public.subscriptions FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Payments ─────────────────────────────────────────────
CREATE POLICY "Admins have full access on payments"
  ON public.payments FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Achievements ──────────────────────────────────────────
CREATE POLICY "Admins have full access on achievements"
  ON public.achievements FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Notifications ────────────────────────────────────────
CREATE POLICY "Admins have full access on notifications"
  ON public.notifications FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Analytics Events ─────────────────────────────────────
CREATE POLICY "Admins have full access on analytics_events"
  ON public.analytics_events FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for User Settings ────────────────────────────────────────
CREATE POLICY "Admins have full access on user_settings"
  ON public.user_settings FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for User Preferences ─────────────────────────────────────
CREATE POLICY "Admins have full access on user_preferences"
  ON public.user_preferences FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Grammar Topics ───────────────────────────────────────
CREATE POLICY "Admins have full access on grammar_topics"
  ON public.grammar_topics FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Writing Tasks ────────────────────────────────────────
CREATE POLICY "Admins have full access on writing_tasks"
  ON public.writing_tasks FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Notification Preferences ─────────────────────────────
CREATE POLICY "Admins have full access on notification_preferences"
  ON public.notification_preferences FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Invoices ─────────────────────────────────────────────
CREATE POLICY "Admins have full access on invoices"
  ON public.invoices FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Premium Features ─────────────────────────────────────
CREATE POLICY "Admins have full access on premium_features"
  ON public.premium_features FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Languages ────────────────────────────────────────────
CREATE POLICY "Admins have full access on languages"
  ON public.languages FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for CEFR Levels ──────────────────────────────────────────
CREATE POLICY "Admins have full access on cefr_levels"
  ON public.cefr_levels FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Lesson Categories ────────────────────────────────────
CREATE POLICY "Admins have full access on lesson_categories"
  ON public.lesson_categories FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Vocabulary Categories ────────────────────────────────
CREATE POLICY "Admins have full access on vocabulary_categories"
  ON public.vocabulary_categories FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for System Roles ─────────────────────────────────────────
CREATE POLICY "Admins have full access on system_roles"
  ON public.system_roles FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Notification Templates ──────────────────────────────
CREATE POLICY "Admins have full access on notification_templates"
  ON public.notification_templates FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Reading Lessons ──────────────────────────────────────
CREATE POLICY "Admins have full access on reading_lessons"
  ON public.reading_lessons FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Listening Lessons ────────────────────────────────────
CREATE POLICY "Admins have full access on listening_lessons"
  ON public.listening_lessons FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Admin Policies for Assessments ──────────────────────────────────────────
CREATE POLICY "Admins have full access on assessments"
  ON public.assessments FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ─── Audit Triggers for Core Admin Actions ───────────────────────────────────

-- Trigger for auditing lessons CRUD
CREATE OR REPLACE FUNCTION audit_lessons_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM log_audit_event(
      auth.uid(),
      'lesson_created',
      'lessons',
      NEW.id,
      NULL,
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'UPDATE' THEN
    PERFORM log_audit_event(
      auth.uid(),
      'lesson_updated',
      'lessons',
      NEW.id,
      to_jsonb(OLD),
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM log_audit_event(
      auth.uid(),
      'lesson_deleted',
      'lessons',
      OLD.id,
      to_jsonb(OLD),
      NULL
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_lessons_changes_trig
  AFTER INSERT OR UPDATE OR DELETE ON public.lessons
  FOR EACH ROW
  EXECUTE FUNCTION audit_lessons_changes();

-- Trigger for auditing vocabulary CRUD
CREATE OR REPLACE FUNCTION audit_vocabulary_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM log_audit_event(
      auth.uid(),
      'vocabulary_created',
      'vocabulary',
      NEW.id,
      NULL,
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'UPDATE' THEN
    PERFORM log_audit_event(
      auth.uid(),
      'vocabulary_updated',
      'vocabulary',
      NEW.id,
      to_jsonb(OLD),
      to_jsonb(NEW)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM log_audit_event(
      auth.uid(),
      'vocabulary_deleted',
      'vocabulary',
      OLD.id,
      to_jsonb(OLD),
      NULL
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_vocabulary_changes_trig
  AFTER INSERT OR UPDATE OR DELETE ON public.vocabulary
  FOR EACH ROW
  EXECUTE FUNCTION audit_vocabulary_changes();
