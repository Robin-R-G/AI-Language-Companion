import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ai_language_coach/features/achievements/domain/repositories/achievement_repository.dart';
import 'package:ai_language_coach/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:ai_language_coach/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_language_coach/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:ai_language_coach/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:ai_language_coach/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:ai_language_coach/features/profile/domain/repositories/profile_repository.dart';
import 'package:ai_language_coach/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:ai_language_coach/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:ai_language_coach/features/voice/domain/repositories/voice_repository.dart';

// ─── Dio Mocks ───────────────────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

class MockResponse<T> extends Mock implements Response<T> {}

class MockRequestOptions extends Mock implements RequestOptions {}

class MockDioException extends Mock implements DioException {}

// ─── Supabase Mocks ──────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseAuth extends Mock implements GoTrueClient {}

class MockSupabaseDatabase extends Mock implements SupabaseQueryBuilder {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<dynamic> {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockAuthResponse extends Mock implements AuthResponse {}

// ─── Feature Repository Mocks ────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockLessonRepository extends Mock implements LessonRepository {}

class MockVocabularyRepository extends Mock implements VocabularyRepository {}

class MockVoiceRepository extends Mock implements VoiceRepository {}

class MockAchievementRepository extends Mock implements AchievementRepository {}

class MockMockExamRepository extends Mock implements MockExamRepository {}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockGrammarRepository extends Mock implements GrammarRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

// ─── Register Fallback Values ────────────────────────────────────────────────

void registerFallbackValues() {
  registerFallbackValue(RequestOptions());
  registerFallbackValue(const Duration(seconds: 10));
}
