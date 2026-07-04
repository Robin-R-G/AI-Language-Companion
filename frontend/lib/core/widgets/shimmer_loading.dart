import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

/// Shimmer loading placeholder for lists and content.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer loading card for list items.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerLoading(width: 40, height: 40, borderRadius: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(width: 120, height: 16),
                      SizedBox(height: AppSpacing.xs),
                      ShimmerLoading(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.base),
            ShimmerLoading(height: 14),
            SizedBox(height: AppSpacing.xs),
            ShimmerLoading(width: 200, height: 14),
          ],
        ),
      ),
    );
  }
}
