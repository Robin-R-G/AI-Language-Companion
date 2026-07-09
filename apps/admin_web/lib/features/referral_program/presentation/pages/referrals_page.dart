import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/data_table_widget.dart';

class ReferralsPage extends StatefulWidget {
  const ReferralsPage({super.key});

  @override
  State<ReferralsPage> createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _referrals = [];
  List<Map<String, dynamic>> _coupons = [];
  List<Map<String, dynamic>> _filteredReferrals = [];

  int _totalReferrals = 0;
  int _activeReferrers = 0;
  int _rewardsGiven = 0;

  double _referralRewardAmount = 5.0;
  int _maxReferralsPerUser = 10;
  bool _referralEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final referralsRes = await _supabase
          .from('referrals')
          .select('*, user_profiles!referrer_id(full_name, email)')
          .order('created_at', ascending: false);

      final couponsRes = await _supabase
          .from('coupons')
          .select('*')
          .order('created_at', ascending: false);

      final settingsRes = await _supabase
          .from('system_settings')
          .select('*')
          .inFilter('key', [
        'referral_reward_amount',
        'max_referrals_per_user',
        'referral_enabled',
      ]);

      final referrals = List<Map<String, dynamic>>.from(referralsRes);
      final coupons = List<Map<String, dynamic>>.from(couponsRes);

      final settingsMap = <String, dynamic>{};
      for (final s in settingsRes) {
        settingsMap[s['key']] = s['value'];
      }

      if (mounted) {
        setState(() {
          _referrals = referrals;
          _coupons = coupons;
          _totalReferrals = referrals.length;
          _activeReferrers =
              referrals.map((r) => r['referrer_id']).toSet().length;
          _rewardsGiven = referrals.where((r) => (r['reward_credits'] ?? 0) > 0).length;
          _referralRewardAmount =
              double.tryParse(settingsMap['referral_reward_amount']?.toString() ?? '') ?? 5.0;
          _maxReferralsPerUser =
              int.tryParse(settingsMap['max_referrals_per_user']?.toString() ?? '') ?? 10;
          _referralEnabled = settingsMap['referral_enabled'] != 'false';
          _applySearch();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load referral data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReferrals = _referrals.where((r) {
        final referrerEmail = (r['user_profiles']?['email'] ?? '').toString().toLowerCase();
        final referredEmail = (r['referred_email'] ?? '').toString().toLowerCase();
        return query.isEmpty ||
            referrerEmail.contains(query) ||
            referredEmail.contains(query);
      }).toList();
    });
  }

  Future<void> _saveRewardSettings() async {
    try {
      await _supabase.from('system_settings').upsert([
        {
          'key': 'referral_reward_amount',
          'value': _referralRewardAmount.toString(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'key': 'max_referrals_per_user',
          'value': _maxReferralsPerUser.toString(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'key': 'referral_enabled',
          'value': _referralEnabled.toString(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward settings saved'),
            backgroundColor: AdminTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  Future<void> _showCouponDialog({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final codeController = TextEditingController(text: existing?['code'] ?? '');
    final discountController = TextEditingController(
      text: existing?['discount_value']?.toString() ?? '10',
    );
    final maxUsesController = TextEditingController(
      text: existing?['usage_limit']?.toString() ?? '100',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Coupon' : 'Create Coupon'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Coupon Code'),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: 'Discount %'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0 || n > 100) return 'Enter 1-100';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: maxUsesController,
                      decoration: const InputDecoration(labelText: 'Max Uses'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final data = {
          'code': codeController.text.trim().toUpperCase(),
          'discount_type': 'percentage',
          'discount_value': double.tryParse(discountController.text) ?? 10,
          'usage_limit': int.tryParse(maxUsesController.text) ?? 100,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (isEdit) {
          await _supabase.from('coupons').update(data).eq('id', existing['id']);
        } else {
          data['used_count'] = 0;
          data['is_active'] = true;
          data['created_at'] = DateTime.now().toIso8601String();
          await _supabase.from('coupons').insert(data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? 'Coupon updated' : 'Coupon created'),
              backgroundColor: AdminTheme.success,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  Future<void> _deleteCoupon(Map<String, dynamic> coupon) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Coupon',
      content: 'Delete coupon "${coupon['code']}"?',
      confirmLabel: 'Delete',
      confirmColor: AdminTheme.error,
    );

    if (confirmed) {
      try {
        await _supabase.from('coupons').delete().eq('id', coupon['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coupon deleted'), backgroundColor: AdminTheme.success),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Referral Program',
            subtitle: 'Manage referrals, rewards, coupons, and affiliates',
            actions: [
              ElevatedButton.icon(
                onPressed: _saveRewardSettings,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Settings'),
              ),
            ],
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AdminTheme.error),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildTabs(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Total Referrals',
              value: '$_totalReferrals',
              subtitle: 'All time',
              icon: Icons.person_add_outlined,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Active Referrers',
              value: '$_activeReferrers',
              subtitle: 'Unique referrers',
              icon: Icons.people_outlined,
              color: AdminTheme.secondary,
            ),
            StatCard(
              title: 'Rewards Given',
              value: '$_rewardsGiven',
              subtitle: 'Credits distributed',
              icon: Icons.card_giftcard_outlined,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Active Coupons',
              value: '${_coupons.where((c) => c['is_active'] == true).length}',
              subtitle: 'Available codes',
              icon: Icons.local_offer_outlined,
              color: AdminTheme.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Referrals'),
              Tab(text: 'Coupons'),
              Tab(text: 'Rewards Config'),
              Tab(text: 'Affiliates'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReferralsTab(),
                _buildCouponsTab(),
                _buildRewardsConfigTab(),
                _buildAffiliatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField(
            hintText: 'Search referrals...',
            controller: _searchController,
          ),
        ),
        Expanded(
          child: AdminDataTable(
            columns: ['Referrer', 'Referred', 'Status', 'Reward', 'Date', 'Actions'],
            rows: _filteredReferrals.map((r) {
              final referrerName = r['user_profiles']?['full_name'] ?? 'Unknown';
              final referrerEmail = r['user_profiles']?['email'] ?? '';
              final referredEmail = r['referred_email'] ?? '-';
              final status = r['status'] ?? 'joined';
              final rewardCredits = r['reward_credits'] ?? 0;
              return [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AdminTheme.primary.withOpacity(0.1),
                      child: Text(
                        referrerName.toString().isNotEmpty ? referrerName.toString()[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(referrerName.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(referrerEmail.toString(), style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(referredEmail.toString()),
                StatusBadge(
                  label: status.toUpperCase(),
                  type: status == 'premium_purchased'
                      ? BadgeType.success
                      : status == 'studied_7d'
                          ? BadgeType.info
                          : BadgeType.warning,
                ),
                Text('$rewardCredits cr'),
                Text(r['created_at'] != null
                    ? DateTime.parse(r['created_at']).toString().substring(0, 10)
                    : '-'),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Referral Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Referrer: $referrerEmail'),
                            Text('Referred: $referredEmail'),
                            Text('Status: $status'),
                            Text('Reward Credits: $rewardCredits'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCouponsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              ElevatedButton.icon(
                onPressed: () => _showCouponDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Coupon'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _coupons.isEmpty
              ? const Center(child: Text('No coupons yet'))
              : AdminDataTable(
                  columns: ['Code', 'Discount', 'Uses', 'Max Uses', 'Status', 'Actions'],
                  rows: _coupons.map((c) {
                    final discountType = c['discount_type'] ?? 'percentage';
                    final discountValue = c['discount_value'] ?? 0;
                    final discountDisplay = discountType == 'percentage' ? '$discountValue%' : '\$$discountValue';
                    return [
                      Text(c['code'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(discountDisplay),
                      Text('${c['used_count'] ?? 0}'),
                      Text('${c['usage_limit'] ?? '-'}'),
                      StatusBadge(
                        label: (c['is_active'] ?? false) ? 'Active' : 'Inactive',
                        type: (c['is_active'] ?? false) ? BadgeType.success : BadgeType.neutral,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showCouponDialog(existing: c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => _deleteCoupon(c),
                          ),
                        ],
                      ),
                    ];
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildRewardsConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reward Engine Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Referral Program'),
                    subtitle: const Text('Allow users to refer friends'),
                    value: _referralEnabled,
                    onChanged: (v) => setState(() => _referralEnabled = v),
                  ),
                  const Divider(height: 32),
                  TextFormField(
                    initialValue: _referralRewardAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Reward Amount (Credits)',
                      helperText: 'Credits given to both referrer and referred user',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        _referralRewardAmount = double.tryParse(v) ?? 5.0,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _maxReferralsPerUser.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Max Referrals Per User',
                      helperText: 'Maximum number of referrals per user',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        _maxReferralsPerUser = int.tryParse(v) ?? 10,
                  ),
                  const SizedBox(height: 24),
                  Text('Reward Rules', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _ruleTile('referrer_reward', 'Referrer gets credits on successful signup'),
                  _ruleTile('referred_reward', 'Referred user gets welcome bonus'),
                  _ruleTile('subscription_reward', 'Bonus when referred user subscribes'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleTile(String key, String description) {
    bool enabled = true;
    return StatefulBuilder(
      builder: (ctx, setTileState) {
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(description),
          value: enabled,
          onChanged: (v) => setTileState(() => enabled = v),
        );
      },
    );
  }

  Widget _buildAffiliatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Affiliate Marketplace', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Manage affiliates and sponsored content partnerships',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _affiliateCard(
                  'Sponsored Content',
                  'Manage paid content placements',
                  Icons.campaign_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _affiliateCard(
                  'Advertisement Rules',
                  'Configure ad placements and rules',
                  Icons.ads_click_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _affiliateCard(
                  'Affiliate Partners',
                  'View and manage affiliate accounts',
                  Icons.handshake_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _affiliateCard(
                  'Payout History',
                  'Track affiliate payouts',
                  Icons.payments_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _affiliateCard(String title, String subtitle, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AdminTheme.primary, size: 32),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
