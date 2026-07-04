import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/app_avatar.dart';

void main() {
  group('AppAvatar', () {
    testWidgets('renders fallback icon when no imageUrl', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppAvatar())),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders with custom radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppAvatar(radius: 40))),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
