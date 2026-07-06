import 'package:flutter/material.dart';

/// Reusable avatar widget with fallback icon.
/// Supports network images, local asset paths, and asset-based avatars.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.radius = 24,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Network image takes priority
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, _) {},
      );
    }

    // Local asset path
    if (assetPath != null && assetPath!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ??
            Theme.of(context).colorScheme.primary.withAlpha(26),
        child: ClipOval(
          child: Image.asset(
            assetPath!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              size: radius * 1.2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Fallback icon
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ??
          Theme.of(context).colorScheme.primary.withAlpha(26),
      child: Icon(
        fallbackIcon,
        size: radius * 1.2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
