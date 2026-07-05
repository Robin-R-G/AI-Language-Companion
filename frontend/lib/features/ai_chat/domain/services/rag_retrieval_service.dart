// lib/features/ai_chat/domain/services/rag_retrieval_service.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/memory_engine.dart';

part 'rag_retrieval_service.g.dart';

class RAGResult {
  final String id;
  final String type;
  final String content;
  final double relevance;
  final Map<String, dynamic>? metadata;

  RAGResult({
    required this.id,
    required this.type,
    required this.content,
    required this.relevance,
    this.metadata,
  });
}

@riverpod
class RAGRetrievalService extends _$RAGRetrievalService {
  @override
  RAGRetrievalService build() {
    return RAGRetrievalService();
  }

  Future<List<RAGResult>> retrieve({
    required String userId,
    required String query,
    String? context,
    int limit = 5,
  }) async {
    final results = <RAGResult>[];

    // 1. Search conversation history
    final conversationResults = await _searchConversations(userId, query, limit: 3);
    results.addAll(conversationResults);

    // 2. Search vocabulary
    final vocabularyResults = await _searchVocabulary(userId, query, limit: 3);
    results.addAll(vocabularyResults);

    // 3. Search lesson content
    final lessonResults = await _searchLessons(userId, query, limit: 2);
    results.addAll(lessonResults);

    // 4. Search grammar rules
    final grammarResults = await _searchGrammar(userId, query, limit: 2);
    results.addAll(grammarResults);

    // Sort by relevance and limit
    results.sort((a, b) => b.relevance.compareTo(a.relevance));
    return results.take(limit).toList();
  }

  Future<List<RAGResult>> _searchConversations(
    String userId,
    String query, {
    int limit = 3,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('chat_messages')
          .select('id, content, role, created_at')
          .eq('user_id', userId)
          .textSearch('content', query, type: TextSearchType.websearch)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((item) {
        return RAGResult(
          id: item['id'],
          type: 'conversation',
          content: item['content'],
          relevance: 0.8,
          metadata: {
            'role': item['role'],
            'timestamp': item['created_at'],
          },
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RAGResult>> _searchVocabulary(
    String userId,
    String query, {
    int limit = 3,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('vocabulary')
          .select('id, word, definition, example')
          .eq('user_id', userId)
          .or('word.ilike.%$query%,definition.ilike.%$query%')
          .limit(limit);

      return (response as List).map((item) {
        return RAGResult(
          id: item['id'],
          type: 'vocabulary',
          content: '${item['word']}: ${item['definition']}',
          relevance: 0.9,
          metadata: {
            'word': item['word'],
            'example': item['example'],
          },
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RAGResult>> _searchLessons(
    String userId,
    String query, {
    int limit = 2,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('lessons')
          .select('id, title, content, topic')
          .textSearch('title', query, type: TextSearchType.websearch)
          .limit(limit);

      return (response as List).map((item) {
        final content = item['content'];
        final description = content is Map ? content['introduction'] ?? '' : '';
        return RAGResult(
          id: item['id'],
          type: 'lesson',
          content: '${item['title']}: $description',
          relevance: 0.7,
          metadata: {
            'topic': item['topic'],
          },
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RAGResult>> _searchGrammar(
    String userId,
    String query, {
    int limit = 2,
  }) async {
    // Search for grammar-related content in user's progress
    try {
      final response = await Supabase.instance.client
          .from('user_progress')
          .select('grammar_score, vocabulary_score')
          .eq('user_id', userId)
          .single();

      // This is a simplified example - in production, you'd have a grammar rules table
      return [];
    } catch (e) {
      return [];
    }
  }

  String buildContextString(List<RAGResult> results) {
    if (results.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('Relevant context from your learning history:');

    for (final result in results) {
      buffer.writeln('\n[${result.type.toUpperCase()}]');
      buffer.writeln(result.content);
      if (result.metadata != null) {
        result.metadata!.forEach((key, value) {
          if (value != null && key != 'timestamp') {
            buffer.writeln('  $key: $value');
          }
        });
      }
    }

    return buffer.toString();
  }
}
