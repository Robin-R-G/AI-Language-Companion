-- Migration: 20260705250000_create_user_profile_flow_triggers.sql
-- Creates complete user profile flow triggers per implementation guide

-- ─── Enhanced User Creation Trigger ─────────────────────────────────────────
-- Handles complete user initialization on registration

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
  profile_id UUID;
  default_language TEXT;
BEGIN
  -- Extract language from metadata or default to Malayalam
  default_language := COALESCE(new.raw_user_meta_data->>'native_language', 'Malayalam');

  -- Step 1: Create user profile
  INSERT INTO public.user_profiles (
    auth_user_id,
    full_name,
    avatar_url,
    native_language,
    target_language,
    proficiency_level,
    onboarding_completed
  )
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'avatar_url', ''),
    default_language,
    COALESCE(new.raw_user_meta_data->>'target_language', 'English'),
    'Beginner',
    false
  )
  RETURNING id INTO profile_id;

  -- Step 2: Create user goals
  INSERT INTO public.user_goals (
    user_id,
    daily_goal_minutes,
    weekly_goal_minutes,
    target_exam_score
  )
  VALUES (
    profile_id,
    15,
    105,
    0
  );

  -- Step 3: Create user settings
  INSERT INTO public.user_settings (
    user_id,
    theme,
    language,
    sound_enabled,
    notifications_enabled
  )
  VALUES (
    new.id,
    'light',
    'en',
    true,
    true
  );

  -- Step 4: Create user preferences
  INSERT INTO public.user_preferences (
    user_id,
    learning_style,
    preferred_study_time,
    daily_reminder,
    lesson_reminders
  )
  VALUES (
    new.id,
    'visual',
    'morning',
    true,
    true
  );

  -- Step 5: Create user progress
  INSERT INTO public.user_progress (
    user_id,
    xp,
    level,
    grammar_score,
    speaking_score,
    writing_score,
    vocabulary_score,
    reading_score,
    listening_score
  )
  VALUES (
    new.id,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0
  );

  -- Step 6: Initialize streak
  INSERT INTO public.streaks (
    user_id,
    current_streak,
    longest_streak,
    last_active_date
  )
  VALUES (
    new.id,
    0,
    0,
    CURRENT_DATE
  );

  -- Step 7: Create notification preferences
  INSERT INTO public.notification_preferences (
    user_id,
    email_notifications,
    push_notifications,
    lesson_reminders,
    streak_reminders,
    achievement_alerts
  )
  VALUES (
    new.id,
    true,
    true,
    true,
    true,
    true
  );

  -- Step 8: Log the event
  PERFORM log_audit_event(
    new.id,
    'user_registered',
    'user_profiles',
    profile_id,
    NULL,
    jsonb_build_object(
      'email', new.email,
      'full_name', COALESCE(new.raw_user_meta_data->>'full_name', ''),
      'native_language', default_language
    )
  );

  RETURN new;
END;
$$;

-- ─── User Deletion Cleanup Trigger ──────────────────────────────────────────
-- Handles cleanup when user is deleted

CREATE OR REPLACE FUNCTION handle_user_deletion()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Log the deletion event
  PERFORM log_audit_event(
    OLD.auth_user_id,
    'user_deleted',
    'user_profiles',
    OLD.id,
    jsonb_build_object(
      'email', (SELECT email FROM auth.users WHERE id = OLD.auth_user_id),
      'full_name', OLD.full_name
    ),
    NULL
  );

  -- Note: CASCADE deletes will handle most cleanup
  -- This function handles any additional logic needed

  RETURN OLD;
END;
$$;

-- ─── Onboarding Completion Trigger ──────────────────────────────────────────
-- Updates user progress when onboarding is completed

CREATE OR REPLACE FUNCTION handle_onboarding_completion()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Only run if onboarding_completed changed from false to true
  IF OLD.onboarding_completed = false AND NEW.onboarding_completed = true THEN
    -- Award XP for completing onboarding
    PERFORM award_xp(
      NEW.auth_user_id,
      100,
      'onboarding',
      NEW.id,
      'Completed onboarding'
    );

    -- Create notification
    INSERT INTO notifications (user_id, title, body, type)
    VALUES (
      NEW.auth_user_id,
      'Welcome to AI Language Coach!',
      'You''ve completed onboarding and earned 100 XP. Start your learning journey!',
      'success'
    );

    -- Log the event
    PERFORM log_audit_event(
      NEW.auth_user_id,
      'onboarding_completed',
      'user_profiles',
      NEW.id,
      jsonb_build_object('onboarding_completed', false),
      jsonb_build_object('onboarding_completed', true)
    );
  END IF;

  RETURN NEW;
END;
$$;

-- ─── XP Level Update Trigger ────────────────────────────────────────────────
-- Automatically updates user level when XP changes

CREATE OR REPLACE FUNCTION handle_xp_change()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
  old_level INTEGER;
  new_level INTEGER;
BEGIN
  -- Only run if XP changed
  IF OLD.xp != NEW.xp THEN
    old_level := OLD.level;
    new_level := FLOOR(SQRT(NEW.xp / 100)) + 1;

    -- Update level if changed
    IF new_level != old_level THEN
      NEW.level := new_level;

      -- Create level up notification
      INSERT INTO notifications (user_id, title, body, type)
      VALUES (
        NEW.auth_user_id,
        'Level Up!',
        'Congratulations! You''ve reached Level ' || new_level || '!',
        'achievement'
      );

      -- Log the event
      PERFORM log_audit_event(
        NEW.auth_user_id,
        'level_up',
        'user_profiles',
        NEW.id,
        jsonb_build_object('level', old_level, 'xp', OLD.xp),
        jsonb_build_object('level', new_level, 'xp', NEW.xp)
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- ─── Create Triggers ────────────────────────────────────────────────────────

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create new trigger for user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Create trigger for user deletion
DROP TRIGGER IF EXISTS on_auth_user_deleted ON user_profiles;
CREATE TRIGGER on_auth_user_deleted
  AFTER DELETE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_deletion();

-- Create trigger for onboarding completion
DROP TRIGGER IF EXISTS on_onboarding_completed ON user_profiles;
CREATE TRIGGER on_onboarding_completed
  AFTER UPDATE ON user_profiles
  FOR EACH ROW
  WHEN (OLD.onboarding_completed IS DISTINCT FROM NEW.onboarding_completed)
  EXECUTE FUNCTION handle_onboarding_completion();

-- Create trigger for XP changes
DROP TRIGGER IF EXISTS on_xp_changed ON user_profiles;
CREATE TRIGGER on_xp_changed
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  WHEN (OLD.xp IS DISTINCT FROM NEW.xp)
  EXECUTE FUNCTION handle_xp_change();

-- ─── Daily Progress Tracking Trigger ────────────────────────────────────────
-- Automatically tracks daily progress

CREATE OR REPLACE FUNCTION track_daily_lesson_progress()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Only run when lesson is completed
  IF NEW.completed_at IS NOT NULL AND OLD.completed_at IS NULL THEN
    -- Update daily progress
    PERFORM track_daily_progress(
      NEW.user_id,
      COALESCE(NEW.earned_xp, 0),
      1,
      0,
      0
    );

    -- Update streak
    PERFORM calculate_streak(NEW.user_id);

    -- Check for badges
    PERFORM check_and_award_badges();
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger for lesson progress
DROP TRIGGER IF EXISTS on_lesson_completed ON lesson_progress;
CREATE TRIGGER on_lesson_completed
  AFTER UPDATE ON lesson_progress
  FOR EACH ROW
  WHEN (NEW.completed_at IS NOT NULL AND OLD.completed_at IS NULL)
  EXECUTE FUNCTION track_daily_lesson_progress();

-- ─── Vocabulary Progress Tracking Trigger ───────────────────────────────────
-- Automatically tracks vocabulary learning

CREATE OR REPLACE FUNCTION track_vocabulary_learning()
RETURNS trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Update daily progress for vocabulary learning
  PERFORM track_daily_progress(
    NEW.user_id,
    0,
    0,
    1,
    0
  );

  RETURN NEW;
END;
$$;

-- Create trigger for vocabulary history
DROP TRIGGER IF EXISTS on_vocabulary_learned ON vocabulary_history;
CREATE TRIGGER on_vocabulary_learned
  AFTER INSERT ON vocabulary_history
  FOR EACH ROW
  EXECUTE FUNCTION track_vocabulary_learning();
