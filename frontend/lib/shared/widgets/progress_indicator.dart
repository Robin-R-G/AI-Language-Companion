// lib/shared/widgets/progress_indicator.dart
import 'package:flutter/material.dart';

class CircularScoreIndicator extends StatelessWidget {
  final double score;
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? label;

  const CircularScoreIndicator({
    super.key,
    required this.score,
    this.size = 80,
    this.strokeWidth = 8,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? _getScoreColor(score);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${score.round()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: effectiveColor,
                  ),
                ),
                if (label != null)
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

class LinearProgress extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;

  const LinearProgress({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: backgroundColor ?? colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            valueColor ?? colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
