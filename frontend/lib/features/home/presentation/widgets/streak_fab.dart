import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';

/// Floating action button for quick voice call access.
/// Displays streak count and opens voice call screen.
class StreakFab extends StatelessWidget {
  const StreakFab({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        onPressed: () => context.push(RouteNames.voice),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, color: Colors.white, size: 28),
            SizedBox(height: 2),
            Text(
              '5🔥',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
