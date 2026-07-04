import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../domain/entities/voice_session.dart';
import '../providers/voice_providers.dart';

/// Voice call page for AI conversation practice.
class VoicePage extends ConsumerStatefulWidget {
  const VoicePage({super.key});

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _durationTimer;
  bool _isMuted = false;
  int _duration = 0;
  final List<String> _transcriptLines = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  bool _isConnected() {
    final session = ref.read(currentVoiceSessionProvider);
    return session != null && session.endedAt == null;
  }

  Future<void> _toggleConnection() async {
    if (_isConnected()) {
      await _endCall();
    } else {
      await _startCall();
    }
  }

  Future<void> _startCall() async {
    try {
      await ref.read(currentVoiceSessionProvider.notifier).startSession('en');
      if (mounted && _isConnected()) {
        _animationController.repeat(reverse: true);
        _startDurationTimer();
        setState(() {
          _transcriptLines.clear();
          _transcriptLines.add('Connected. Start speaking...');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start voice session: $e')),
        );
      }
    }
  }

  Future<void> _endCall() async {
    _animationController.stop();
    _animationController.reset();

    try {
      await ref.read(currentVoiceSessionProvider.notifier).endSession();
      final session = ref.read(currentVoiceSessionProvider);
      if (session != null && _transcriptLines.isNotEmpty) {
        final transcript = _transcriptLines.join('\n');
        await ref
            .read(pronunciationScoreStateProvider.notifier)
            .evaluate(transcript, targetLanguage: 'en');
      }
      setState(() {
        _duration = 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to end session: $e')));
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isConnected() && mounted) {
        setState(() => _duration++);
      } else {
        _durationTimer?.cancel();
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _isConnected();
    final score = ref.watch(pronunciationScoreStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_isConnected()) {
                        _endCall();
                      }
                      context.pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                  Text(
                    isConnected ? _formatDuration(_duration) : 'Voice Call',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.speed)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    isConnected ? 'Listening...' : 'Tap to start',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  if (isConnected) _buildTranscriptCard(),
                  if (!isConnected && score != null) _buildScoreCard(score),
                ],
              ),
            ),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isConnected() ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              boxShadow: _isConnected()
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: const Icon(Icons.school, size: 64, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Live Transcript',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._transcriptLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                line,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(PronunciationScore score) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assessment, size: 16, color: AppColors.success),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Session Score',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _buildScoreBar('Overall', score.overallScore, AppColors.primary500),
          const SizedBox(height: AppSpacing.sm),
          _buildScoreBar(
            'Pronunciation',
            score.pronunciationScore,
            AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildScoreBar('Fluency', score.fluencyScore, AppColors.info),
          const SizedBox(height: AppSpacing.sm),
          _buildScoreBar('Grammar', score.grammarScore, AppColors.warning),
          const SizedBox(height: AppSpacing.sm),
          _buildScoreBar(
            'Vocabulary',
            score.vocabularyScore,
            AppColors.success,
          ),
          if (score.feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.base),
            Text(
              score.feedback,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
          if (score.strengths.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: score.strengths
                  .map<Widget>(
                    (s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      side: BorderSide(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (score.practiceWords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Practice: ${score.practiceWords.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 30,
          child: Text(
            '$score',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            isActive: _isMuted,
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),
          GestureDetector(
            onTap: _toggleConnection,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isConnected() ? AppColors.error : AppColors.success,
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isConnected() ? AppColors.error : AppColors.success)
                            .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isConnected() ? Icons.call_end : Icons.mic,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          _ControlButton(
            icon: Icons.volume_up,
            label: 'Speaker',
            isActive: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: true,
      child: GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
