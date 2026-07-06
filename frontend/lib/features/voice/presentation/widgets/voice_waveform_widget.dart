// lib/features/voice/presentation/widgets/voice_waveform_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ai_language_coach/shared/theme/app_theme.dart';

class VoiceWaveformWidget extends AnimatedWidget {
  final bool isActive;
  final Animation<double> animation;

  const VoiceWaveformWidget({
    super.key,
    required this.isActive,
    required this.animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(
        isActive: isActive,
        progress: animation.value,
      ),
      size: Size.infinite,
    );
  }
}

class WaveformPainter extends CustomPainter {
  final bool isActive;
  final double progress;
  final List<double> amplitudes = [];

  WaveformPainter({
    required this.isActive,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final barWidth = 4.0;
    final barSpacing = 6.0;
    final numBars = (size.width / (barWidth + barSpacing)).floor();

    for (int i = 0; i < numBars; i++) {
      final x = i * (barWidth + barSpacing) + barWidth / 2;

      double amplitude;
      if (isActive) {
        // Generate random-looking waveform based on progress
        final seed = (i * 0.3 + progress * 10).toDouble();
        amplitude = (sin(seed) * 0.3 + 0.5 + sin(seed * 2.7) * 0.2) *
            size.height *
            0.4;

        // Add some variation
        final variation = sin(progress * pi * 2 + i * 0.5) * 0.2;
        amplitude *= (1 + variation);
      } else {
        amplitude = 2; // Flat line when inactive
      }

      // Color gradient based on position
      final hue = (i / numBars * 60 + 200) % 360; // Blue to purple
      paint.color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();

      canvas.drawLine(
        Offset(x, centerY - amplitude / 2),
        Offset(x, centerY + amplitude / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
