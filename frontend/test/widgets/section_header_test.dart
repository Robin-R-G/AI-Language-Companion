import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/section_header.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: 'Recent Activity')),
        ),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Vocabulary',
              actionLabel: 'View All',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('calls onAction when action tapped', (tester) async {
      bool actionCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Lessons',
              actionLabel: 'See All',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('See All'));
      expect(actionCalled, isTrue);
    });

    testWidgets('does not render action when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: 'Title')),
        ),
      );

      expect(find.byType(TextButton), findsNothing);
    });
  });
}
