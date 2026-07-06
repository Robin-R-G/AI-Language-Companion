import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/data_table_widget.dart';
import '../widgets/wallet_transaction_dialog.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _supabase = Supabase.instance.client;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _numberFormat = NumberFormat.compact();
  final _searchController = TextEditingController();
  bool _isLoading = true;

  double _totalCreditsInCirculation = 0;
  int _creditsIssuedToday = 0;
  int _creditsRedeemed = 0;
  double _totalWalletBalance = 0;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _creditPacks = [];
  List<Map<String, dynamic>> _walletRules = [];
  List<Map<String, dynamic>> _userBalances = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  List<Map<String, dynamic>> _filteredBalances = [];
  String _activeTab = 'transactions';

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final walletsRes = await _supabase.from('wallets').select('*');
      final wallets = List<Map<String, dynamic>>.from(walletsRes);
      _totalWalletBalance = wallets.fold(0, (sum, w) => sum + ((w['balance'] as num?)?.toDouble() ?? 0));
      _totalCreditsInCirculation = _totalWalletBalance;

      final txRes = await _supabase
          .from('wallet_transactions')
          .select('*, wallets(user_id, user_profiles(display_name, email))')
          .order('created_at', ascending: false)
          .limit(200);
      _transactions = List<Map<String, dynamic>>.from(txRes);
      _filteredTransactions = List.from(_transactions);

      for (final tx in _transactions) {
        final createdAt = DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now();
        if (createdAt.isAfter(todayStart)) {
          if (tx['type'] == 'credit') {
            _creditsIssuedToday += ((tx['amount'] as num?)?.toInt() ?? 0).abs();
          } else if (tx['type'] == 'debit') {
            _creditsRedeemed += ((tx['amount'] as num?)?.toInt() ?? 0).abs();
          }
        }
      }

      final packsRes = await _supabase
          .from('credit_packs')
          .select('*')
          .order('price', ascending: true);
      _creditPacks = List<Map<String, dynamic>>.from(packsRes);

      final rulesRes = await _supabase.from('wallet_rules').select('*');
      _walletRules = List<Map<String, dynamic>>.from(rulesRes);

      final balancesRes = await _supabase
          .from('wallets')
          .select('*, user_profiles(display_name, email)')
          .order('balance', ascending: false)
          .limit(100);
      _userBalances = List<Map<String, dynamic>>.from(balancesRes);
      _filteredBalances = List.from(_userBalances);

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterData(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredTransactions = _transactions.where((tx) {
        final email = tx['wallets']?['user_profiles']?['email']?.toString().toLowerCase() ?? '';
        final type = tx['type']?.toString().toLowerCase() ?? '';
        final desc = tx['description']?.toString().toLowerCase() ?? '';
        return email.contains(q) || type.contains(q) || desc.contains(q);
      }).toList();
      _filteredBalances = _userBalances.where((w) {
        final email = w['user_profiles']?['email']?.toString().toLowerCase() ?? '';
        final name = w['user_profiles']?['display_name']?.toString().toLowerCase() ?? '';
        return email.contains(q) || name.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Wallet & AI Credits',
          subtitle: 'Manage wallet balances, credit packs, and transactions',
          trailing: Row(
            children: [
              IconButton(
                onPressed: _loadWalletData,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          _buildStatsCards(isDesktop),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 16),
          _buildTabContent(),
        ],
      ],
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.8 : 1.6,
          children: [
            StatCard(
              title: 'Credits in Circulation',
              value: _numberFormat.format(_totalCreditsInCirculation),
              subtitle: 'Total active credits',
              icon: Icons.account_balance_wallet_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Credits Issued Today',
              value: _numberFormat.format(_creditsIssuedToday),
              subtitle: 'New credits added',
              icon: Icons.add_circle_outline_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Credits Redeemed',
              value: _numberFormat.format(_creditsRedeemed),
              subtitle: 'Used today',
              icon: Icons.remove_circle_outline_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Total Wallet Balance',
              value: _currencyFormat.format(_totalWalletBalance),
              subtitle: 'Combined balances',
              icon: Icons.savings_rounded,
              color: AdminTheme.secondary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('transactions', 'Transactions'),
      ('packs', 'Credit Packs'),
      ('rules', 'Wallet Rules'),
      ('balances', 'User Balances'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _activeTab == tab.$1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ChoiceChip(
                label: Text(tab.$2, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (_) => setState(() => _activeTab = tab.$1),
                selectedColor: AdminTheme.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: isSelected ? AdminTheme.primary : Theme.of(context).colorScheme.onBackground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'transactions':
        return _buildTransactionsTab();
      case 'packs':
        return _buildCreditPacksTab();
      case 'rules':
        return _buildWalletRulesTab();
      case 'balances':
        return _buildBalancesTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SearchField(
            hintText: 'Search transactions...',
            controller: _searchController,
            onChanged: _filterData,
          ),
        ),
        AdminDataTable(
          columns: ['ID', 'User', 'Type', 'Amount', 'Balance After', 'Description', 'Date'],
          rows: _filteredTransactions.map((tx) {
            final type = tx['type'] ?? 'unknown';
            final badgeType = switch (type) {
              'credit' => BadgeType.success,
              'debit' => BadgeType.error,
              'purchase' => BadgeType.info,
              _ => BadgeType.neutral,
            };
            final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
            final balanceAfter = (tx['balance_after'] as num?)?.toDouble() ?? 0;

            return [
              Text(
                (tx['id'] ?? '').toString().substring(0, 8),
                style: const TextStyle(fontSize: 12),
              ),
              Text(tx['wallets']?['user_profiles']?['email'] ?? 'N/A'),
              StatusBadge(label: type, type: badgeType),
              Text(
                '${amount >= 0 ? '+' : ''}${_numberFormat.format(amount)}',
                style: TextStyle(
                  color: amount >= 0 ? AdminTheme.success : AdminTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(_numberFormat.format(balanceAfter)),
              Flexible(
                child: Text(
                  tx['description'] ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy HH:mm').format(
                  DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now(),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreditPacksTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Credit Pack Configurations', style: Theme.of(context).textTheme.titleLarge),
            ElevatedButton.icon(
              onPressed: () => _showAddPackDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Pack'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AdminDataTable(
          columns: ['Name', 'Credits', 'Price', 'Bonus', 'Popular', 'Active', 'Actions'],
          rows: _creditPacks.map((pack) {
            return [
              Text(pack['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(_numberFormat.format((pack['credits'] as num?)?.toInt() ?? 0)),
              Text(_currencyFormat.format((pack['price'] as num?)?.toDouble() ?? 0)),
              Text('${(pack['bonus_credits'] as num?)?.toInt() ?? 0}'),
              StatusBadge(
                label: (pack['is_popular'] ?? false) ? 'Popular' : 'Normal',
                type: (pack['is_popular'] ?? false) ? BadgeType.info : BadgeType.neutral,
              ),
              StatusBadge(
                label: (pack['is_active'] ?? false) ? 'Active' : 'Inactive',
                type: (pack['is_active'] ?? false) ? BadgeType.success : BadgeType.neutral,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showEditPackDialog(pack),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _togglePackStatus(pack),
                    icon: Icon(
                      (pack['is_active'] ?? false)
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 18,
                    ),
                    tooltip: (pack['is_active'] ?? false) ? 'Deactivate' : 'Activate',
                  ),
                ],
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWalletRulesTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wallet Rules', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_walletRules.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No wallet rules configured'),
                ),
              )
            else
              ..._walletRules.map((rule) => _buildRuleItem(rule)),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(Map<String, dynamic> rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getRuleIcon(rule['type'] ?? ''),
              color: AdminTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule['name'] ?? 'Rule',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  rule['description'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge(
            label: (rule['is_active'] ?? false) ? 'Active' : 'Inactive',
            type: (rule['is_active'] ?? false) ? BadgeType.success : BadgeType.neutral,
          ),
        ],
      ),
    );
  }

  IconData _getRuleIcon(String type) {
    switch (type) {
      case 'bonus':
        return Icons.card_giftcard_rounded;
      case 'expiry':
        return Icons.timer_rounded;
      case 'minimum':
        return Icons.speed_rounded;
      case 'daily_limit':
        return Icons.today_rounded;
      default:
        return Icons.rule_rounded;
    }
  }

  Widget _buildBalancesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SearchField(
            hintText: 'Search users...',
            controller: _searchController,
            onChanged: _filterData,
          ),
        ),
        AdminDataTable(
          columns: ['User', 'Email', 'Balance', 'Total Earned', 'Total Spent', 'Last Activity'],
          rows: _filteredBalances.map((wallet) {
            final balance = (wallet['balance'] as num?)?.toDouble() ?? 0;
            final totalEarned = (wallet['total_earned'] as num?)?.toDouble() ?? 0;
            final totalSpent = (wallet['total_spent'] as num?)?.toDouble() ?? 0;

            return [
              Text(wallet['user_profiles']?['display_name'] ?? 'N/A'),
              Text(wallet['user_profiles']?['email'] ?? 'N/A'),
              Text(
                _numberFormat.format(balance),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: balance > 0 ? AdminTheme.primary : AdminTheme.darkTextSecondary,
                ),
              ),
              Text(_numberFormat.format(totalEarned)),
              Text(_numberFormat.format(totalSpent)),
              Text(
                wallet['updated_at'] != null
                    ? DateFormat('MMM d, yyyy').format(
                        DateTime.tryParse(wallet['updated_at']) ?? DateTime.now(),
                      )
                    : 'N/A',
                style: const TextStyle(fontSize: 12),
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _showAddPackDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const WalletTransactionDialog(type: 'add_pack'),
    );
    if (result == true) _loadWalletData();
  }

  Future<void> _showEditPackDialog(Map<String, dynamic> pack) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WalletTransactionDialog(type: 'edit_pack', data: pack),
    );
    if (result == true) _loadWalletData();
  }

  Future<void> _togglePackStatus(Map<String, dynamic> pack) async {
    try {
      await _supabase.from('credit_packs').update({
        'is_active': !(pack['is_active'] ?? false),
      }).eq('id', pack['id']);
      _loadWalletData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update pack: $e')),
        );
      }
    }
  }
}
