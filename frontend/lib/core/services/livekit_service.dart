import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class LiveSession {
  const LiveSession({
    required this.sessionId,
    required this.roomName,
    required this.token,
    required this.livekitUrl,
    required this.tutorId,
    required this.studentId,
    this.isHost = false,
  });

  final String sessionId;
  final String roomName;
  final String token;
  final String livekitUrl;
  final String tutorId;
  final String studentId;
  final bool isHost;
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Manages LiveKit real-time sessions for live tutoring classes.
/// - Development: self-hosted LiveKit via Docker
/// - Production: LiveKit Cloud
class LiveKitService {
  LiveKitService._();
  static final LiveKitService instance = LiveKitService._();

  final SupabaseClient _client = Supabase.instance.client;
  Room? _room;

  Room? get room => _room;
  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  // ── Session lifecycle ─────────────────────────────────────────────────────

  /// Join a live class session. Fetches JWT token from Supabase edge function.
  Future<Room?> joinSession({
    required String sessionId,
    required bool asHost,
    VideoPublishOptions? videoOptions,
    AudioPublishOptions? audioOptions,
  }) async {
    try {
      // 1. Get LiveKit token from edge function
      final tokenResponse = await _client.functions.invoke(
        'livekit_token',
        body: {
          'session_id': sessionId,
          'is_host': asHost,
        },
      );

      if (tokenResponse.status != 200) {
        throw Exception('Failed to get LiveKit token');
      }

      final data = tokenResponse.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final url = data['livekit_url'] as String;

      // 2. Create and connect room
      _room = Room();

      await _room!.connect(
        url,
        token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );

      // 3. Enable camera/mic for host; mic-only for student (default)
      if (asHost) {
        await _room!.localParticipant?.setCameraEnabled(true);
      }
      await _room!.localParticipant?.setMicrophoneEnabled(true);

      // 4. Update session status in Supabase
      await _client.from('live_sessions').upsert({
        'id': sessionId,
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
      });

      return _room;
    } catch (e) {
      await _room?.disconnect();
      _room = null;
      rethrow;
    }
  }

  /// Leave the current session.
  Future<void> leaveSession(String sessionId) async {
    try {
      await _room?.disconnect();
      _room = null;

      // Update session status
      await _client.from('live_sessions').update({
        'status': 'ended',
        'ended_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);
    } catch (_) {}
  }

  /// Toggle microphone mute state.
  Future<void> toggleMic() async {
    final enabled = _room?.localParticipant?.isMicrophoneEnabled() ?? false;
    await _room?.localParticipant?.setMicrophoneEnabled(!enabled);
  }

  /// Toggle camera on/off.
  Future<void> toggleCamera() async {
    final enabled = _room?.localParticipant?.isCameraEnabled() ?? false;
    await _room?.localParticipant?.setCameraEnabled(!enabled);
  }

  /// Switch between front/rear cameras.
  Future<void> switchCamera() async {
    final track = _room?.localParticipant?.videoTrackPublications
        .firstOrNull
        ?.track as LocalVideoTrack?;
    if (track == null) return;
    try {
      final devices = await navigator.mediaDevices.enumerateDevices();
      final videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
      if (videoInputs.length < 2) return;
      
      final currentDeviceId = track.mediaStreamTrack.getSettings()['deviceId'] as String?;
      final nextDevice = videoInputs.firstWhere(
        (d) => d.deviceId != currentDeviceId,
        orElse: () => videoInputs.first,
      );
      await track.switchCamera(nextDevice.deviceId);
    } catch (e) {
      print('Failed to switch camera: $e');
    }
  }

  // ── Scheduling ────────────────────────────────────────────────────────────

  /// Create a new live session booking.
  Future<String> createSession({
    required String tutorId,
    required String studentId,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String subject,
  }) async {
    final response = await _client.from('live_sessions').insert({
      'tutor_id': tutorId,
      'student_id': studentId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'subject': subject,
      'status': 'scheduled',
    }).select('id').single();

    return response['id'] as String;
  }

  /// Fetch upcoming sessions for the current user.
  Future<List<Map<String, dynamic>>> getUpcomingSessions() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final now = DateTime.now().toIso8601String();
    final response = await _client
        .from('live_sessions')
        .select('''
          *,
          tutor:tutor_id(id, full_name, avatar_url),
          student:student_id(id, full_name, avatar_url)
        ''')
        .or('tutor_id.eq.${user.id},student_id.eq.${user.id}')
        .gte('scheduled_at', now)
        .inFilter('status', ['scheduled', 'active'])
        .order('scheduled_at')
        .limit(20);

    return List<Map<String, dynamic>>.from(response);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final liveKitServiceProvider = Provider<LiveKitService>((ref) {
  return LiveKitService.instance;
});

final upcomingSessionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return LiveKitService.instance.getUpcomingSessions();
});
