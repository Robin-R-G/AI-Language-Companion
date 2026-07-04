import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/ai_chat/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'msg_001',
        'role': 'user',
        'content': 'Hello, how are you?',
        'timestamp': '2026-07-04T10:00:00Z',
        'grammarFeedback': {
          'isCorrect': false,
          'original': 'Yesterday I go school.',
          'corrected': 'Yesterday I went to school.',
          'explanation': 'Past tense required.',
          'explanationMalayalam': 'Past tense വിശദീകരണം',
          'category': 'Tense',
          'examples': ['I went to school yesterday.'],
        },
        'translation': {
          'translation': 'നമസ്കാരം, എങ്ങനെയുണ്ട്?',
          'pronunciation': 'Namaskaram, enganeyundu?',
          'alternativeExpressions': {'casual': 'Hi!', 'formal': 'Good day!'},
          'explanation': 'Common greeting',
        },
        'tokenCount': 25,
        'latencyMs': 500,
      };

      final message = ChatMessage.fromJson(json);
      expect(message.id, equals('msg_001'));
      expect(message.role, equals('user'));
      expect(message.content, equals('Hello, how are you?'));
      expect(message.grammarFeedback, isNotNull);
      expect(message.grammarFeedback!.isCorrect, isFalse);
      expect(
        message.grammarFeedback!.original,
        equals('Yesterday I go school.'),
      );
      expect(message.translation, isNotNull);
      expect(
        message.translation!.translation,
        equals('നമസ്കാരം, എങ്ങനെയുണ്ട്?'),
      );
      expect(message.tokenCount, equals(25));
      expect(message.latencyMs, equals(500));
    });

    test('fromJson with minimal fields', () {
      final json = {'id': 'msg_002', 'role': 'assistant', 'content': 'Hello!'};

      final message = ChatMessage.fromJson(json);
      expect(message.id, equals('msg_002'));
      expect(message.role, equals('assistant'));
      expect(message.content, equals('Hello!'));
      expect(message.timestamp, isNull);
      expect(message.grammarFeedback, isNull);
      expect(message.translation, isNull);
      expect(message.tokenCount, isNull);
      expect(message.latencyMs, isNull);
    });

    test('serialization roundtrip', () {
      final original = ChatMessage(
        id: 'msg_003',
        role: 'user',
        content: 'Test message',
        tokenCount: 10,
      );

      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.role, equals(original.role));
      expect(restored.content, equals(original.content));
      expect(restored.tokenCount, equals(original.tokenCount));
    });
  });

  group('GrammarFeedback', () {
    test('has correct defaults', () {
      const feedback = GrammarFeedback(
        original: 'test',
        corrected: 'test',
        explanation: 'test',
      );

      expect(feedback.isCorrect, isFalse);
      expect(feedback.explanationMalayalam, equals(''));
      expect(feedback.category, equals(''));
      expect(feedback.examples, isEmpty);
    });

    test('fromJson with all fields', () {
      final json = {
        'isCorrect': true,
        'original': 'I am correct.',
        'corrected': 'I am correct.',
        'explanation': 'No errors found.',
        'explanationMalayalam': '',
        'category': 'None',
        'examples': ['This is correct.'],
      };

      final feedback = GrammarFeedback.fromJson(json);
      expect(feedback.isCorrect, isTrue);
      expect(feedback.examples.length, equals(1));
    });
  });

  group('TranslationData', () {
    test('has correct defaults', () {
      const translation = TranslationData(translation: 'test');

      expect(translation.pronunciation, equals(''));
      expect(translation.alternativeExpressions, isNull);
      expect(translation.explanation, equals(''));
    });

    test('fromJson with all fields', () {
      final json = {
        'translation': 'Malayalam text',
        'pronunciation': '/prəˌnʌnsiˈeɪʃən/',
        'alternativeExpressions': {'casual': 'Hi', 'formal': 'Hello'},
        'explanation': 'Usage note',
      };

      final translation = TranslationData.fromJson(json);
      expect(translation.translation, equals('Malayalam text'));
      expect(translation.alternativeExpressions, isA<Map<String, String>>());
    });
  });
}
