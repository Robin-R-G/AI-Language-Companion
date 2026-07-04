/*
====================================================
AI Language Coach
Supabase Production Schema
Version: 1.0
Last Updated: July 2026
====================================================
*/

-- Enable Extensions
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

----------------------------------------------------
-- USER PROFILES
----------------------------------------------------

create table public.user_profiles (
    id uuid primary key default gen_random_uuid(),
    auth_user_id uuid not null unique references auth.users(id) on delete cascade,

    full_name text,
    avatar_url text,

    native_language text not null,
    target_language text not null,

    proficiency_level text,
    target_exam text,

    timezone text,

    onboarding_completed boolean default false,

    xp integer default 0,
    level integer default 1,

    streak integer default 0,

    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

----------------------------------------------------
-- USER GOALS
----------------------------------------------------

create table public.user_goals (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id) on delete cascade,
    daily_goal_minutes integer,
    weekly_goal_minutes integer,
    target_exam_score numeric,
    reminder_time time,
    created_at timestamptz default now()
);

----------------------------------------------------
-- LESSONS
----------------------------------------------------

create table public.lessons (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    description text,
    language text,
    category text,
    difficulty text,
    estimated_minutes integer,
    xp_reward integer,
    created_at timestamptz default now()
);

----------------------------------------------------
-- LESSON PROGRESS
----------------------------------------------------

create table public.lesson_progress (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    lesson_id uuid references lessons(id),
    completion_percentage integer,
    earned_xp integer,
    mistakes integer,
    started_at timestamptz,
    completed_at timestamptz
);

----------------------------------------------------
-- AI CONVERSATIONS
----------------------------------------------------

create table public.ai_conversations (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    title text,
    provider text,
    model text,
    created_at timestamptz default now()
);

----------------------------------------------------
-- CHAT MESSAGES
----------------------------------------------------

create table public.chat_messages (
    id uuid primary key default gen_random_uuid(),
    conversation_id uuid references ai_conversations(id) on delete cascade,
    role text,
    content text,
    grammar_feedback jsonb,
    translation jsonb,
    token_count integer,
    latency_ms integer,
    created_at timestamptz default now()
);

----------------------------------------------------
-- VOCABULARY
----------------------------------------------------

create table public.vocabulary (
    id uuid primary key default gen_random_uuid(),
    word text,
    meaning text,
    pronunciation text,
    examples jsonb,
    cefr_level text
);

----------------------------------------------------
-- VOCABULARY HISTORY
----------------------------------------------------

create table public.vocabulary_history (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    vocabulary_id uuid references vocabulary(id),
    mastery_level integer,
    review_count integer,
    next_review timestamptz,
    updated_at timestamptz default now()
);

----------------------------------------------------
-- VOICE SESSIONS
----------------------------------------------------

create table public.voice_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    provider text,
    room_id text,
    duration integer,
    transcript text,
    pronunciation_score numeric,
    fluency_score numeric,
    created_at timestamptz default now()
);

----------------------------------------------------
-- MOCK EXAMS
----------------------------------------------------

create table public.mock_exams (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    exam_type text,
    section text,
    estimated_score numeric,
    feedback jsonb,
    created_at timestamptz default now()
);

----------------------------------------------------
-- AI MEMORY
----------------------------------------------------

create table public.ai_memory (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    key text,
    value jsonb,
    created_at timestamptz default now()
);

----------------------------------------------------
-- SUBSCRIPTIONS
----------------------------------------------------

create table public.subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    provider text,
    plan text,
    status text,
    renewal_date timestamptz,
    expires_at timestamptz
);

----------------------------------------------------
-- PAYMENTS
----------------------------------------------------

create table public.payments (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    transaction_id text,
    amount numeric,
    currency text,
    platform text,
    status text,
    created_at timestamptz default now()
);

----------------------------------------------------
-- ACHIEVEMENTS
----------------------------------------------------

create table public.achievements (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    badge text,
    title text,
    xp_reward integer,
    unlocked_at timestamptz default now()
);

----------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------

create table public.notifications (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    title text,
    body text,
    type text,
    is_read boolean default false,
    created_at timestamptz default now()
);

----------------------------------------------------
-- ANALYTICS EVENTS
----------------------------------------------------

create table public.analytics_events (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references user_profiles(id),
    event_name text,
    properties jsonb,
    created_at timestamptz default now()
);

----------------------------------------------------
-- INDEXES
----------------------------------------------------

create index idx_profile_auth
on user_profiles(auth_user_id);

create index idx_messages_conversation
on chat_messages(conversation_id);

create index idx_voice_user
on voice_sessions(user_id);

create index idx_lesson_user
on lesson_progress(user_id);

create index idx_vocab_user
on vocabulary_history(user_id);

create index idx_events_user
on analytics_events(user_id);

----------------------------------------------------
-- UPDATED_AT TRIGGER
----------------------------------------------------

create or replace function public.update_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger update_user_profile_timestamp
before update on user_profiles
for each row
execute procedure update_updated_at();

----------------------------------------------------
-- ROW LEVEL SECURITY
----------------------------------------------------

alter table user_profiles enable row level security;
alter table user_goals enable row level security;
alter table lesson_progress enable row level security;
alter table ai_conversations enable row level security;
alter table chat_messages enable row level security;
alter table vocabulary_history enable row level security;
alter table voice_sessions enable row level security;
alter table mock_exams enable row level security;
alter table ai_memory enable row level security;
alter table subscriptions enable row level security;
alter table payments enable row level security;
alter table achievements enable row level security;
alter table notifications enable row level security;
alter table analytics_events enable row level security;

----------------------------------------------------
-- SAMPLE RLS POLICY
----------------------------------------------------

create policy "Users manage own profile"
on user_profiles
for all
using (auth.uid() = auth_user_id)
with check (auth.uid() = auth_user_id);

-- Similar user-owned policies should be created for each table.

----------------------------------------------------
-- OPTIONAL SEED DATA
----------------------------------------------------

insert into lessons
(title, description, language, category, difficulty, estimated_minutes, xp_reward)
values
('English Basics', 'Introduction to everyday English.', 'English', 'Grammar', 'Beginner', 15, 100),
('German A1 Greetings', 'Learn common greetings.', 'German', 'Vocabulary', 'Beginner', 20, 120);
