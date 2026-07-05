-- Migration: 20260705220000_add_extensions.sql
-- Adds PostgreSQL extensions per strategy document

-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enable pg_trgm for text search (trigram matching)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Enable unaccent for removing accents from text
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Enable pgvector for vector similarity search (if needed for AI features)
-- Note: pgvector requires the extension to be installed in Supabase
-- Uncomment if pgvector is available:
-- CREATE EXTENSION IF NOT EXISTS vector;

-- ─── Full-Text Search Setup ─────────────────────────────────────────────────

-- Create a function for unaccent search
CREATE OR REPLACE FUNCTION unaccent_search(text)
RETURNS text AS $$
  SELECT unaccent($1);
$$ LANGUAGE sql IMMUTABLE;

-- Create GIN index for vocabulary full-text search
CREATE INDEX IF NOT EXISTS idx_vocabulary_word_trgm
  ON vocabulary USING gin (word gin_trgm_ops);

-- Create GIN index for lessons full-text search
CREATE INDEX IF NOT EXISTS idx_lessons_title_trgm
  ON lessons USING gin (title gin_trgm_ops);

-- Create GIN index for grammar topics full-text search
CREATE INDEX IF NOT EXISTS idx_grammar_topics_title_trgm
  ON grammar_topics USING gin (title gin_trgm_ops);

-- ─── Vector Search Setup (Optional) ─────────────────────────────────────────
-- Uncomment if pgvector is available and needed for AI features

-- ALTER TABLE vocabulary ADD COLUMN IF NOT EXISTS embedding vector(1536);
-- CREATE INDEX IF NOT EXISTS idx_vocabulary_embedding
--   ON vocabulary USING ivfflat (embedding vector_cosine_ops)
--   WITH (lists = 100);

-- ALTER TABLE ai_memory ADD COLUMN IF NOT EXISTS embedding vector(1536);
-- CREATE INDEX IF NOT EXISTS idx_ai_memory_embedding
--   ON ai_memory USING ivfflat (embedding vector_cosine_ops)
--   WITH (lists = 100);
