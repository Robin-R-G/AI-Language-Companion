import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Animated streak flame indicator with count.
class StreakIndicator extends StatelessWidget {
  final int streak;
  final bool isActive;
  final double size;

  const StreakIndicator({
    super.key,
    required this.streak,
    this.isActive = true,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$streak day streak${isActive ? ', active' : ''}',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.warning.withAlpha(30)
                    : theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isActive ? AppColors.warning : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
            ),
            Icon(
              Icons.local_fire_department,
              size: size * 0.5,
              color: isActive ? AppColors.warning : AppColors.disabled,
            ),
            if (streak > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.warning : AppColors.disabled,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$streak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
