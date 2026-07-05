import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/streak_indicator.dart';

void main() {
  group('StreakIndicator', () {
    testWidgets('renders streak count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StreakIndicator(streak: 5))),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders with fire icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StreakIndicator(streak: 3))),
      );

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('shows active state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StreakIndicator(streak: 7))),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('shows inactive state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StreakIndicator(streak: 0, isActive: false)),
        ),
      );

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StreakIndicator(streak: 10))),
      );

      final semantics = tester.getSemantics(find.byType(StreakIndicator));
      expect(semantics.label, contains('10 day streak'));
    });
  });
}
