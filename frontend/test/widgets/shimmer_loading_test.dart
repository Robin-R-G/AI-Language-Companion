import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/shimmer_loading.dart';

void main() {
  group('ShimmerLoading', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders with custom dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              width: 200,
              height: 40,
              borderRadius: 16,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });
  });

  group('ShimmerCard', () {
    testWidgets('renders shimmer card skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
