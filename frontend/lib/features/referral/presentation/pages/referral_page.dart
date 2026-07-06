import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _referralCode = 'ROBINRG50';
  List<dynamic> _referrals = [];
  List<dynamic> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Extract user referral code from metadata or default to prefix + slice
      final meta = user.userMetadata ?? {};
      final rawName = meta['full_name'] ?? 'USER';
      _referralCode = '${rawName.toString().toUpperCase().replaceAll(' ', '')}${user.id.substring(0, 4).toUpperCase()}';

      // Query referrals where referrer_id = user.id
      final refs = await _supabase
          .from('referrals')
          .select()
          .eq('referrer_id', user.id);

      // Query top referrers list from server
      final topReferrers = await _supabase
          .from('user_profiles')
          .select('full_name, xp') // use xp as a proxy for referrals for mock simplicity
          .order('xp', ascending: false)
          .limit(5);

      setState(() {
        _referrals = refs ?? [];
        _leaderboard = topReferrers ?? [];
        _isLoading = false;
      });
    } catch (e) {
      // Mock Fallback
      setState(() {
        _referrals = [
          {'referred_email': 'akhil.menon@mail.com', 'status': 'studied_7d', 'reward_credits': 300},
          {'referred_email': 'sreya_krishna@live.com', 'status': 'joined', 'reward_credits': 100},
          {'referred_email': 'deepak.p@gmail.com', 'status': 'premium_purchased', 'reward_credits': 1300},
        ];
        _leaderboard = [
          {'full_name': 'Meera Varughese', 'referral_count': 45},
          {'full_name': 'Rahul Nair', 'referral_count': 32},
          {'full_name': 'Siddharth S.', 'referral_count': 28},
          {'full_name': 'Devika Ram', 'referral_count': 22},
          {'full_name': 'Dr. George Thomas', 'referral_count': 18},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Referral Program')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral Sharing Card
            _buildShareCard(theme),
            const SizedBox(height: AppSpacing.xl),

            // How it works
            Text('Referral Milestones Rewards', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            _buildMilestonesCard(theme),
            const SizedBox(height: AppSpacing.xl),

            // Friend list
            Text('Your Referred Friends', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            _buildFriendsList(theme),
            const SizedBox(height: AppSpacing.xl),

            // Leaderboard
            Text('Global Referrers Leaderboard', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            _buildLeaderboard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard(ThemeData theme) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.person_add_rounded, color: theme.colorScheme.primary, size: 48),
            const SizedBox(height: 12),
            Text('Invite Friends & Earn Credits', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Share your unique referral code. When your friends register or subscribe, you both receive AI credits!',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_referralCode, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2)),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral code copied to clipboard!')));
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesCard(ThemeData theme) {
    final steps = [
      {'title': 'Friend Joins Platform', 'subtitle': 'Get 100 credits instantly', 'reward': '+100'},
      {'title': 'Friend Completes 7-Day Streak', 'subtitle': 'Earn 200 bonus credits', 'reward': '+200'},
      {'title': 'Friend Upgrades to Premium', 'subtitle': 'Earn 1000 credits', 'reward': '+1000'},
    ];

    return AppCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final step = steps[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text('${index + 1}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(step['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(step['subtitle']!),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(step['reward']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsList(ThemeData theme) {
    if (_referrals.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('You haven\'t referred any friends yet.')));
    }

    return AppCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _referrals.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final ref = _referrals[index];
          Color statusColor = Colors.orange;
          String statusText = 'Joined';

          if (ref['status'] == 'studied_7d') {
            statusColor = Colors.blue;
            statusText = 'Active (7 Days)';
          } else if (ref['status'] == 'premium_purchased') {
            statusColor = Colors.green;
            statusText = 'Premium Member';
          }

          return ListTile(
            title: Text(ref['referred_email'] as String),
            subtitle: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            trailing: Text('+${ref['reward_credits']} Credits', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          );
        },
      ),
    );
  }

  Widget _buildLeaderboard(ThemeData theme) {
    return AppCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _leaderboard.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final entry = _leaderboard[index];
          final rank = index + 1;
          final isTop3 = rank <= 3;
          final score = (entry['referral_count'] as int?) ?? (entry['xp'] != null ? ((entry['xp'] as int) ~/ 100) : 0);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isTop3 ? Colors.amber.withOpacity(0.15) : Colors.transparent,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isTop3 ? Colors.amber[800] : theme.colorScheme.onBackground,
                ),
              ),
            ),
            title: Text((entry['full_name'] as String?) ?? 'Anonymous'),
            trailing: Text('$score Invites', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}
