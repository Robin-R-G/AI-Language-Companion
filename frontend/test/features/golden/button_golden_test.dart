import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/app_button.dart';
import '../../helpers/golden_test_helper.dart';

void main() {
  group('Golden Tests - AppButton', () {
    testWidgets('primary button light theme', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          AppButton(
            label: 'Get Started',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/button_primary_light.png'),
      );
    });

    testWidgets('primary button dark theme', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          AppButton(
            label: 'Get Started',
            onPressed: () {},
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/button_primary_dark.png'),
      );
    });

    testWidgets('secondary button light theme', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          AppButton(
            label: 'Cancel',
            onPressed: () {},
            variant: ButtonVariant.secondary,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/button_secondary_light.png'),
      );
    });

    testWidgets('disabled button light theme', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          AppButton(
            label: 'Disabled',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/button_disabled_light.png'),
      );
    });

    testWidgets('loading button light theme', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          AppButton(
            label: 'Loading',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/button_loading_light.png'),
      );
    });
  });
}
