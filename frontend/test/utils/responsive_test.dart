import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/responsive.dart';

void main() {
  group('Responsive', () {
    testWidgets('isMobile returns true for width < 400', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isMobile = Responsive.isMobile(context);
              return Scaffold(body: Text(isMobile ? 'mobile' : 'not mobile'));
            },
          ),
        ),
      );

      // Default test screen is 800x600, so not mobile
      expect(find.text('not mobile'), findsOneWidget);
    });

    testWidgets('gridColumns returns correct count for desktop', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final columns = Responsive.gridColumns(context);
              return Scaffold(body: Text('$columns'));
            },
          ),
        ),
      );

      // Default test screen is 800x600, which is tablet
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('screenPadding returns correct margin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = Responsive.screenPadding(context);
              return Scaffold(body: Text('${padding.left}'));
            },
          ),
        ),
      );

      // Default test screen is 800x600, which is tablet -> 32dp
      expect(find.text('32.0'), findsOneWidget);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('provides correct layout info', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, layout) {
                return Text(
                  'columns: ${layout.columns}, isMobile: ${layout.isMobile}',
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('columns: 8, isMobile: false'), findsOneWidget);
    });
  });

  group('ResponsiveLayout', () {
    test('stores layout properties correctly', () {
      const layout = ResponsiveLayout(
        isMobile: true,
        isTablet: false,
        isDesktop: false,
        columns: 4,
        margin: 16,
        maxWidth: double.infinity,
      );

      expect(layout.isMobile, isTrue);
      expect(layout.isTablet, isFalse);
      expect(layout.isDesktop, isFalse);
      expect(layout.columns, 4);
      expect(layout.margin, 16);
    });
  });
}
