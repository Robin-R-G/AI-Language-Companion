-- 20260704000002_composite_indexes_and_cascades.sql
-- Adds composite indexes for common query patterns and cascade deletes

ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';

----------------------------------------------------
-- COMPOSITE INDEXES
----------------------------------------------------

create index if not exists idx_messages_conversation_created
on chat_messages(conversation_id, created_at);

create index if not exists idx_lesson_progress_user_completed
on lesson_progress(user_id, completed_at);

create index if not exists idx_vocab_user_next_review
on vocabulary_history(user_id, next_review);

create index if not exists idx_achievements_user_unlocked
on achievements(user_id, unlocked_at);

create index if not exists idx_voice_user_created
on voice_sessions(user_id, created_at);

create index if not exists idx_notifications_user_read
on notifications(user_id, is_read, created_at);

create index if not exists idx_mock_exams_user_created
on mock_exams(user_id, created_at);

create index if not exists idx_analytics_events_user_created
on analytics_events(user_id, created_at);

----------------------------------------------------
-- UPDATED_AT TRIGGERS FOR REMAINING TABLES
----------------------------------------------------

create trigger update_user_goals_timestamp
before update on user_goals
for each row
execute procedure update_updated_at();

create trigger update_vocabulary_history_timestamp
before update on vocabulary_history
for each row
execute procedure update_updated_at();

----------------------------------------------------
-- CASCADE DELETES FOR ORPHANED RECORDS
----------------------------------------------------

alter table lesson_progress
drop constraint if exists lesson_progress_lesson_id_fkey,
add constraint lesson_progress_lesson_id_fkey
foreign key (lesson_id) references lessons(id) on delete cascade;

alter table vocabulary_history
drop constraint if exists vocabulary_history_vocabulary_id_fkey,
add constraint vocabulary_history_vocabulary_id_fkey
foreign key (vocabulary_id) references vocabulary(id) on delete cascade;

alter table ai_conversations
drop constraint if exists ai_conversations_user_id_fkey,
add constraint ai_conversations_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table voice_sessions
drop constraint if exists voice_sessions_user_id_fkey,
add constraint voice_sessions_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table mock_exams
drop constraint if exists mock_exams_user_id_fkey,
add constraint mock_exams_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table subscriptions
drop constraint if exists subscriptions_user_id_fkey,
add constraint subscriptions_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table payments
drop constraint if exists payments_user_id_fkey,
add constraint payments_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table achievements
drop constraint if exists achievements_user_id_fkey,
add constraint achievements_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table notifications
drop constraint if exists notifications_user_id_fkey,
add constraint notifications_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table analytics_events
drop constraint if exists analytics_events_user_id_fkey,
add constraint analytics_events_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;

alter table user_goals
drop constraint if exists user_goals_user_id_fkey,
add constraint user_goals_user_id_fkey
foreign key (user_id) references user_profiles(id) on delete cascade;
