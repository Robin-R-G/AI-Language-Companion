import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/vocabulary/domain/entities/vocabulary_word.dart';

void main() {
  group('VocabularyWord', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'vocab_001',
        'word': 'Ephemeral',
        'meaning': 'Lasting for a very short time.',
        'meaningMalayalam': 'ശാശ്വതമല്ലാത്ത',
        'pronunciation': '/ɪˈfɛmərəl/',
        'examples': ['The ephemeral beauty of cherry blossoms.'],
        'cefrLevel': 'C1',
        'masteryLevel': 3,
        'reviewCount': 5,
        'nextReview': '2026-07-10T08:00:00Z',
        'lastReviewed': '2026-07-04T08:00:00Z',
      };

      final word = VocabularyWord.fromJson(json);
      expect(word.id, equals('vocab_001'));
      expect(word.word, equals('Ephemeral'));
      expect(word.meaning, equals('Lasting for a very short time.'));
      expect(word.meaningMalayalam, equals('ശാശ്വതമല്ലാത്ത'));
      expect(word.pronunciation, equals('/ɪˈfɛmərəl/'));
      expect(word.examples.length, equals(1));
      expect(word.cefrLevel, equals('C1'));
      expect(word.masteryLevel, equals(3));
      expect(word.reviewCount, equals(5));
      expect(word.nextReview, isNotNull);
      expect(word.lastReviewed, isNotNull);
    });

    test('fromJson with minimal fields', () {
      final json = {
        'id': 'vocab_002',
        'word': 'Test',
        'meaning': 'A test word.',
      };

      final word = VocabularyWord.fromJson(json);
      expect(word.id, equals('vocab_002'));
      expect(word.word, equals('Test'));
      expect(word.meaning, equals('A test word.'));
      expect(word.meaningMalayalam, equals(''));
      expect(word.pronunciation, equals(''));
      expect(word.examples, isEmpty);
      expect(word.cefrLevel, equals(''));
      expect(word.masteryLevel, equals(0));
      expect(word.reviewCount, equals(0));
      expect(word.nextReview, isNull);
      expect(word.lastReviewed, isNull);
    });

    test('serialization roundtrip', () {
      final original = VocabularyWord(
        id: 'vocab_003',
        word: 'Ubiquitous',
        meaning: 'Present everywhere.',
        cefrLevel: 'C1',
        masteryLevel: 4,
      );

      final json = original.toJson();
      final restored = VocabularyWord.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.word, equals(original.word));
      expect(restored.meaning, equals(original.meaning));
      expect(restored.cefrLevel, equals(original.cefrLevel));
      expect(restored.masteryLevel, equals(original.masteryLevel));
    });

    test('creates with factory constructor', () {
      const word = VocabularyWord(
        id: 'test',
        word: 'Hello',
        meaning: 'A greeting',
      );

      expect(word.id, equals('test'));
      expect(word.word, equals('Hello'));
    });
  });
}
