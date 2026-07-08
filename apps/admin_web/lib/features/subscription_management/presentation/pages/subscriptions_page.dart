import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_table_widget.dart';
import '../../../../core/services/audit_service.dart';
import '../widgets/subscription_detail_dialog.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _planFilter = 'All';
  String _statusFilter = 'All';
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _allSubscriptions = [];
  List<Map<String, dynamic>> _filteredSubscriptions = [];

  int _activeCount = 0;
  double _mrr = 0;
  double _churnRate = 0;
  double _avgRevenue = 0;

  Map<String, double> _revenueByPlan = {};
  List<Map<String, dynamic>> _monthlyTrends = [];

  final _planFilters = ['All', 'Free', 'Basic', 'Pro', 'Premium'];
  final _statusFilters = ['All', 'active', 'cancelled', 'expired'];

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _supabase
          .from('subscriptions')
          .select('*, user_profiles(full_name, email)')
          .order('created_at', ascending: false);

      final subs = List<Map<String, dynamic>>.from(response);

      _activeCount = subs.where((s) => s['status'] == 'active').length;

      _mrr = subs
          .where((s) => s['status'] == 'active')
          .fold<double>(0, (sum, s) => sum + (double.tryParse(s['amount'].toString()) ?? 0));

      final totalSubs = subs.length;
      final cancelledCount =
          subs.where((s) => s['status'] == 'cancelled').length;
      _churnRate = totalSubs > 0 ? (cancelledCount / totalSubs) * 100 : 0;

      _avgRevenue = _activeCount > 0 ? _mrr / _activeCount : 0;

      _revenueByPlan = {};
      for (final sub in subs.where((s) => s['status'] == 'active')) {
        final plan = sub['plan'] ?? 'Free';
        final amount = double.tryParse(sub['amount'].toString()) ?? 0;
        _revenueByPlan[plan] = (_revenueByPlan[plan] ?? 0) + amount;
      }

      _monthlyTrends = _generateMonthlyTrends(subs);

      setState(() {
        _allSubscriptions = subs;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load subscriptions: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateMonthlyTrends(
      List<Map<String, dynamic>> subs) {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthStr = DateFormat('MMM yyyy').format(month);

      final activeInMonth = subs.where((s) {
        final createdAt = DateTime.tryParse(s['created_at'] ?? '') ?? DateTime.now();
        final cancelledAt = s['cancelled_at'] != null
            ? DateTime.tryParse(s['cancelled_at'] ?? '')
            : null;
        return createdAt.isBefore(month.add(const Duration(days: 31))) &&
            (cancelledAt == null || cancelledAt.isAfter(month));
      }).length;

      final revenue = subs
          .where((s) {
            final createdAt = DateTime.tryParse(s['created_at'] ?? '') ?? DateTime.now();
            final cancelledAt = s['cancelled_at'] != null
                ? DateTime.tryParse(s['cancelled_at'] ?? '')
                : null;
            return createdAt.isBefore(month.add(const Duration(days: 31))) &&
                (cancelledAt == null || cancelledAt.isAfter(month)) &&
                s['status'] == 'active';
          })
          .fold<double>(
              0,
              (sum, s) =>
                  sum + (double.tryParse(s['amount'].toString()) ?? 0));

      trends.add({
        'month': monthStr,
        'count': activeInMonth,
        'revenue': revenue,
      });
    }

    return trends;
  }

  void _applyFilters() {
    var results = List<Map<String, dynamic>>.from(_allSubscriptions);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((s) {
        final name =
            (s['user_profiles']?['full_name'] ?? '').toString().toLowerCase();
        final email =
            (s['user_profiles']?['email'] ?? '').toString().toLowerCase();
        final plan = (s['plan'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q) || plan.contains(q);
      }).toList();
    }

    if (_planFilter != 'All') {
      results = results
          .where((s) => (s['plan'] ?? '').toString().toLowerCase() ==
              _planFilter.toLowerCase())
          .toList();
    }

    if (_statusFilter != 'All') {
      results = results
          .where((s) =>
              (s['status'] ?? '').toString().toLowerCase() ==
              _statusFilter.toLowerCase())
          .toList();
    }

    setState(() => _filteredSubscriptions = results);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final val = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(symbol: '\$').format(val);
  }

  BadgeType _statusBadge(String? status) {
    return switch (status) {
      'active' => BadgeType.success,
      'cancelled' => BadgeType.error,
      'expired' => BadgeType.warning,
      'trialing' => BadgeType.info,
      _ => BadgeType.neutral,
    };
  }

  Future<void> _showCreateOrEditSubscriptionDialog({Map<String, dynamic>? subscription}) async {
    final isEdit = subscription != null;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(
      text: subscription?['user_profiles']?['email'] ?? '',
    );
    final amountController = TextEditingController(
      text: (subscription?['amount'] ?? 0).toString(),
    );
    String plan = subscription?['plan'] ?? 'Basic';
    String status = subscription?['status'] ?? 'active';
    String provider = subscription?['provider'] ?? 'stripe';
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Edit Subscription' : 'Create Subscription'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        enabled: !isEdit,
                        decoration: const InputDecoration(
                          labelText: 'User Email',
                          hintText: 'Enter student email',
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: plan,
                        decoration: const InputDecoration(labelText: 'Plan'),
                        items: const [
                          DropdownMenuItem(value: 'Free', child: Text('Free')),
                          DropdownMenuItem(value: 'Basic', child: Text('Basic')),
                          DropdownMenuItem(value: 'Pro', child: Text('Pro')),
                          DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => plan = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                          DropdownMenuItem(value: 'expired', child: Text('Expired')),
                          DropdownMenuItem(value: 'trialing', child: Text('Trialing')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => status = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Billing Amount (\$)',
                          hintText: 'e.g. 9.99',
                        ),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Must be a number' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: provider,
                        decoration: const InputDecoration(labelText: 'Provider'),
                        items: const [
                          DropdownMenuItem(value: 'stripe', child: Text('Stripe')),
                          DropdownMenuItem(value: 'manual', child: Text('Manual')),
                          DropdownMenuItem(value: 'revenuecat', child: Text('RevenueCat')),
                          DropdownMenuItem(value: 'apple', child: Text('Apple App Store')),
                          DropdownMenuItem(value: 'google', child: Text('Google Play Store')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => provider = v);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);
                          try {
                            final supabase = _supabase;
                            final amountVal = double.parse(amountController.text);
                            
                            if (isEdit) {
                              await supabase.from('subscriptions').update({
                                'plan': plan,
                                'status': status,
                                'amount': amountVal,
                                'provider': provider,
                              }).eq('id', subscription['id']);

                              await AuditService.instance.log(
                                action: 'subscription_update',
                                targetType: 'subscription',
                                targetId: subscription['id'],
                                details: {'email': emailController.text},
                              );
                            } else {
                              final userRes = await supabase
                                  .from('user_profiles')
                                  .select('id')
                                  .eq('email', emailController.text.trim())
                                  .maybeSingle();
                              
                              if (userRes == null) {
                                throw Exception('No user found with email ${emailController.text}');
                              }

                              final userProfileId = userRes['id'];

                              await supabase.from('subscriptions').insert({
                                'user_id': userProfileId,
                                'plan': plan,
                                'status': status,
                                'amount': amountVal,
                                'provider': provider,
                                'start_date': DateTime.now().toIso8601String(),
                                'next_billing_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
                              });
                            }
                            
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? 'Subscription updated' : 'Subscription created'),
                                  backgroundColor: AdminTheme.success,
                                ),
                              );
                              _loadSubscriptions();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AdminTheme.error,
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEdit ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Subscription Management',
          subtitle: 'Monitor plans, revenue, and subscriber metrics',
          actions: [
            ElevatedButton.icon(
              onPressed: () => _showCreateOrEditSubscriptionDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Subscription'),
            ),
          ],
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AdminTheme.error),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadSubscriptions,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildChartsRow(),
          const SizedBox(height: 24),
          _buildFiltersAndSearch(),
          const SizedBox(height: 16),
          _buildSubscriptionsTable(),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Active Subscriptions',
              value: '$_activeCount',
              subtitle: 'Currently subscribed users',
              icon: Icons.card_membership_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Monthly Recurring Revenue',
              value: _formatCurrency(_mrr),
              subtitle: 'From active subscriptions',
              icon: Icons.attach_money_rounded,
              color: AdminTheme.primary,
              trend: 8.3,
            ),
            StatCard(
              title: 'Churn Rate',
              value: '${_churnRate.toStringAsFixed(1)}%',
              subtitle: 'Cancellation rate',
              icon: Icons.trending_down_rounded,
              color: AdminTheme.error,
            ),
            StatCard(
              title: 'Avg Revenue / User',
              value: _formatCurrency(_avgRevenue),
              subtitle: 'Per active subscriber',
              icon: Icons.person_add_rounded,
              color: AdminTheme.tertiary,
              trend: 3.1,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildTrendsChart()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildRevenueByPlanChart()),
                ],
              )
            : Column(
                children: [
                  _buildTrendsChart(),
                  const SizedBox(height: 16),
                  _buildRevenueByPlanChart(),
                ],
              );
      },
    );
  }

  Widget _buildTrendsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription Trends',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _monthlyTrends.isEmpty
                  ? const Center(child: Text('No trend data'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.1),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= _monthlyTrends.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _monthlyTrends[idx]['month']
                                        .toString()
                                        .substring(0, 3),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              _monthlyTrends.length,
                              (i) => FlSpot(
                                  i.toDouble(),
                                  (_monthlyTrends[i]['count'] as int)
                                      .toDouble()),
                            ),
                            isCurved: true,
                            color: AdminTheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 4,
                                color: AdminTheme.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AdminTheme.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueByPlanChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue by Plan',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _revenueByPlan.isEmpty
                  ? const Center(child: Text('No revenue data'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _revenueByPlan.entries.map((entry) {
                          final colors = {
                            'Free': AdminTheme.neutral,
                            'Basic': AdminTheme.primary,
                            'Pro': AdminTheme.secondary,
                            'Premium': AdminTheme.warning,
                          };
                          final total = _revenueByPlan.values
                              .fold<double>(0, (sum, v) => sum + v);
                          final pct = total > 0
                              ? (entry.value / total * 100)
                              : 0.0;
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${pct.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            color: colors[entry.key] ??
                                AdminTheme.info,
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _revenueByPlan.entries.map((entry) {
                final colors = {
                  'Free': AdminTheme.neutral,
                  'Basic': AdminTheme.primary,
                  'Pro': AdminTheme.secondary,
                  'Premium': AdminTheme.warning,
                };
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[entry.key] ?? AdminTheme.info,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key}: ${_formatCurrency(entry.value)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              controller: _searchController,
              hintText: 'Search by user name, email, or plan...',
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),
            isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlanFilterChips(),
                      const SizedBox(height: 8),
                      _buildStatusFilterChips(),
                    ],
                  )
                : Row(
                    children: [
                      _buildPlanFilterChips(),
                      const SizedBox(width: 16),
                      _buildStatusFilterChips(),
                    ],
                  ),
          ],
        );
      },
    );
  }

  Widget _buildPlanFilterChips() {
    return Wrap(
      spacing: 6,
      children: _planFilters.map((plan) {
        final isActive = _planFilter == plan;
        return ChoiceChip(
          label: Text(plan, style: const TextStyle(fontSize: 12)),
          selected: isActive,
          onSelected: (_) {
            setState(() => _planFilter = plan);
            _applyFilters();
          },
          selectedColor: AdminTheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive
                ? AdminTheme.primary
                : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilterChips() {
    return Wrap(
      spacing: 6,
      children: _statusFilters.map((status) {
        final isActive = _statusFilter == status;
        final label = status == 'All'
            ? 'All'
            : status[0].toUpperCase() + status.substring(1);
        return ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: isActive,
          onSelected: (_) {
            setState(() => _statusFilter = status);
            _applyFilters();
          },
          selectedColor: AdminTheme.info.withOpacity(0.1),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive
                ? AdminTheme.info
                : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionsTable() {
    final columns = [
      'User',
      'Plan',
      'Status',
      'Amount',
      'Start Date',
      'Next Billing',
      'Actions',
    ];

    final rows = _filteredSubscriptions.map((sub) {
      final userName = sub['user_profiles']?['full_name'] ?? 'Unknown';
      final userEmail = sub['user_profiles']?['email'] ?? '';
      final plan = sub['plan'] ?? 'Free';
      final status = sub['status'] ?? 'unknown';
      final amount = sub['amount'] ?? 0;
      final startDate = sub['start_date'] ?? sub['created_at'];
      final nextBilling = sub['next_billing_date'];
      final avatarLetter =
          userName.toString().isNotEmpty ? userName.toString()[0].toUpperCase() : '?';

      return [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AdminTheme.primary.withOpacity(0.1),
              child: Text(
                avatarLetter,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.primary),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(userName.toString(),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(userEmail.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        _buildPlanBadge(plan.toString()),
        StatusBadge(
          label: status.toString().toUpperCase(),
          type: _statusBadge(status),
        ),
        Text(_formatCurrency(amount),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(_formatDate(startDate)),
        Text(_formatDate(nextBilling)),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, size: 18),
          onSelected: (action) {
            if (action == 'view') {
              showDialog(
                context: context,
                builder: (_) => SubscriptionDetailDialog(subscription: sub),
              );
            } else if (action == 'edit') {
              _showCreateOrEditSubscriptionDialog(subscription: sub);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility_rounded, size: 16),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 16),
                  SizedBox(width: 8),
                  Text('Edit Subscription'),
                ],
              ),
            ),
          ],
        ),
      ];
    }).toList();

    return AdminDataTable(
      columns: columns,
      rows: rows,
      onRowTap: (index) {
        showDialog(
          context: context,
          builder: (_) => SubscriptionDetailDialog(
              subscription: _filteredSubscriptions[index]),
        );
      },
    );
  }

  Widget _buildPlanBadge(String plan) {
    final colors = {
      'Free': AdminTheme.neutral,
      'Basic': AdminTheme.primary,
      'Pro': AdminTheme.secondary,
      'Premium': AdminTheme.warning,
    };
    final color = colors[plan] ?? AdminTheme.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        plan,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
