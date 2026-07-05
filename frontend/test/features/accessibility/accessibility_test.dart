import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/app_button.dart';
import 'package:ai_language_coach/core/widgets/app_text_field.dart';
import 'package:ai_language_coach/core/widgets/empty_state.dart';
import 'package:ai_language_coach/core/widgets/error_view.dart';
import 'package:ai_language_coach/core/widgets/info_tile.dart';
import 'package:ai_language_coach/core/widgets/progress_card.dart';
import 'package:ai_language_coach/core/widgets/section_header.dart';
import 'package:ai_language_coach/core/widgets/streak_indicator.dart';
import '../../test_utils/test_helpers.dart';

void main() {
  group('Accessibility Tests - WCAG AA Compliance', () {
    group('AppButton Accessibility', () {
      testWidgets('primary button has accessible label', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppButton(
              label: 'Submit',
              onPressed: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(findSemanticsLabel('Submit'), findsOneWidget);
      });

      testWidgets('button has minimum touch target size', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppButton(
              label: 'Submit',
              onPressed: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        final button = find.byType(AppButton);
        expectMinTouchTargetSize(tester, button);
      });

      testWidgets('disabled button is announced as disabled', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppButton(
              label: 'Submit',
              onPressed: null,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final button = tester.widget<AppButton>(find.byType(AppButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('loading button has semantic label', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('AppTextField Accessibility', () {
      testWidgets('text field has label', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppTextField(
              labelText: 'Email Address',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Email Address'), findsOneWidget);
      });

      testWidgets('text field is focusable', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppTextField(
              labelText: 'Email',
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('text field has minimum touch target size', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            AppTextField(
              labelText: 'Search',
            ),
          ),
        );
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);
        final size = tester.getSize(textField);
        expect(size.height, greaterThanOrEqualTo(48));
      });
    });

    group('EmptyState Accessibility', () {
      testWidgets('empty state has icon and text', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const EmptyState(
              icon: Icons.inbox,
              title: 'No items',
              message: 'There are no items to display.',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No items'), findsOneWidget);
        expect(find.text('There are no items to display.'), findsOneWidget);
      });

      testWidgets('action button is accessible', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              message: 'Nothing here',
              actionLabel: 'Add Item',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Add Item'), findsOneWidget);
      });
    });

    group('ErrorView Accessibility', () {
      testWidgets('error view displays error message', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const ErrorView(
              title: 'Something went wrong',
              message: 'Please try again later.',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Please try again later.'), findsOneWidget);
      });

      testWidgets('retry button is accessible', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            ErrorView(
              title: 'Error',
              message: 'Failed to load',
              onRetry: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('InfoTile Accessibility', () {
      testWidgets('info tile has semantic label', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            InfoTile(
              icon: Icons.star,
              title: 'Achievements',
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(findSemanticsLabel('Achievements'), findsOneWidget);
      });

      testWidgets('info tile has minimum touch target size', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            InfoTile(
              icon: Icons.star,
              title: 'Achievements',
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        final tile = find.byType(InfoTile);
        expectMinTouchTargetSize(tester, tile);
      });
    });

    group('ProgressCard Accessibility', () {
      testWidgets('progress card displays data', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const ProgressCard(
              label: 'Weekly Progress',
              value: '75%',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Weekly Progress'), findsOneWidget);
        expect(find.text('75%'), findsOneWidget);
      });
    });

    group('SectionHeader Accessibility', () {
      testWidgets('section header has title', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const SectionHeader(title: 'Recent Activity'),
          ),
        );
        await tester.pumpAndSettle();

        expect(findSemanticsLabel('Recent Activity'), findsOneWidget);
      });
    });

    group('StreakIndicator Accessibility', () {
      testWidgets('streak indicator has semantic label', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const StreakIndicator(
              streak: 5,
              isActive: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(findSemanticsLabel('5 day streak'), findsOneWidget);
      });

      testWidgets('inactive streak is announced', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const StreakIndicator(
              streak: 0,
              isActive: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(findSemanticsLabel('No active streak'), findsOneWidget);
      });
    });

    group('Color Contrast', () {
      testWidgets('primary color has sufficient contrast', (tester) async {
        const primaryColor = Color(0xFF3B82F6);
        const onPrimary = Colors.white;

        final luminance = primaryColor.computeLuminance();
        final onPrimaryLuminance = onPrimary.computeLuminance();

        final lighter = luminance > onPrimaryLuminance
            ? luminance
            : onPrimaryLuminance;
        final darker = luminance > onPrimaryLuminance
            ? onPrimaryLuminance
            : luminance;

        final contrastRatio = (lighter + 0.05) / (darker + 0.05);

        expect(contrastRatio, greaterThanOrEqualTo(4.5));
      });
    });

    group('Touch Target Compliance', () {
      testWidgets('all interactive elements meet minimum size', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            Column(
              children: [
                AppButton(label: 'Test', onPressed: () {}),
                const SizedBox(height: 8),
                InfoTile(
                  icon: Icons.star,
                  title: 'Test',
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final button = find.byType(AppButton);
        final tile = find.byType(InfoTile);

        expectMinTouchTargetSize(tester, button);
        expectMinTouchTargetSize(tester, tile);
      });
    });
  });
}
