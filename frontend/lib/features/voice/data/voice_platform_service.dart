import 'dart:async';
import 'dart:typed_data';
import 'package:livekit_client/livekit_client.dart' as lk hide Platform;
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient, Supabase;

class VoicePlatformService {
  final Dio _dio;
  final SupabaseClient _client;
  lk.Room? _room;
  lk.LocalAudioTrack? _localAudioTrack;
  bool _isConnected = false;
  bool _isMuted = false;

  VoicePlatformService({Dio? dio, SupabaseClient? client})
      : _dio = dio ?? Dio(),
        _client = client ?? Supabase.instance.client;

  bool get isConnected => _isConnected;
  bool get isMuted => _isMuted;
  lk.Room? get room => _room;

  Stream<lk.ParticipantEvent>? get participantEvents =>
      _room?.events.streamCtrl.stream.where((e) => e is lk.ParticipantEvent).cast<lk.ParticipantEvent>();

  Stream<lk.RoomEvent>? get roomEvents => _room?.events.streamCtrl.stream;

  Future<void> connect({
    required String sessionId,
    required String token,
    required String livekitUrl,
  }) async {
    _room = lk.Room();

    _room!.events.listen((event) {
      if (event is lk.RoomConnectedEvent) {
        _isConnected = true;
      } else if (event is lk.RoomDisconnectedEvent) {
        _isConnected = false;
      }
    });

    _room!.events.on<lk.TrackEvent>((event) {
      final subscribedEvent = event as lk.TrackSubscribedEvent?;
      if (subscribedEvent != null) {
        final track = subscribedEvent.track;
        if (track is lk.RemoteAudioTrack) {
          _onRemoteAudioTrack(track);
        }
      }
    });

    await _room!.connect(
      livekitUrl,
      token,
      roomOptions: const lk.RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      ),
    );

    _localAudioTrack = await _createAudioTrack();
    if (_localAudioTrack != null) {
      await _room!.localParticipant?.publishAudioTrack(_localAudioTrack!);
    }
  }

  Future<void> disconnect() async {
    if (_localAudioTrack != null) {
      await _localAudioTrack?.stop();
      _localAudioTrack = null;
    }

    await _room?.disconnect();
    _room?.dispose();
    _room = null;
    _isConnected = false;
    _isMuted = false;
  }

  Future<void> toggleMute() async {
    if (_localAudioTrack == null) return;

    _isMuted = !_isMuted;
    await _localAudioTrack!.mute();
  }

  Future<void> startRecording() async {
    if (_localAudioTrack == null || _isMuted) {
      await toggleMute();
    }
  }

  Future<void> stopRecording() async {
    if (_isMuted) {
      await toggleMute();
    }
  }

  Future<TranscriptionResult> transcribeAudio({
    required Uint8List audioData,
    required String language,
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': MultipartFile.fromBytes(audioData, filename: 'audio.webm'),
        'language': language,
      });

      final response = await _dio.post(
        '/voice-api/transcribe',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_client.auth.currentUser?.id}',
          },
        ),
      );

      if (response.data['success'] == true) {
        return TranscriptionResult.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      return TranscriptionResult(
        text: '',
        confidence: 0,
        language: language,
      );
    } catch (e) {
      return TranscriptionResult(
        text: '',
        confidence: 0,
        language: language,
      );
    }
  }

  Future<PronunciationAnalysis> analyzePronunciation({
    required String transcript,
    required String targetText,
    required String language,
  }) async {
    try {
      final response = await _dio.post(
        '/voice-api/pronunciation',
        data: {
          'transcript': transcript,
          'target': targetText,
          'language': language,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_client.auth.currentUser?.id}',
          },
        ),
      );

      if (response.data['success'] == true) {
        return PronunciationAnalysis.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      return PronunciationAnalysis.empty();
    } catch (e) {
      return PronunciationAnalysis.empty();
    }
  }

  Future<void> speakText({
    required String text,
    required String language,
    String? voiceId,
  }) async {
    try {
      await _dio.post(
        '/voice-api/tts',
        data: {
          'text': text,
          'language': language,
          if (voiceId != null) 'voice_id': voiceId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_client.auth.currentUser?.id}',
          },
        ),
      );
    } catch (e) {
      // TTS failed silently
    }
  }

  Future<lk.LocalAudioTrack> _createAudioTrack() async {
    return lk.LocalAudioTrack.create();
  }

  void _onRemoteAudioTrack(lk.RemoteAudioTrack track) {
    track.start();
  }
}

class TranscriptionResult {
  final String text;
  final double confidence;
  final String language;
  final List<WordTiming>? words;

  const TranscriptionResult({
    required this.text,
    required this.confidence,
    required this.language,
    this.words,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: (json['text'] as String?) ?? '',
      confidence: ((json['confidence'] as num?) ?? 0).toDouble(),
      language: (json['language'] as String?) ?? 'en',
      words: json['words'] != null
          ? (json['words'] as List).map((w) => WordTiming.fromJson(w as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

class WordTiming {
  final String word;
  final double start;
  final double end;
  final double confidence;

  const WordTiming({
    required this.word,
    required this.start,
    required this.end,
    required this.confidence,
  });

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: (json['word'] as String?) ?? '',
      start: ((json['start'] as num?) ?? 0).toDouble(),
      end: ((json['end'] as num?) ?? 0).toDouble(),
      confidence: ((json['confidence'] as num?) ?? 0).toDouble(),
    );
  }
}

class PronunciationAnalysis {
  final double overallScore;
  final double clarity;
  final double fluency;
  final double prosody;
  final List<WordFeedback> wordFeedbacks;
  final String? suggestion;

  const PronunciationAnalysis({
    required this.overallScore,
    required this.clarity,
    required this.fluency,
    required this.prosody,
    required this.wordFeedbacks,
    this.suggestion,
  });

  factory PronunciationAnalysis.empty() {
    return const PronunciationAnalysis(
      overallScore: 0,
      clarity: 0,
      fluency: 0,
      prosody: 0,
      wordFeedbacks: [],
    );
  }

  factory PronunciationAnalysis.fromJson(Map<String, dynamic> json) {
    return PronunciationAnalysis(
      overallScore: ((json['overall_score'] as num?) ?? 0).toDouble(),
      clarity: ((json['clarity'] as num?) ?? 0).toDouble(),
      fluency: ((json['fluency'] as num?) ?? 0).toDouble(),
      prosody: ((json['prosody'] as num?) ?? 0).toDouble(),
      wordFeedbacks: json['word_feedbacks'] != null
          ? (json['word_feedbacks'] as List)
              .map((w) => WordFeedback.fromJson(w as Map<String, dynamic>))
              .toList()
          : [],
      suggestion: json['suggestion'] as String?,
    );
  }
}

class WordFeedback {
  final String word;
  final double score;
  final String? issue;
  final String? suggestion;

  const WordFeedback({
    required this.word,
    required this.score,
    this.issue,
    this.suggestion,
  });

  factory WordFeedback.fromJson(Map<String, dynamic> json) {
    return WordFeedback(
      word: (json['word'] as String?) ?? '',
      score: ((json['score'] as num?) ?? 0).toDouble(),
      issue: json['issue'] as String?,
      suggestion: json['suggestion'] as String?,
    );
  }
}
