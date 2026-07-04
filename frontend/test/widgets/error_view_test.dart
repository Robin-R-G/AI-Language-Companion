import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/error_view.dart';
import 'package:ai_language_coach/core/widgets/app_button.dart';

void main() {
  group('ErrorView', () {
    testWidgets('renders default error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorView()),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Please check your connection and try again.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders custom title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(
              title: 'Network Error',
              message: 'Could not load data.',
            ),
          ),
        ),
      );

      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Could not load data.'), findsOneWidget);
    });

    testWidgets('renders retry button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(onRetry: () {}),
          ),
        ),
      );

      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button tapped', (tester) async {
      bool retryCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(onRetry: () => retryCalled = true),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(retryCalled, isTrue);
    });

    testWidgets('does not render retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorView()),
        ),
      );

      expect(find.byType(AppButton), findsNothing);
    });
  });
}
