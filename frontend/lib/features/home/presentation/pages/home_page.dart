import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/design_tokens.dart';
import '../controllers/home_controller.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(homeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardState.when(
          data: (data) {
            if (data == null) {
              return const Center(child: Text('No data available'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingCard(data),
                  const SizedBox(height: AppSpacing.base),
                  _buildDailyProgress(data),
                  const SizedBox(height: AppSpacing.base),
                  _buildDailyMission(),
                  const SizedBox(height: AppSpacing.base),
                  _buildQuickActions(),
                  const SizedBox(height: AppSpacing.base),
                  _buildBusinessActions(),
                  const SizedBox(height: AppSpacing.base),
                  _buildSponsoredContent(),
                  const SizedBox(height: AppSpacing.base),
                  _buildMotivationalQuote(),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(DashboardData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, Learner!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${data.streak}-Day Streak',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push(RouteNames.notifications),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgress(DashboardData data) {
    const dailyGoalMinutes = 20;
    final progressFraction = (data.todayMinutes / dailyGoalMinutes).clamp(
      0.0,
      1.0,
    );
    final remainingMinutes = dailyGoalMinutes - data.todayMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${data.todayMinutes}/$dailyGoalMinutes min',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.round),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progressFraction),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              remainingMinutes > 0
                  ? '$remainingMinutes more minutes to reach your daily goal!'
                  : 'Daily goal reached! Great work!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMission() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'DAILY MISSION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Mock IELTS Speaking: Travel',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Practice Part 2 Cue Card - Describe a place you visited',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(RouteNames.mockExam),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Mission'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          children: [
            _QuickActionCard(
              icon: Icons.book,
              label: 'Vocabulary',
              color: AppColors.info,
              onTap: () => context.push(RouteNames.vocabulary),
            ),
            _QuickActionCard(
              icon: Icons.rule,
              label: 'Grammar',
              color: AppColors.success,
              onTap: () => context.push(RouteNames.grammar),
            ),
            _QuickActionCard(
              icon: Icons.quiz,
              label: 'Mock Exam',
              color: AppColors.warning,
              onTap: () => context.push(RouteNames.mockExam),
            ),
            _QuickActionCard(
              icon: Icons.mic,
              label: 'Speaking',
              color: AppColors.error,
              onTap: () => context.push(RouteNames.voice),
            ),
            _QuickActionCard(
              icon: Icons.translate,
              label: 'Reading',
              color: AppColors.secondary,
              onTap: () => context.push(RouteNames.reading),
            ),
            _QuickActionCard(
              icon: Icons.trending_up,
              label: 'Progress',
              color: AppColors.primary500,
              onTap: () => context.push(RouteNames.progress),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote() {
    final quote =
        AppConstants.motivationalQuotes[DateTime.now().day %
            AppConstants.motivationalQuotes.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            Icon(
              Icons.format_quote,
              size: 32,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                quote,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  Widget _buildBusinessActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monetization & Partner Services',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          children: [
            _QuickActionCard(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Credits Wallet',
              color: Colors.blue,
              onTap: () => context.push(RouteNames.wallet),
            ),
            _QuickActionCard(
              icon: Icons.share_arrival_rounded,
              label: 'Referrals',
              color: Colors.orange,
              onTap: () => context.push(RouteNames.referral),
            ),
            _QuickActionCard(
              icon: Icons.verified_user_rounded,
              label: 'Tutor Market',
              color: Colors.purple,
              onTap: () => context.push(RouteNames.tutors),
            ),
            _QuickActionCard(
              icon: Icons.shopping_bag_rounded,
              label: 'Affiliate Shop',
              color: Colors.green,
              onTap: () => context.push(RouteNames.affiliates),
            ),
            _QuickActionCard(
              icon: Icons.card_membership_rounded,
              label: 'Certificates',
              color: Colors.teal,
              onTap: () => context.push(RouteNames.certificates),
            ),
            _QuickActionCard(
              icon: Icons.credit_card_rounded,
              label: 'Get Premium',
              color: Colors.pink,
              onTap: () => context.push(RouteNames.subscription),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSponsoredContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sponsored Partnerships',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Sponsored Scholarship Path'),
                        content: Text('Redirecting you to the official Oxford English Honors Program portal for international candidates...'),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('University of Oxford', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          SizedBox(height: 4),
                          Text('English Honors Program', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Official Exam Partner'),
                        content: Text('Redirecting you to Duolingo English Test registration with 10% platform discount code...'),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duolingo Partner', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          SizedBox(height: 4),
                          Text('Duolingo Exam (10% Off)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: AppDuration.fast,
      curve: Curves.easeOut,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onHighlightChanged: (isHighlighted) {
            if (isHighlighted) HapticFeedback.lightImpact();
            setState(() => _isPressed = isHighlighted);
          },
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 32, color: widget.color),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
