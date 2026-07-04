import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/stat_row.dart';

void main() {
  group('StatRow', () {
    testWidgets('renders multiple stat items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatRow(
              stats: [
                StatItem(icon: Icons.star, value: '100', label: 'XP'),
                StatItem(icon: Icons.local_fire_department, value: '5', label: 'Streak'),
                StatItem(icon: Icons.book, value: '50', label: 'Words'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('XP'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Words'), findsOneWidget);
    });

    testWidgets('renders with icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatRow(
              stats: [
                StatItem(icon: Icons.star, value: '100', label: 'XP'),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('has semantic labels for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatRow(
              stats: [
                StatItem(icon: Icons.star, value: '100', label: 'XP'),
              ],
            ),
          ),
        ),
      );

      final SemanticsNode semantics = tester.getSemantics(
        find.byType(StatRow),
      );
      expect(semantics.label, contains('XP'));
      expect(semantics.label, contains('100'));
    });
  });
}
