import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

// Supabase Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseAuth extends Mock implements GoTrueClient {}
class MockSupabaseQuery extends Mock implements PostgrestQueryBuilder {}
class MockSupabaseResponse extends Mock implements PostgrestResponse {}

// Routing Mocks
class MockGoRouter extends Mock implements GoRouter {}

// Network Mocks
class MockDio extends Mock implements Dio {}
class MockResponse<T> extends Mock implements Response<T> {}

// Feature Mocks (Uncomment as feature repos are implemented)
// class MockAuthRepository extends Mock implements AuthRepository {}
// class MockChatRepository extends Mock implements ChatRepository {}
// class MockLessonRepository extends Mock implements LessonRepository {}
// class MockVocabularyRepository extends Mock implements VocabularyRepository {}
// class MockProgressRepository extends Mock implements ProgressRepository {}
