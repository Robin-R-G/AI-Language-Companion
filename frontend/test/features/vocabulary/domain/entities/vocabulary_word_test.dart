import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/vocabulary/domain/entities/vocabulary_word.dart';

void main() {
  group('VocabularyWord', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'vocab_001',
        'word': 'Ephemeral',
        'meaning': 'Lasting for a very short time.',
        'pronunciation': '/ɪˈfɛmərəl/',
        'examples': ['The ephemeral beauty of cherry blossoms.'],
        'cefrLevel': 'C1',
        'partOfSpeech': 'adjective',
        'targetLanguage': 'en',
        'nativeLanguage': 'ml',
      };

      final word = VocabularyWord.fromJson(json);
      expect(word.id, equals('vocab_001'));
      expect(word.word, equals('Ephemeral'));
      expect(word.meaning, equals('Lasting for a very short time.'));
      expect(word.pronunciation, equals('/ɪˈfɛmərəl/'));
      expect(word.examples.length, equals(1));
      expect(word.cefrLevel, equals('C1'));
      expect(word.partOfSpeech, equals('adjective'));
      expect(word.targetLanguage, equals('en'));
      expect(word.nativeLanguage, equals('ml'));
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
      expect(word.pronunciation, equals(''));
      expect(word.examples, isEmpty);
      expect(word.cefrLevel, equals(''));
      expect(word.partOfSpeech, equals(''));
      expect(word.targetLanguage, equals(''));
      expect(word.nativeLanguage, equals(''));
    });

    test('serialization roundtrip', () {
      final original = VocabularyWord(
        id: 'vocab_003',
        word: 'Ubiquitous',
        meaning: 'Present everywhere.',
        pronunciation: '',
        examples: [],
        cefrLevel: 'C1',
        partOfSpeech: '',
        targetLanguage: 'en',
        nativeLanguage: 'ml',
        audioUrl: null,
        imageUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final json = original.toJson();
      final restored = VocabularyWord.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.word, equals(original.word));
      expect(restored.meaning, equals(original.meaning));
      expect(restored.cefrLevel, equals(original.cefrLevel));
      expect(restored.partOfSpeech, equals(original.partOfSpeech));
      expect(restored.targetLanguage, equals(original.targetLanguage));
      expect(restored.nativeLanguage, equals(original.nativeLanguage));
    });

    test('creates with factory constructor', () {
      final now = DateTime(2026);
      final word = VocabularyWord(
        id: 'test',
        word: 'Hello',
        meaning: 'A greeting',
        pronunciation: '',
        examples: [],
        cefrLevel: '',
        partOfSpeech: '',
        targetLanguage: 'en',
        nativeLanguage: 'ml',
        audioUrl: null,
        imageUrl: null,
        createdAt: now,
        updatedAt: now,
      );

      expect(word.id, equals('test'));
      expect(word.word, equals('Hello'));
      expect(word.meaning, equals('A greeting'));
    });
  });
}
