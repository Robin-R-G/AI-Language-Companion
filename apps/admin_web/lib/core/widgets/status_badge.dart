import 'package:flutter/material.dart';

enum BadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (type) {
      BadgeType.success => (Colors.green, Colors.green.withOpacity(0.1)),
      BadgeType.warning => (Colors.orange, Colors.orange.withOpacity(0.1)),
      BadgeType.error => (Colors.red, Colors.red.withOpacity(0.1)),
      BadgeType.info => (Colors.blue, Colors.blue.withOpacity(0.1)),
      BadgeType.neutral => (
          Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
