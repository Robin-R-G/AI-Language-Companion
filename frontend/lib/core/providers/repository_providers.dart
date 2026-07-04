import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/achievements/data/repositories/achievement_repository_impl.dart';
import '../../features/achievements/domain/repositories/achievement_repository.dart';
import '../../features/ai_chat/data/repositories/chat_repository_impl.dart';
import '../../features/ai_chat/domain/repositories/chat_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/grammar/data/repositories/grammar_repository_impl.dart';
import '../../features/grammar/domain/repositories/grammar_repository.dart';
import '../../features/lessons/data/repositories/lesson_repository_impl.dart';
import '../../features/lessons/domain/repositories/lesson_repository.dart';
import '../../features/listening/data/repositories/listening_repository_impl.dart';
import '../../features/listening/domain/repositories/listening_repository.dart';
import '../../features/mock_exam/data/repositories/mock_exam_repository_impl.dart';
import '../../features/mock_exam/domain/repositories/mock_exam_repository.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import '../../features/reading/data/repositories/reading_repository_impl.dart';
import '../../features/reading/domain/repositories/reading_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import '../../features/vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../features/voice/data/repositories/voice_repository_impl.dart';
import '../../features/voice/domain/repositories/voice_repository.dart';
import '../../features/writing/data/repositories/writing_repository_impl.dart';
import '../../features/writing/domain/repositories/writing_repository.dart';
import '../network/dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(supabase);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatRepositoryImpl(dioClient: dioClient);
});

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LessonRepositoryImpl(dioClient: dioClient);
});

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VocabularyRepositoryImpl(dioClient: dioClient);
});

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VoiceRepositoryImpl(dioClient: dioClient);
});

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AchievementRepositoryImpl(dioClient: dioClient);
});

final mockExamRepositoryProvider = Provider<MockExamRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MockExamRepositoryImpl(dioClient: dioClient);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SubscriptionRepositoryImpl(dioClient: dioClient);
});

final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GrammarRepositoryImpl(dioClient: dioClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileRepositoryImpl(dioClient: dioClient);
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProgressRepositoryImpl(dioClient: dioClient);
});

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReadingRepositoryImpl(dioClient: dioClient);
});

final writingRepositoryProvider = Provider<WritingRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WritingRepositoryImpl(dioClient: dioClient);
});

final listeningRepositoryProvider = Provider<ListeningRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ListeningRepositoryImpl(dioClient: dioClient);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SettingsRepositoryImpl(dioClient: dioClient);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationsRepositoryImpl(dioClient: dioClient);
});
