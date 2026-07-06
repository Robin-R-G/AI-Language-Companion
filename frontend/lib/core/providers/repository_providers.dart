// lib/core/providers/repository_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/grammar/data/repositories/grammar_repository_impl.dart';
import '../../features/grammar/domain/repositories/grammar_repository.dart';
import '../../features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import '../../features/vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../features/lessons/data/repositories/lessons_repository_impl.dart';
import '../../features/lessons/domain/repositories/lessons_repository.dart';
import '../../features/listening/data/repositories/listening_repository_impl.dart';
import '../../features/listening/domain/repositories/listening_repository.dart';
import '../../features/reading/data/repositories/reading_repository_impl.dart';
import '../../features/reading/domain/repositories/reading_repository.dart';
import '../../features/writing/data/repositories/writing_repository_impl.dart';
import '../../features/writing/domain/repositories/writing_repository.dart';
import '../../features/voice/data/repositories/voice_repository_impl.dart';
import '../../features/voice/domain/repositories/voice_repository.dart';
import '../../features/mock_exam/data/repositories/mock_exam_repository_impl.dart';
import '../../features/mock_exam/domain/repositories/mock_exam_repository.dart';
import '../../features/achievements/data/repositories/achievement_repository_impl.dart';
import '../../features/achievements/domain/repositories/achievement_repository.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/ai_chat/data/repositories/chat_repository_impl.dart';
import '../../features/ai_chat/domain/repositories/chat_repository.dart';

part 'repository_providers.g.dart';

// ─── Auth ────────────────────────────────────────────────────────────────────

@riverpod
AuthRepository authRepositoryInst(AuthRepositoryInstRef ref) {
  return AuthRepositoryImpl();
}

// ─── Profile ─────────────────────────────────────────────────────────────────

@riverpod
ProfileRepository profileRepositoryInst(ProfileRepositoryInstRef ref) {
  return ProfileRepositoryImpl();
}

// ─── Grammar ─────────────────────────────────────────────────────────────────

@riverpod
GrammarRepository grammarRepository(GrammarRepositoryRef ref) {
  return GrammarRepositoryImpl();
}

// ─── Vocabulary ──────────────────────────────────────────────────────────────

@riverpod
VocabularyRepository vocabularyRepository(VocabularyRepositoryRef ref) {
  return VocabularyRepositoryImpl();
}

// ─── Lessons ─────────────────────────────────────────────────────────────────

@riverpod
LessonsRepository lessonsRepository(LessonsRepositoryRef ref) {
  return LessonsRepositoryImpl();
}

// ─── Listening ───────────────────────────────────────────────────────────────

@riverpod
ListeningRepository listeningRepository(ListeningRepositoryRef ref) {
  return ListeningRepositoryImpl();
}

// ─── Reading ─────────────────────────────────────────────────────────────────

@riverpod
ReadingRepository readingRepository(ReadingRepositoryRef ref) {
  return ReadingRepositoryImpl();
}

// ─── Writing ─────────────────────────────────────────────────────────────────

@riverpod
WritingRepository writingRepository(WritingRepositoryRef ref) {
  return WritingRepositoryImpl();
}

// ─── Voice ───────────────────────────────────────────────────────────────────

@riverpod
VoiceRepository voiceRepository(VoiceRepositoryRef ref) {
  return VoiceRepositoryImpl();
}

// ─── Mock Exam ───────────────────────────────────────────────────────────────

@riverpod
MockExamRepository mockExamRepository(MockExamRepositoryRef ref) {
  return MockExamRepositoryImpl();
}

// ─── Achievements ────────────────────────────────────────────────────────────

@riverpod
AchievementRepository achievementRepository(AchievementRepositoryRef ref) {
  return AchievementRepositoryImpl();
}

// ─── Notifications ───────────────────────────────────────────────────────────

@riverpod
NotificationsRepository notificationsRepository(NotificationsRepositoryRef ref) {
  return NotificationsRepositoryImpl();
}

// ─── Progress ────────────────────────────────────────────────────────────────

@riverpod
ProgressRepository progressRepository(ProgressRepositoryRef ref) {
  return ProgressRepositoryImpl();
}

// ─── Settings ────────────────────────────────────────────────────────────────

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SettingsRepositoryImpl();
}

// ─── Subscription ────────────────────────────────────────────────────────────

@riverpod
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  return SubscriptionRepositoryImpl();
}

// ─── Chat ────────────────────────────────────────────────────────────────────

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepositoryImpl();
}
