// lib/shared/widgets/skill_radar_chart.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SkillRadarChart extends StatelessWidget {
  final Map<String, double> skills;
  final double size;

  const SkillRadarChart({
    super.key,
    required this.skills,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          skills: skills,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> skills;
  final Color color;
  final Color backgroundColor;

  _RadarChartPainter({
    required this.skills,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final skillsList = skills.entries.toList();
    final count = skillsList.length;

    if (count < 3) return;

    final angleStep = 2 * math.pi / count;

    // Draw background polygons
    for (int level = 5; level >= 1; level--) {
      final paint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;

      final path = Path();
      for (int i = 0; i < count; i++) {
        final angle = angleStep * i - math.pi / 2;
        final point = Offset(
          center.dx + (radius * level / 5) * math.cos(angle),
          center.dy + (radius * level / 5) * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // Draw axis lines
    final linePaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 1;

    for (int i = 0; i < count; i++) {
      final angle = angleStep * i - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, point, linePaint);
    }

    // Draw data polygon
    final dataPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dataPath = Path();
    for (int i = 0; i < count; i++) {
      final angle = angleStep * i - math.pi / 2;
      final value = (skillsList[i].value / 100).clamp(0.0, 1.0);
      final point = Offset(
        center.dx + radius * value * math.cos(angle),
        center.dy + radius * value * math.sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, borderPaint);

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < count; i++) {
      final angle = angleStep * i - math.pi / 2;
      final labelRadius = radius + 20;
      final labelPoint = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      textPainter.text = TextSpan(
        text: skillsList[i].key,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2,
          labelPoint.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
