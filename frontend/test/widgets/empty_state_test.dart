import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/empty_state.dart';
import 'package:ai_language_coach/core/widgets/app_button.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders icon, title, and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'There are no items to display.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('There are no items to display.'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              message: 'Nothing here',
              actionLabel: 'Add Item',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('does not render action button when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              message: 'Nothing here',
            ),
          ),
        ),
      );

      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('calls onAction when action button tapped', (tester) async {
      bool actionCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              message: 'Nothing here',
              actionLabel: 'Add',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(actionCalled, isTrue);
    });
  });
}
