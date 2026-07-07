import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../../core/services/livekit_service.dart';

/// Full-screen live class page for real-time tutoring sessions.
class LiveClassPage extends ConsumerStatefulWidget {
  const LiveClassPage({
    super.key,
    required this.sessionId,
    required this.isHost,
    required this.tutorName,
    this.subject,
  });

  final String sessionId;
  final bool isHost;
  final String tutorName;
  final String? subject;

  @override
  ConsumerState<LiveClassPage> createState() => _LiveClassPageState();
}

class _LiveClassPageState extends ConsumerState<LiveClassPage> {
  Room? _room;
  bool _isLoading = true;
  bool _isConnected = false;
  bool _isMicOn = true;
  bool _isCameraOn = false;
  bool _isScreenSharing = false;
  String? _error;
  Duration _elapsed = Duration.zero;
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _joinSession();
  }

  @override
  void dispose() {
    _leaveSession();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _joinSession() async {
    try {
      final service = ref.read(liveKitServiceProvider);
      final room = await service.joinSession(
        sessionId: widget.sessionId,
        asHost: widget.isHost,
      );
      if (mounted) {
        setState(() {
          _room = room;
          _isLoading = false;
          _isConnected = true;
          _isCameraOn = widget.isHost; // host joins with camera
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _startTimer() {
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (!mounted) return;
      setState(() {
        _elapsed = DateTime.now().difference(_startTime);
      });
    });
  }

  Future<void> _leaveSession() async {
    final service = ref.read(liveKitServiceProvider);
    await service.leaveSession(widget.sessionId);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? _buildLoading()
            : _error != null
                ? _buildError()
                : _buildRoom(theme),
      ),
    );
  }

  Widget _buildLoading() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Connecting to class...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Connection Failed',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error',
                style: const TextStyle(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );

  Widget _buildRoom(ThemeData theme) {
    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────────────────────────
        _TopBar(
          tutorName: widget.tutorName,
          subject: widget.subject,
          elapsed: _formatDuration(_elapsed),
          isHost: widget.isHost,
          onLeave: () async {
            await _leaveSession();
            if (mounted) Navigator.of(context).pop();
          },
        ),

        // ── Video area ───────────────────────────────────────────────────────
        Expanded(
          child: _room != null
              ? _VideoGrid(room: _room!, isHost: widget.isHost)
              : const Center(
                  child: Text(
                    'Waiting for participants...',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
        ),

        // ── Control bar ──────────────────────────────────────────────────────
        _ControlBar(
          isMicOn: _isMicOn,
          isCameraOn: _isCameraOn,
          isScreenSharing: _isScreenSharing,
          isHost: widget.isHost,
          onToggleMic: () async {
            final service = ref.read(liveKitServiceProvider);
            await service.toggleMic();
            setState(() => _isMicOn = !_isMicOn);
          },
          onToggleCamera: () async {
            final service = ref.read(liveKitServiceProvider);
            await service.toggleCamera();
            setState(() => _isCameraOn = !_isCameraOn);
          },
          onSwitchCamera: () async {
            final service = ref.read(liveKitServiceProvider);
            await service.switchCamera();
          },
          onLeave: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Leave Class?'),
                content: Text(widget.isHost
                    ? 'Leaving will end the class for all participants.'
                    : 'Are you sure you want to leave?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Leave'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await _leaveSession();
              if (mounted) Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.tutorName,
    required this.subject,
    required this.elapsed,
    required this.isHost,
    required this.onLeave,
  });

  final String tutorName;
  final String? subject;
  final String elapsed;
  final bool isHost;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black87,
      child: Row(
        children: [
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '● LIVE',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject ?? 'Live Class',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'with $tutorName',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            elapsed,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _VideoGrid extends StatelessWidget {
  const _VideoGrid({required this.room, required this.isHost});

  final Room room;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    final participants = room.remoteParticipants.values.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: participants.length > 2 ? 2 : 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 16 / 9,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return _ParticipantTile(participant: participant);
      },
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});

  final RemoteParticipant participant;

  @override
  Widget build(BuildContext context) {
    final videoTrack = participant.videoTrackPublications
        .where((p) => !p.muted)
        .firstOrNull
        ?.track as RemoteVideoTrack?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (videoTrack != null)
              VideoTrackRenderer(videoTrack)
            else
              const Center(
                child:
                    Icon(Icons.person, color: Colors.white38, size: 48),
              ),
            // Name overlay
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  participant.name ?? participant.identity,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.isMicOn,
    required this.isCameraOn,
    required this.isScreenSharing,
    required this.isHost,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onLeave,
  });

  final bool isMicOn;
  final bool isCameraOn;
  final bool isScreenSharing;
  final bool isHost;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            icon: isMicOn ? Icons.mic : Icons.mic_off,
            label: isMicOn ? 'Mute' : 'Unmute',
            color: isMicOn ? Colors.white : Colors.red,
            onTap: onToggleMic,
          ),
          const SizedBox(width: 16),
          if (isHost) ...[
            _ControlButton(
              icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
              label: isCameraOn ? 'Camera Off' : 'Camera On',
              color: isCameraOn ? Colors.white : Colors.red,
              onTap: onToggleCamera,
            ),
            const SizedBox(width: 16),
            _ControlButton(
              icon: Icons.flip_camera_ios,
              label: 'Flip',
              color: Colors.white,
              onTap: onSwitchCamera,
            ),
            const SizedBox(width: 16),
          ],
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            color: Colors.red,
            backgroundColor: Colors.red.withOpacity(0.2),
            onTap: onLeave,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
