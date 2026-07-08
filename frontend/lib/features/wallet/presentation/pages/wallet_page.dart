import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/ad_config.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/ad_banner_widget.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  int _balance = 100;
  List<dynamic> _transactions = [];
  List<dynamic> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Get or initialize wallet
      var wallet = await _supabase
          .from('wallet')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (wallet == null) {
        wallet = await _supabase
            .from('wallet')
            .insert({'user_id': user.id, 'balance': 100})
            .select()
            .single();
      }

      final txs = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', wallet!['id'] as String)
          .order('created_at', ascending: false);

      final pkgs = await _supabase
          .from('credit_packages')
          .select()
          .eq('is_active', true);

      setState(() {
        _balance = (wallet?['balance'] as int?) ?? 0;
        _transactions = txs ?? [];
        _packages = pkgs ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _balance = 0;
        _transactions = [];
        _packages = [];
        _isLoading = false;
      });
    }
  }

  /// Shows a real AdMob rewarded ad via [AdService].
  /// Credits are only awarded after the user watches the full ad.
  Future<void> _watchAdReward() async {
    final adService = AdService.instance;

    if (!adService.isRewardedReady) {
      // Show loading while we try to get the ad
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading ad, please wait a moment…'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    bool creditsAwarded = false;

    final shown = await adService.showRewarded(
      onRewarded: (amount) async {
        creditsAwarded = true;
        // The reward amount from AdMob may vary; we treat each view as 20 credits
        const rewardCredits = 20;
        try {
          final user = _supabase.auth.currentUser;
          if (user == null) return;

          final wallet = await _supabase
              .from('wallet')
              .select()
              .eq('user_id', user.id)
              .single();
          final newBalance = (wallet['balance'] as int) + rewardCredits;

          await _supabase
              .from('wallet')
              .update({'balance': newBalance})
              .eq('id', wallet!['id'] as String);

          await _supabase.from('wallet_transactions').insert({
            'wallet_id': wallet['id'],
            'amount': rewardCredits,
            'type': 'ad_reward',
            'description': 'Watched Rewarded Video Ad',
          });

          await _loadWalletData();
        } catch (e) {
          // Offline fallback
          setState(() {
            _balance += rewardCredits;
            _transactions.insert(0, {
              'amount': rewardCredits,
              'type': 'ad_reward',
              'description': 'Watched Rewarded Video Ad',
              'created_at': DateTime.now().toIso8601String(),
            });
          });
        }
      },
    );

    if (!mounted) return;

    if (shown && creditsAwarded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 +20 AI Credits awarded!'),
          backgroundColor: Color(0xff16a34a),
        ),
      );
    } else if (!shown) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not available right now. Try again shortly.')),
      );
    }
  }


  Future<void> _buyPackage(dynamic pkg) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Simulating Store Purchase: ${pkg['name'] as String}...', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final wallet = await _supabase.from('wallet').select().eq('user_id', user.id).single();
      final newBalance = (wallet['balance'] as int) + (pkg['credits_amount'] as int);

      await _supabase.from('wallet').update({'balance': newBalance}).eq('id', wallet['id'] as String);
      await _supabase.from('wallet_transactions').insert({
        'wallet_id': wallet['id'] as String,
        'amount': pkg['credits_amount'],
        'type': 'purchase',
        'description': 'Purchased package: ${pkg['name'] as String}',
      });

      _loadWalletData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully purchased ${pkg['name'] as String}!')));
    } catch (e) {
      setState(() {
        _balance += pkg['credits_amount'] as int;
        _transactions.insert(0, {
          'amount': pkg['credits_amount'],
          'type': 'purchase',
          'description': 'Purchased package: ${pkg['name'] as String} (Mock)',
          'created_at': DateTime.now().toIso8601String(),
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully purchased ${pkg['name'] as String} offline!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Credits Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(theme),
            const SizedBox(height: AppSpacing.xl),

            // Ad Reward Trigger
            _buildAdRewardSection(theme),
            const SizedBox(height: AppSpacing.xl),

            // Buy Credit Store Packages
            Text('Credit Packages Store', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            _buildStoreGrid(),
            const SizedBox(height: AppSpacing.xl),

            // Transaction History
            Text('Transaction Audit Logs', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            _buildTransactionList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Text('Current Wallet Balance', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 12),
            Text('$_balance Credits', style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Used for RAG Memory queries, AI Voice calls, and writing evaluation engines.', style: TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAdRewardSection(ThemeData theme) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
              radius: 28,
              child: Icon(Icons.ondemand_video, color: theme.colorScheme.secondary, size: 28),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rewarded Ad Credits', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Watch a short video sponsor ad to earn +20 credits.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            AppButton(
              label: 'Watch',
              onPressed: _watchAdReward,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStoreGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final pkg = _packages[index];
        return AppCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(pkg['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Text('+${pkg['credits_amount'] as int} Credits', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _buyPackage(pkg),
                child: Text('\$${((pkg['price_cents'] as int) / 100).toStringAsFixed(2)}'),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(ThemeData theme) {
    if (_transactions.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('No transaction history found.')));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final isGrant = (tx['amount'] as int) > 0;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isGrant ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            child: Icon(
              isGrant ? Icons.arrow_downward : Icons.arrow_upward,
              color: isGrant ? Colors.green : Colors.red,
            ),
          ),
          title: Text((tx['description'] as String?) ?? 'Transaction'),
          subtitle: Text(
            tx['created_at'] != null ? DateTime.parse(tx['created_at'] as String).toLocal().toString().substring(0, 16) : '',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          trailing: Text(
            '${isGrant ? "+" : ""}${tx['amount']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isGrant ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
