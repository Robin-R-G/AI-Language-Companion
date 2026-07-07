import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/user_role.dart';

// ── Models ────────────────────────────────────────────────────────────────────

enum AiProvider { openAi, anthropic, gemini, groq, omniRoute }

class AiRequest {
  const AiRequest({
    required this.prompt,
    required this.feature,
    this.language = 'en',
    this.systemPrompt,
    this.maxTokens = 1024,
    this.temperature = 0.7,
    this.stream = false,
    this.creditCost = 1,
  });

  final String prompt;
  final String feature; // 'chat', 'grammar', 'vocabulary', 'writing', 'speaking', 'exam'
  final String language;
  final String? systemPrompt;
  final int maxTokens;
  final double temperature;
  final bool stream;
  final int creditCost;
}

class AiResponse {
  const AiResponse({
    required this.content,
    required this.provider,
    required this.creditsUsed,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.error,
  });

  final String content;
  final AiProvider provider;
  final int creditsUsed;
  final int promptTokens;
  final int completionTokens;
  final String? error;

  bool get hasError => error != null;
}

// ── Gateway ───────────────────────────────────────────────────────────────────

/// Central AI Gateway that:
/// • Routes to the best available provider
/// • Deducts credits from the user's wallet
/// • Logs usage to Supabase for cost tracking
/// • Supports streaming responses
/// • Falls back to secondary provider on failure
class AiGateway {
  AiGateway._();
  static final AiGateway instance = AiGateway._();

  final SupabaseClient _client = Supabase.instance.client;

  // ── Single-shot request ──────────────────────────────────────────────────

  Future<AiResponse> complete(AiRequest request) async {
    // 1. Check credits
    final balance = await _getCredits();
    if (balance < request.creditCost) {
      return AiResponse(
        content: '',
        provider: AiProvider.openAi,
        creditsUsed: 0,
        error: 'Insufficient credits. Please top up your wallet.',
      );
    }

    // 2. Call Supabase AI gateway edge function
    try {
      final response = await _client.functions.invoke(
        'ai-gateway',
        body: {
          'prompt': request.prompt,
          'feature': request.feature,
          'language': request.language,
          if (request.systemPrompt != null)
            'system_prompt': request.systemPrompt,
          'max_tokens': request.maxTokens,
          'temperature': request.temperature,
          'credit_cost': request.creditCost,
        },
      );

      if (response.status != 200) {
        throw Exception('AI gateway error: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as String? ?? '';
      final providerStr = data['provider'] as String? ?? 'openai';
      final creditsUsed = data['credits_used'] as int? ?? request.creditCost;

      return AiResponse(
        content: content,
        provider: _parseProvider(providerStr),
        creditsUsed: creditsUsed,
        promptTokens: data['prompt_tokens'] as int? ?? 0,
        completionTokens: data['completion_tokens'] as int? ?? 0,
      );
    } catch (e) {
      return AiResponse(
        content: '',
        provider: AiProvider.openAi,
        creditsUsed: 0,
        error: e.toString(),
      );
    }
  }

  // ── Streaming request ────────────────────────────────────────────────────

  Stream<String> stream(AiRequest request) async* {
    final balance = await _getCredits();
    if (balance < request.creditCost) {
      yield '[Error: Insufficient credits]';
      return;
    }

    try {
      // Use Supabase realtime channels for streaming via edge function
      final channel = _client.channel('ai-stream-${DateTime.now().millisecondsSinceEpoch}');

      final completer = Completer<void>();
      final buffer = StreamController<String>();

      channel.onBroadcast(
        event: 'chunk',
        callback: (payload) {
          final chunk = payload['text'] as String? ?? '';
          buffer.add(chunk);
        },
      ).onBroadcast(
        event: 'done',
        callback: (payload) {
          buffer.close();
          completer.complete();
        },
      ).subscribe();

      // Trigger the stream via edge function
      unawaited(_client.functions.invoke(
        'ai-gateway',
        body: {
          'prompt': request.prompt,
          'feature': request.feature,
          'language': request.language,
          if (request.systemPrompt != null)
            'system_prompt': request.systemPrompt,
          'max_tokens': request.maxTokens,
          'temperature': request.temperature,
          'credit_cost': request.creditCost,
          'stream': true,
          'channel': channel.topic,
        },
      ));

      yield* buffer.stream;
      await completer.future;
      await _client.removeChannel(channel);
    } catch (e) {
      yield '[Error: $e]';
    }
  }

  // ── Quick helpers for each feature ──────────────────────────────────────

  Future<AiResponse> checkGrammar(String text, {String language = 'en'}) {
    return complete(AiRequest(
      prompt: text,
      feature: 'grammar',
      language: language,
      systemPrompt:
          'You are an expert grammar teacher. Identify grammar mistakes, explain each one clearly, and provide the corrected version. Respond in JSON: {"mistakes": [...], "corrected": "...", "score": 0-100}',
      creditCost: 1,
    ));
  }

  Future<AiResponse> explainVocabulary(String word, {String language = 'en'}) {
    return complete(AiRequest(
      prompt: 'Explain the word: $word',
      feature: 'vocabulary',
      language: language,
      systemPrompt:
          'You are a vocabulary expert. Provide definition, pronunciation, example sentences, synonyms, antonyms, and usage tips. Respond in JSON format.',
      creditCost: 1,
    ));
  }

  Future<AiResponse> evaluateWriting(String essay,
      {String examType = 'ielts', String language = 'en'}) {
    return complete(AiRequest(
      prompt: essay,
      feature: 'writing',
      language: language,
      systemPrompt:
          'You are a certified $examType writing examiner. Score this essay on Task Achievement, Coherence, Lexical Resource, and Grammar (0-9 IELTS scale). Provide detailed feedback. Respond in JSON: {"scores": {...}, "overall": 0, "feedback": {...}, "improved_version": "..."}',
      maxTokens: 2048,
      creditCost: 3,
    ));
  }

  Future<AiResponse> evaluateSpeaking(String transcript,
      {String language = 'en'}) {
    return complete(AiRequest(
      prompt: transcript,
      feature: 'speaking',
      language: language,
      systemPrompt:
          'You are a speaking coach. Evaluate fluency, pronunciation, vocabulary, grammar, and coherence. Respond in JSON: {"scores": {...}, "overall": 0, "feedback": {...}, "suggestions": [...]}',
      creditCost: 2,
    ));
  }

  Future<AiResponse> chat(String message,
      {String? systemPrompt, String language = 'en'}) {
    return complete(AiRequest(
      prompt: message,
      feature: 'chat',
      language: language,
      systemPrompt: systemPrompt ??
          'You are an AI language coach. Help the student improve their language skills through conversation. Be encouraging, correct mistakes gently, and provide explanations when needed.',
      creditCost: 1,
    ));
  }

  // ── Internals ────────────────────────────────────────────────────────────

  Future<int> _getCredits() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final response = await _client
          .from('wallets')
          .select('ai_credits')
          .eq('user_id', user.id)
          .maybeSingle();

      return (response?['ai_credits'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  AiProvider _parseProvider(String value) {
    switch (value) {
      case 'anthropic':
        return AiProvider.anthropic;
      case 'gemini':
        return AiProvider.gemini;
      case 'groq':
        return AiProvider.groq;
      case 'omniroute':
        return AiProvider.omniRoute;
      case 'openai':
      default:
        return AiProvider.openAi;
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final aiGatewayProvider = Provider<AiGateway>((ref) {
  return AiGateway.instance;
});
