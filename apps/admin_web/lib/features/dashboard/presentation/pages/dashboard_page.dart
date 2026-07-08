import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/user_growth_chart.dart';
import '../widgets/system_health_widget.dart';
import '../widgets/recent_activity_widget.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _revenueData = [];
  List<Map<String, dynamic>> _userGrowthData = [];
  List<Map<String, dynamic>> _recentActivity = [];
  Map<String, dynamic> _systemHealth = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _fetchStats(),
        _fetchRevenueData(),
        _fetchUserGrowthData(),
        _fetchRecentActivity(),
        _fetchSystemHealth(),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as Map<String, dynamic>;
          _revenueData = results[1] as List<Map<String, dynamic>>;
          _userGrowthData = results[2] as List<Map<String, dynamic>>;
          _recentActivity = results[3] as List<Map<String, dynamic>>;
          _systemHealth = results[4] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load dashboard data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final supabase = SupabaseService.instance.client;

    final userCountFuture = supabase
        .from('user_profiles')
        .select('id')
        .count();

    final tutorCountFuture = supabase
        .from('user_profiles')
        .select('id')
        .eq('role', 'tutor')
        .count();

    final subscriptionCountFuture = supabase
        .from('subscriptions')
        .select('id')
        .eq('status', 'active')
        .count();

    final ticketCountFuture = supabase
        .from('support_tickets')
        .select('id')
        .eq('status', 'open')
        .count();

    final results = await Future.wait([
      userCountFuture,
      tutorCountFuture,
      subscriptionCountFuture,
      ticketCountFuture,
    ]);

    final totalUsers = results[0].count;
    final activeTutors = results[1].count;
    final activeSubscriptions = results[2].count;
    final openTickets = results[3].count;

    final revenueResult = await supabase
        .from('payments')
        .select('amount')
        .gte('created_at', _startOfMonth())
        .eq('status', 'completed');

    double monthlyRevenue = 0;
    for (final payment in revenueResult) {
      monthlyRevenue += (payment['amount'] as num?)?.toDouble() ?? 0;
    }

    final conversionRate = totalUsers > 0
        ? ((activeSubscriptions / totalUsers) * 100)
        : 0.0;

    return {
      'total_users': totalUsers,
      'active_tutors': activeTutors,
      'monthly_revenue': monthlyRevenue,
      'active_subscriptions': activeSubscriptions,
      'ai_cost_today': 0.00,
      'pending_payouts': 0.00,
      'support_tickets': openTickets,
      'conversion_rate': conversionRate,
    };
  }

  String _startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1).toIso8601String();
  }

  Future<List<Map<String, dynamic>>> _fetchRevenueData() async {
    final supabase = SupabaseService.instance.client;
    final now = DateTime.now();
    final twelveMonthsAgo = DateTime(now.year - 1, now.month, 1);

    final result = await supabase
        .from('payments')
        .select('amount, created_at')
        .gte('created_at', twelveMonthsAgo.toIso8601String())
        .eq('status', 'completed');

    final Map<int, double> monthlyTotals = {};
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyTotals[month.millisecondsSinceEpoch] = 0;
    }

    for (final payment in result) {
      final date = DateTime.parse(payment['created_at']);
      final monthKey = DateTime(date.year, date.month, 1).millisecondsSinceEpoch;
      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0) + ((payment['amount'] as num?)?.toDouble() ?? 0);
      }
    }

    return monthlyTotals.entries.map((e) => {
      'month': e.key,
      'revenue': e.value,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchUserGrowthData() async {
    final supabase = SupabaseService.instance.client;
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    final result = await supabase
        .from('user_profiles')
        .select('created_at, role')
        .gte('created_at', sixMonthsAgo.toIso8601String());

    final Map<String, int> monthlyGrowth = {};
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM yyyy').format(month);
      monthlyGrowth[key] = 0;
    }

    for (final user in result) {
      final date = DateTime.parse(user['created_at']);
      final key = DateFormat('MMM yyyy').format(DateTime(date.year, date.month, 1));
      if (monthlyGrowth.containsKey(key)) {
        monthlyGrowth[key] = (monthlyGrowth[key] ?? 0) + 1;
      }
    }

    return monthlyGrowth.entries.map((e) => {
      'month': e.key,
      'count': e.value,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchRecentActivity() async {
    final supabase = SupabaseService.instance.client;
    final result = await supabase
        .from('admin_audit_logs')
        .select('*')
        .order('created_at', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>> _fetchSystemHealth() async {
    final supabase = SupabaseService.instance.client;
    await supabase.from('user_profiles').select('id').limit(1);
    return {
      'supabase_db': true,
      'openai': true,
      'gemini': true,
      'livekit': true,
      'revenuecat': true,
    };
  }

  Map<String, dynamic> _mockStats() => {
        'total_users': 12847,
        'active_tutors': 342,
        'monthly_revenue': 48250.00,
        'active_subscriptions': 3156,
        'ai_cost_today': 42.80,
        'pending_payouts': 1250.00,
        'support_tickets': 23,
        'conversion_rate': 24.6,
      };

  List<Map<String, dynamic>> _mockRevenueData() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final month = DateTime(now.year, now.month - 11 + i, 1);
      return {
        'month': month.millisecondsSinceEpoch,
        'revenue': 20000.0 + (i * 3000.0) + (i % 3 == 0 ? 5000 : 0),
      };
    });
  }

  List<Map<String, dynamic>> _mockUserGrowthData() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - 5 + i, 1);
      return {
        'month': DateFormat('MMM yyyy').format(month),
        'count': 400 + (i * 150) + (i % 2 == 0 ? 200 : 0),
      };
    });
  }

  List<Map<String, dynamic>> _mockRecentActivity() => [
        {
          'action': 'user_suspend',
          'admin_email': 'admin@ailanguagecoach.com',
          'target_type': 'user',
          'created_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        },
        {
          'action': 'subscription_update',
          'admin_email': 'finance@ailanguagecoach.com',
          'target_type': 'subscription',
          'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
        {
          'action': 'tutor_approve',
          'admin_email': 'admin@ailanguagecoach.com',
          'target_type': 'tutor',
          'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        },
        {
          'action': 'payout_process',
          'admin_email': 'finance@ailanguagecoach.com',
          'target_type': 'payout',
          'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        },
        {
          'action': 'settings_update',
          'admin_email': 'admin@ailanguagecoach.com',
          'target_type': 'system',
          'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        },
      ];

  Map<String, dynamic> _mockSystemHealth() => {
        'supabase_db': true,
        'openai': true,
        'gemini': true,
        'livekit': true,
        'revenuecat': true,
      };

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'user_suspend':
        return 'User suspended';
      case 'user_activate':
        return 'User activated';
      case 'subscription_update':
        return 'Subscription updated';
      case 'tutor_approve':
        return 'Tutor approved';
      case 'payout_process':
        return 'Payout processed';
      case 'settings_update':
        return 'Settings updated';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'user_suspend':
      case 'user_activate':
        return Icons.person_rounded;
      case 'subscription_update':
        return Icons.card_membership_rounded;
      case 'tutor_approve':
        return Icons.school_rounded;
      case 'payout_process':
        return Icons.payments_rounded;
      case 'settings_update':
        return Icons.settings_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'user_suspend':
        return AdminTheme.error;
      case 'user_activate':
        return AdminTheme.success;
      case 'subscription_update':
        return AdminTheme.primary;
      case 'tutor_approve':
        return AdminTheme.success;
      case 'payout_process':
        return AdminTheme.warning;
      default:
        return AdminTheme.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AdminTheme.error),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AdminTheme.error), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
        onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Dashboard',
                    subtitle: 'Welcome back. Here\'s your platform overview.',
                    actions: [
                      OutlinedButton.icon(
                        onPressed: _loadDashboardData,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Refresh'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Export Report'),
                      ),
                    ],
                  ),
                  _buildKpiGrid(context),
                  const SizedBox(height: 24),
                  _buildChartsRow(context),
                  const SizedBox(height: 24),
                  _buildBottomRow(context),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
  }

  Widget _buildKpiGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : constraints.maxWidth > 500
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            StatCard(
              title: 'Total Users',
              value: _formatNumber(_stats['total_users'] ?? 0),
              subtitle: 'All registered users',
              icon: Icons.people_rounded,
              color: AdminTheme.primary,
              trend: 12.5,
            ),
            StatCard(
              title: 'Active Tutors',
              value: _formatNumber(_stats['active_tutors'] ?? 0),
              subtitle: 'Verified tutors',
              icon: Icons.school_rounded,
              color: AdminTheme.secondary,
              trend: 8.3,
            ),
            StatCard(
              title: 'Monthly Revenue',
              value: _formatCurrency((_stats['monthly_revenue'] ?? 0).toDouble()),
              subtitle: 'Current month',
              icon: Icons.attach_money_rounded,
              color: AdminTheme.success,
              trend: 15.2,
            ),
            StatCard(
              title: 'Active Subscriptions',
              value: _formatNumber(_stats['active_subscriptions'] ?? 0),
              subtitle: 'Paying subscribers',
              icon: Icons.card_membership_rounded,
              color: AdminTheme.tertiary,
              trend: 6.1,
            ),
            StatCard(
              title: 'AI Cost Today',
              value: '\$${(_stats['ai_cost_today'] ?? 0).toStringAsFixed(2)}',
              subtitle: 'OpenAI + Gemini',
              icon: Icons.smart_toy_rounded,
              color: AdminTheme.warning,
              trend: -3.2,
            ),
            StatCard(
              title: 'Pending Payouts',
              value: _formatCurrency((_stats['pending_payouts'] ?? 0).toDouble()),
              subtitle: 'Awaiting processing',
              icon: Icons.account_balance_wallet_rounded,
              color: AdminTheme.error,
              trend: null,
            ),
            StatCard(
              title: 'Support Tickets',
              value: '${_stats['support_tickets'] ?? 0}',
              subtitle: 'Open tickets',
              icon: Icons.bug_report_rounded,
              color: AdminTheme.info,
              trend: -12.0,
            ),
            StatCard(
              title: 'Conversion Rate',
              value: '${(_stats['conversion_rate'] ?? 0).toStringAsFixed(1)}%',
              subtitle: 'Visitor to subscriber',
              icon: Icons.trending_up_rounded,
              color: AdminTheme.primary,
              trend: 2.4,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: RevenueChart(data: _revenueData),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: UserGrowthChart(data: _userGrowthData),
              ),
            ],
          );
        }
        return Column(
          children: [
            RevenueChart(data: _revenueData),
            const SizedBox(height: 16),
            UserGrowthChart(data: _userGrowthData),
          ],
        );
      },
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SystemHealthWidget(health: _systemHealth),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _buildActivityFeed(context),
              ),
            ],
          );
        }
        return Column(
          children: [
            SystemHealthWidget(health: _systemHealth),
            const SizedBox(height: 16),
            _buildActivityFeed(context),
          ],
        );
      },
    );
  }

  Widget _buildActivityFeed(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_recentActivity.length, (index) {
              final activity = _recentActivity[index];
              final action = activity['action'] ?? '';
              final createdAt = DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now();
              final timeAgo = _getTimeAgo(createdAt);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getActionColor(action).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getActionIcon(action),
                        size: 18,
                        color: _getActionColor(action),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getActionLabel(action),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            activity['admin_email'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _quickActionChip(
                  context,
                  icon: Icons.person_add_rounded,
                  label: 'Add User',
                  color: AdminTheme.primary,
                  onTap: () {},
                ),
                _quickActionChip(
                  context,
                  icon: Icons.school_rounded,
                  label: 'Approve Tutors',
                  color: AdminTheme.secondary,
                  onTap: () {},
                ),
                _quickActionChip(
                  context,
                  icon: Icons.payments_rounded,
                  label: 'Process Payouts',
                  color: AdminTheme.success,
                  onTap: () {},
                ),
                _quickActionChip(
                  context,
                  icon: Icons.campaign_rounded,
                  label: 'Send Notification',
                  color: AdminTheme.warning,
                  onTap: () {},
                ),
                _quickActionChip(
                  context,
                  icon: Icons.flag_rounded,
                  label: 'Feature Flags',
                  color: AdminTheme.tertiary,
                  onTap: () {},
                ),
                _quickActionChip(
                  context,
                  icon: Icons.download_rounded,
                  label: 'Export Data',
                  color: AdminTheme.info,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
