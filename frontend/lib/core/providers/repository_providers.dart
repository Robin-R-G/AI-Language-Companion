import 'package:riverpod_annotation/riverpod_annotation.dart';
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
import '../../features/mock_exam/data/repositories/mock_exam_repository_impl.dart';
import '../../features/mock_exam/domain/repositories/mock_exam_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import '../../features/vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../features/voice/data/repositories/voice_repository_impl.dart';
import '../../features/voice/domain/repositories/voice_repository.dart';
import '../network/dio_client.dart';

part 'repository_providers.g.dart';

@riverpod
DioClient dioClient(DioClientRef ref) {
  return DioClient();
}

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(supabase);
}

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatRepositoryImpl(dioClient: dioClient);
}

@riverpod
LessonRepository lessonRepository(LessonRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LessonRepositoryImpl(dioClient: dioClient);
}

@riverpod
VocabularyRepository vocabularyRepository(VocabularyRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VocabularyRepositoryImpl(dioClient: dioClient);
}

@riverpod
VoiceRepository voiceRepository(VoiceRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VoiceRepositoryImpl(dioClient: dioClient);
}

@riverpod
AchievementRepository achievementRepository(AchievementRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AchievementRepositoryImpl(dioClient: dioClient);
}

@riverpod
MockExamRepository mockExamRepository(MockExamRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MockExamRepositoryImpl(dioClient: dioClient);
}

@riverpod
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SubscriptionRepositoryImpl(dioClient: dioClient);
}

@riverpod
GrammarRepository grammarRepository(GrammarRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GrammarRepositoryImpl(dioClient: dioClient);
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileRepositoryImpl(dioClient: dioClient);
}
