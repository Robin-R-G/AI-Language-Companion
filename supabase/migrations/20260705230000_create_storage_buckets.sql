-- Migration: 20260705230000_create_storage_buckets.sql
-- Creates storage buckets and policies per implementation guide

-- ─── Storage Buckets ────────────────────────────────────────────────────────
-- Note: Buckets are created via Supabase Dashboard or API
-- This migration creates the RLS policies for storage

-- ─── Avatars Bucket Policies ────────────────────────────────────────────────
-- Public read, authenticated write, owner delete

CREATE POLICY "Avatar public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Avatar authenticated insert"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Avatar owner update"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Avatar owner delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ─── Voice Recordings Bucket Policies ───────────────────────────────────────
-- Private, owner-only access

CREATE POLICY "Voice recordings owner select"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'voice-recordings'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Voice recordings authenticated insert"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'voice-recordings'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Voice recordings owner delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'voice-recordings'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ─── Lesson Images Bucket Policies ──────────────────────────────────────────
-- Public read, admin write

CREATE POLICY "Lesson images public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'lesson-images');

CREATE POLICY "Lesson images authenticated insert"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'lesson-images'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Lesson images admin delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'lesson-images'
  AND EXISTS (
    SELECT 1 FROM user_profiles
    WHERE auth_user_id = auth.uid()
    AND role = 'admin'
  )
);

-- ─── Exam Assets Bucket Policies ────────────────────────────────────────────
-- Private, owner and admin access

CREATE POLICY "Exam assets owner select"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'exam-assets'
  AND (
    auth.uid()::text = (storage.foldername(name))[1]
    OR EXISTS (
      SELECT 1 FROM user_profiles
      WHERE auth_user_id = auth.uid()
      AND role = 'admin'
    )
  )
);

CREATE POLICY "Exam assets authenticated insert"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'exam-assets'
  AND auth.role() = 'authenticated'
);

-- ─── Certificates Bucket Policies ───────────────────────────────────────────
-- Private, owner-only access

CREATE POLICY "Certificates owner select"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'certificates'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Certificates authenticated insert"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'certificates'
  AND auth.role() = 'authenticated'
);

-- ─── Exports Bucket Policies ────────────────────────────────────────────────
-- Private, owner-only access with expiration

CREATE POLICY "Exports owner select"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'exports'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Exports authenticated insert"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'exports'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Exports owner delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'exports'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ─── Temporary Bucket Policies ──────────────────────────────────────────────
-- Private, owner-only access, auto-cleanup

CREATE POLICY "Temporary owner select"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'temporary'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Temporary authenticated insert"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'temporary'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Temporary owner delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'temporary'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ─── Storage Cleanup Function ───────────────────────────────────────────────
-- Cleans up temporary files older than 24 hours

CREATE OR REPLACE FUNCTION cleanup_temporary_storage()
RETURNS void AS $$
BEGIN
  DELETE FROM storage.objects
  WHERE bucket_id = 'temporary'
  AND created_at < now() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Storage Quota Check Function ───────────────────────────────────────────
-- Checks if user has exceeded storage quota

CREATE OR REPLACE FUNCTION check_storage_quota(
  p_user_id UUID,
  p_bucket_id TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  total_size BIGINT;
  quota_limit BIGINT;
BEGIN
  -- Get total size of user's files in bucket
  SELECT COALESCE(SUM(metadata->>'size')::BIGINT, 0)
  INTO total_size
  FROM storage.objects
  WHERE bucket_id = p_bucket_id
  AND auth.uid()::text = (storage.foldername(name))[1];

  -- Set quota based on bucket
  CASE p_bucket_id
    WHEN 'avatars' THEN quota_limit := 52428800; -- 50MB
    WHEN 'voice-recordings' THEN quota_limit := 524288000; -- 500MB
    WHEN 'exports' THEN quota_limit := 104857600; -- 100MB
    ELSE quota_limit := 104857600; -- 100MB default
  END CASE;

  RETURN total_size < quota_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
