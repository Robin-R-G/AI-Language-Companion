-- 20260704000001_rls_policies_and_auth_trigger.sql

----------------------------------------------------
-- PROFILE RESOLVER HELPER FUNCTION
----------------------------------------------------

create or replace function public.current_user_profile_id()
returns uuid
security definer
language sql
stable
as $$
    select id from public.user_profiles where auth_user_id = auth.uid();
$$;

----------------------------------------------------
-- AUTHENTICATION TRIGGER SYNCHRONIZATION
----------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
security definer
language plpgsql
as $$
declare
    profile_id uuid;
begin
    insert into public.user_profiles (
        auth_user_id,
        full_name,
        avatar_url,
        native_language,
        target_language,
        proficiency_level,
        onboarding_completed
    )
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'full_name', ''),
        coalesce(new.raw_user_meta_data->>'avatar_url', ''),
        coalesce(new.raw_user_meta_data->>'native_language', 'Malayalam'),
        coalesce(new.raw_user_meta_data->>'target_language', 'English'),
        'Beginner',
        false
    )
    returning id into profile_id;

    insert into public.user_goals (
        user_id,
        daily_goal_minutes,
        weekly_goal_minutes,
        target_exam_score
    )
    values (
        profile_id,
        15,
        105,
        0
    );

    return new;
end;
$$;

create or replace trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

----------------------------------------------------
-- ROW LEVEL SECURITY POLICIES
----------------------------------------------------

-- user_goals policies
create policy "Users manage own goals"
on user_goals
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- lesson_progress policies
create policy "Users manage own lesson progress"
on lesson_progress
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- ai_conversations policies
create policy "Users manage own ai conversations"
on ai_conversations
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- chat_messages policies
create policy "Users manage own chat messages"
on chat_messages
for all
to authenticated
using (
    conversation_id in (
        select id from public.ai_conversations 
        where user_id = public.current_user_profile_id()
    )
)
with check (
    conversation_id in (
        select id from public.ai_conversations 
        where user_id = public.current_user_profile_id()
    )
);

-- vocabulary_history policies
create policy "Users manage own vocabulary history"
on vocabulary_history
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- voice_sessions policies
create policy "Users manage own voice sessions"
on voice_sessions
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- mock_exams policies
create policy "Users manage own mock exams"
on mock_exams
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- ai_memory policies
create policy "Users manage own ai memory"
on ai_memory
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- subscriptions policies
create policy "Users view own subscriptions"
on subscriptions
for select
to authenticated
using (user_id = public.current_user_profile_id());

-- payments policies
create policy "Users view own payments"
on payments
for select
to authenticated
using (user_id = public.current_user_profile_id());

-- achievements policies
create policy "Users view own achievements"
on achievements
for select
to authenticated
using (user_id = public.current_user_profile_id());

-- notifications policies
create policy "Users manage own notifications"
on notifications
for all
to authenticated
using (user_id = public.current_user_profile_id())
with check (user_id = public.current_user_profile_id());

-- analytics_events policies
create policy "Users insert own analytics events"
on analytics_events
for insert
to authenticated
with check (user_id = public.current_user_profile_id());

-- lessons policies (Read-only for all users)
create policy "Users read lessons"
on lessons
for select
to authenticated
using (true);

-- vocabulary policies (Read-only for all users)
create policy "Users read vocabulary"
on vocabulary
for select
to authenticated
using (true);
