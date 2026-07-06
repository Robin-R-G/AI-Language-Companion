import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ai_language_coach/features/lessons/data/repositories/lesson_repository_impl.dart';

void main() {
  group('LessonRepositoryImpl', () {
    test('can be instantiated with default Supabase client', () {
      // Note: This test verifies the repository can be created.
      // Integration tests should verify actual Supabase queries.
      expect(() => LessonRepositoryImpl(), returnsNormally);
    });

    test('constructor accepts optional client parameter', () {
      final client = SupabaseClient('https://test.supabase.co', 'test-key');
      expect(() => LessonRepositoryImpl(client: client), returnsNormally);
    });
  });
}
