import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Voice components for the AI Language Coach application.
/// Follows the Flutter Component Library specification.

/// Voice recorder button with visual feedback.
class VoiceRecorder extends StatefulWidget {
  final bool isRecording;
  final VoidCallback? onTap;
  final double size;

  const VoiceRecorder({
    super.key,
    this.isRecording = false,
    this.onTap,
    this.size = 80,
  });

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.isRecording
                    ? AppColors.error
                    : theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording
                            ? AppColors.error
                            : theme.colorScheme.primary)
                        .withOpacity(0.3),
                    blurRadius: widget.isRecording ? 20 : 10,
                    spreadRadius: widget.isRecording ? 5 : 0,
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: widget.size * 0.4,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Audio waveform visualization.
class WaveformWidget extends StatelessWidget {
  final List<double> amplitudes;
  final Color? color;
  final double height;

  const WaveformWidget({
    super.key,
    this.amplitudes = const [],
    this.color,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final waveColor = color ?? theme.colorScheme.primary;
    final displayAmplitudes =
        amplitudes.isEmpty ? List.generate(30, (_) => 0.0) : amplitudes;

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: displayAmplitudes.map((amplitude) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 3,
              height: (amplitude * height * 0.8) + 4,
              decoration: BoxDecoration(
                color: waveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Audio player controls.
class AudioPlayerWidget extends StatelessWidget {
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSeek;

  const AudioPlayerWidget({
    super.key,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.onPlayPause,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Slider(
          value: duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0.0,
          onChanged: (value) {
            final newPosition = Duration(
              milliseconds: (value * duration.inMilliseconds).round(),
            );
            // Handle seek
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () {
                // Handle rewind
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: onPlayPause,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () {
                // Handle forward
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Live microphone indicator.
class LiveMicrophoneIndicator extends StatefulWidget {
  final bool isActive;

  const LiveMicrophoneIndicator({
    super.key,
    this.isActive = false,
  });

  @override
  State<LiveMicrophoneIndicator> createState() =>
      _LiveMicrophoneIndicatorState();
}

class _LiveMicrophoneIndicatorState extends State<LiveMicrophoneIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.error.withOpacity(_controller.value)
                : AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Pronunciation score display.
class PronunciationScore extends StatelessWidget {
  final double score;
  final String? word;

  const PronunciationScore({
    super.key,
    required this.score,
    this.word,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (word != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              word!,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '${score.round()}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _getScoreLabel(score),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Needs Practice';
  }
}

/// Speech timer display.
class SpeechTimer extends StatelessWidget {
  final Duration elapsed;
  final Duration? limit;
  final bool isRecording;

  const SpeechTimer({
    super.key,
    this.elapsed = Duration.zero,
    this.limit,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverLimit = limit != null && elapsed > limit!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRecording)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: LiveMicrophoneIndicator(isActive: isRecording),
          ),
        Text(
          _formatDuration(elapsed),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isOverLimit ? AppColors.error : null,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (limit != null) ...[
          Text(
            ' / ${_formatDuration(limit!)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Recording status indicator.
class RecordingStatus extends StatelessWidget {
  final RecordingState state;

  const RecordingStatus({
    super.key,
    this.state = RecordingState.idle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStateColor(theme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state == RecordingState.recording)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: LiveMicrophoneIndicator(isActive: true),
            ),
          Text(
            _getStateText(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: _getStateColor(theme),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(ThemeData theme) {
    switch (state) {
      case RecordingState.idle:
        return AppColors.textSecondary;
      case RecordingState.recording:
        return AppColors.error;
      case RecordingState.paused:
        return AppColors.warning;
      case RecordingState.processing:
        return AppColors.info;
    }
  }

  String _getStateText() {
    switch (state) {
      case RecordingState.idle:
        return 'Ready';
      case RecordingState.recording:
        return 'Recording';
      case RecordingState.paused:
        return 'Paused';
      case RecordingState.processing:
        return 'Processing';
    }
  }
}

enum RecordingState {
  idle,
  recording,
  paused,
  processing,
}

/// Speaking progress indicator.
class SpeakingProgress extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const SpeakingProgress({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalQuestions > 0 ? currentQuestion / totalQuestions : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $currentQuestion of $totalQuestions',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Accent indicator for pronunciation feedback.
class AccentIndicator extends StatelessWidget {
  final String targetAccent;
  final String userAccent;
  final double similarity;

  const AccentIndicator({
    super.key,
    required this.targetAccent,
    required this.userAccent,
    required this.similarity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSimilarityColor(similarity);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Accent Analysis',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    targetAccent,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward, color: AppColors.textSecondary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Your Accent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    userAccent,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: similarity,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Similarity: ${(similarity * 100).round()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSimilarityColor(double similarity) {
    if (similarity >= 0.8) return AppColors.success;
    if (similarity >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}
