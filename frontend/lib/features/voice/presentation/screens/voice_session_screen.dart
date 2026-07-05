// lib/features/voice/presentation/screens/voice_session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_theme.dart';
import '../controllers/voice_controller.dart';
import '../widgets/voice_waveform_widget.dart';

class VoiceSessionScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String? mode; // 'conversation', 'pronunciation', 'shadowing'

  const VoiceSessionScreen({
    super.key,
    required this.conversationId,
    this.mode,
  });

  @override
  ConsumerState<VoiceSessionScreen> createState() => _VoiceSessionScreenState();
}

class _VoiceSessionScreenState extends ConsumerState<VoiceSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _lastTranscription;
  double _confidence = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat(reverse: true);
      // Start voice session
      ref.read(voiceControllerProvider.notifier).startSession(
        widget.conversationId,
        mode: widget.mode ?? 'conversation',
      );
    } else {
      _pulseController.stop();
      _waveController.stop();
      setState(() => _isProcessing = true);

      // Stop and get result
      ref.read(voiceControllerProvider.notifier).stopSession().then((_) {
        setState(() => _isProcessing = false);
        // Get transcription and evaluation
        _evaluateRecording();
      });
    }
  }

  Future<void> _evaluateRecording() async {
    // Get the recorded audio data and evaluate
    final result = await ref.read(voiceControllerProvider.notifier).evaluatePronunciation(
      widget.conversationId,
    );

    if (result != null) {
      setState(() {
        _lastTranscription = result['transcription'];
        _confidence = result['confidence'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getModeTitle(),
          style: AppTextStyles.headingSmall,
        ),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            onPressed: () {
              // Settings
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Transcription display
                    if (_lastTranscription != null)
                      Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'You said:',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _lastTranscription!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_confidence > 0) ...[
                              const SizedBox(height: 12),
                              _buildConfidenceIndicator(),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(),

                    // Voice waveform
                    if (_isRecording || _isProcessing)
                      Container(
                        height: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: VoiceWaveformWidget(
                          isActive: _isRecording,
                          animation: _waveController,
                        ),
                      ).animate().fadeIn(),

                    // Recording button
                    const SizedBox(height: 32),
                    _buildRecordButton(),

                    const SizedBox(height: 24),

                    // Instructions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _getInstructionText(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action bar
            if (_lastTranscription != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _lastTranscription = null;
                            _confidence = 0;
                          });
                        },
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Continue with next item
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _toggleRecording,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.1);
          return Transform.scale(
            scale: _isRecording ? scale : 1.0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isRecording ? AppColors.error : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? AppColors.error : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: _isRecording ? 20 : 10,
                    spreadRadius: _isRecording ? 5 : 0,
                  ),
                ],
              ),
              child: Center(
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 36,
                        color: Colors.white,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pronunciation',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(_confidence * 100).round()}%',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: _getConfidenceColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _confidence,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
        ),
      ],
    );
  }

  Color _getConfidenceColor() {
    if (_confidence >= 0.8) return AppColors.success;
    if (_confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case 'pronunciation':
        return 'Pronunciation Practice';
      case 'shadowing':
        return 'Shadowing Exercise';
      default:
        return 'Voice Conversation';
    }
  }

  String _getInstructionText() {
    if (_isRecording) {
      return 'Listening... Tap to stop';
    }
    if (_isProcessing) {
      return 'Processing your speech...';
    }
    if (_lastTranscription != null) {
      return 'Check your pronunciation above';
    }
    return 'Tap the microphone to start speaking';
  }
}
