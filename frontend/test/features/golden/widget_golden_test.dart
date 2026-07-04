import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/app_avatar.dart';
import 'package:ai_language_coach/core/widgets/app_card.dart';
import 'package:ai_language_coach/core/widgets/empty_state.dart';
import 'package:ai_language_coach/core/widgets/error_view.dart';
import 'package:ai_language_coach/core/widgets/info_tile.dart';
import 'package:ai_language_coach/core/widgets/progress_card.dart';
import 'package:ai_language_coach/core/widgets/section_header.dart';
import 'package:ai_language_coach/core/widgets/shimmer_loading.dart';
import 'package:ai_language_coach/core/widgets/stat_row.dart';
import 'package:ai_language_coach/core/widgets/streak_indicator.dart';
import '../../helpers/golden_test_helper.dart';

void main() {
  group('Golden Tests - Core Widgets Light Theme', () {
    testWidgets('app avatar', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const AppAvatar(radius: 32),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppAvatar),
        matchesGoldenFile('goldens/avatar_light.png'),
      );
    });

    testWidgets('app card', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          AppCard(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Card Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppCard),
        matchesGoldenFile('goldens/card_light.png'),
      );
    });

    testWidgets('empty state', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const EmptyState(
            icon: Icons.inbox,
            title: 'No Items',
            message: 'You have no items yet.',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(EmptyState),
        matchesGoldenFile('goldens/empty_state_light.png'),
      );
    });

    testWidgets('error view', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const ErrorView(
            title: 'Oops!',
            message: 'Something went wrong.',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ErrorView),
        matchesGoldenFile('goldens/error_view_light.png'),
      );
    });

    testWidgets('info tile', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          InfoTile(
            icon: Icons.star,
            title: 'Achievements',
            subtitle: '12 unlocked',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(InfoTile),
        matchesGoldenFile('goldens/info_tile_light.png'),
      );
    });

    testWidgets('progress card', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const ProgressCard(
            label: 'Weekly Goal',
            value: '75%',
            icon: Icons.trending_up,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ProgressCard),
        matchesGoldenFile('goldens/progress_card_light.png'),
      );
    });

    testWidgets('section header', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const SectionHeader(
            title: 'Recent Activity',
            actionText: 'View All',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(SectionHeader),
        matchesGoldenFile('goldens/section_header_light.png'),
      );
    });

    testWidgets('shimmer loading', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const ShimmerLoading(
            width: double.infinity,
            height: 80,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ShimmerLoading),
        matchesGoldenFile('goldens/shimmer_light.png'),
      );
    });

    testWidgets('stat row', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          StatRow(
            stats: const [
              StatItem(value: '1,200', label: 'XP'),
              StatItem(value: '5', label: 'Streak'),
              StatItem(value: '8', label: 'Level'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StatRow),
        matchesGoldenFile('goldens/stat_row_light.png'),
      );
    });

    testWidgets('streak indicator active', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const StreakIndicator(
            streak: 7,
            isActive: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StreakIndicator),
        matchesGoldenFile('goldens/streak_active_light.png'),
      );
    });

    testWidgets('streak indicator inactive', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const StreakIndicator(
            streak: 0,
            isActive: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StreakIndicator),
        matchesGoldenFile('goldens/streak_inactive_light.png'),
      );
    });
  });

  group('Golden Tests - Core Widgets Dark Theme', () {
    testWidgets('app card dark', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          AppCard(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Card Content'),
            ),
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppCard),
        matchesGoldenFile('goldens/card_dark.png'),
      );
    });

    testWidgets('empty state dark', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const EmptyState(
            icon: Icons.inbox,
            title: 'No Items',
            message: 'You have no items yet.',
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(EmptyState),
        matchesGoldenFile('goldens/empty_state_dark.png'),
      );
    });

    testWidgets('error view dark', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const ErrorView(
            title: 'Oops!',
            message: 'Something went wrong.',
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ErrorView),
        matchesGoldenFile('goldens/error_view_dark.png'),
      );
    });

    testWidgets('info tile dark', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          InfoTile(
            icon: Icons.star,
            title: 'Achievements',
            onTap: () {},
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(InfoTile),
        matchesGoldenFile('goldens/info_tile_dark.png'),
      );
    });

    testWidgets('progress card dark', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const ProgressCard(
            label: 'Weekly Goal',
            value: '75%',
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ProgressCard),
        matchesGoldenFile('goldens/progress_card_dark.png'),
      );
    });

    testWidgets('streak indicator dark', (tester) async {
      await tester.pumpWidget(
        createGoldenWrapper(
          const StreakIndicator(
            streak: 7,
            isActive: true,
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(StreakIndicator),
        matchesGoldenFile('goldens/streak_active_dark.png'),
      );
    });
  });
}
