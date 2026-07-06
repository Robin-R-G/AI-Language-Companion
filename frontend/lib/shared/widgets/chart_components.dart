import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';

/// Chart components for the AI Language Coach application.
/// These are placeholder widgets that can be replaced with fl_chart or similar.

/// Simple line chart for progress tracking.
class ProgressLineChart extends StatelessWidget {
  final List<double> data;
  final List<String>? labels;
  final Color? lineColor;
  final Color? fillColor;
  final double? height;

  const ProgressLineChart({
    super.key,
    required this.data,
    this.labels,
    this.lineColor,
    this.fillColor,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = lineColor ?? theme.colorScheme.primary;
    final fill = fillColor ?? color.withOpacity(0.1);

    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(
          data: data,
          lineColor: color,
          fillColor: fill,
          labels: labels,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final List<String>? labels;

  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final stepX = size.width / (data.length - 1);
    final padding = size.height * 0.1;
    final chartHeight = size.height - padding * 2;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw line and fill
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = range > 0
          ? (data[i] - minVal) / range
          : 0.5;
      final y = padding + chartHeight * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = range > 0
          ? (data[i] - minVal) / range
          : 0.5;
      final y = padding + chartHeight * (1 - normalizedValue);

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Draw labels
    if (labels != null && labels!.length == data.length) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: '',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      );

      for (int i = 0; i < labels!.length; i++) {
        final x = i * stepX;
        textPainter.text = TextSpan(text: labels![i]);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x - textPainter.width / 2,
            size.height - textPainter.height,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Bar chart for XP tracking.
class XPBarChart extends StatelessWidget {
  final List<XPBarData> data;
  final double? height;

  const XPBarChart({
    super.key,
    required this.data,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.map((item) {
          final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
          final normalizedHeight = maxValue > 0 ? item.value / maxValue : 0.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${item.value}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: (height! - 60) * normalizedHeight,
                    decoration: BoxDecoration(
                      color: item.color ?? theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Weekly activity heatmap.
class WeeklyActivity extends StatelessWidget {
  final List<bool> activeDays;
  final int currentDayIndex;

  const WeeklyActivity({
    super.key,
    required this.activeDays,
    this.currentDayIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isActive = index < activeDays.length && activeDays[index];
          final isCurrentDay = index == currentDayIndex;

          return Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success
                      : isCurrentDay
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                  border: isCurrentDay
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: isActive
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : Text(
                          days[index][0],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isCurrentDay
                                ? theme.colorScheme.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                days[index],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Circular progress indicator.
class CircularProgress extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double? size;

  const CircularProgress({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 6,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Donut chart for skill distribution.
class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double? size;
  final String? centerLabel;

  const DonutChart({
    super.key,
    required this.segments,
    this.size = 120,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          total: total,
        ),
        child: centerLabel != null
            ? Center(
                child: Text(
                  centerLabel!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double total;

  _DonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    double startAngle = -90;

    for (final segment in segments) {
      final sweepAngle = total > 0 ? (segment.value / total) * 360 : 0.0;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _degreesToRadians(startAngle),
        _degreesToRadians(sweepAngle),
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  double _degreesToRadians(double degrees) => degrees * 3.141592653589793 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Stacked bar chart for daily breakdown.
class StackedBarChart extends StatelessWidget {
  final List<StackedBarData> data;
  final double? height;

  const StackedBarChart({
    super.key,
    required this.data,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final totalHeight = height! - 60;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...item.segments.map((segment) => Container(
                        height: totalHeight * (segment.value / item.total),
                        color: segment.color,
                      )),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Data classes for charts.
class XPBarData {
  final String label;
  final double value;
  final Color? color;

  const XPBarData({
    required this.label,
    required this.value,
    this.color,
  });
}

class DonutSegment {
  final double value;
  final Color color;
  final String? label;

  const DonutSegment({
    required this.value,
    required this.color,
    this.label,
  });
}

class StackedBarData {
  final String label;
  final List<StackedSegment> segments;
  final double total;

  const StackedBarData({
    required this.label,
    required this.segments,
    required this.total,
  });
}

class StackedSegment {
  final double value;
  final Color color;

  const StackedSegment({
    required this.value,
    required this.color,
  });
}

/// Mini sparkline chart for inline data.
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color? color;
  final double height;
  final double strokeWidth;

  const Sparkline({
    super.key,
    required this.data,
    this.color,
    this.height = 40,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          data: data,
          color: lineColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final stepX = size.width / (data.length - 1);
    final padding = size.height * 0.1;
    final chartHeight = size.height - padding * 2;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = range > 0
          ? (data[i] - minVal) / range
          : 0.5;
      final y = padding + chartHeight * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
