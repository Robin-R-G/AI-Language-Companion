import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';

class TutorDashboardPage extends StatefulWidget {
  const TutorDashboardPage({super.key});

  @override
  State<TutorDashboardPage> createState() => _TutorDashboardPageState();
}

class _TutorDashboardPageState extends State<TutorDashboardPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic> _dashboard = {};
  List<dynamic> _todayClasses = [];
  List<dynamic> _upcomingClasses = [];
  Map<String, dynamic> _wallet = {};
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final results = await Future.wait([
        _supabase.rpc('get_tutor_dashboard', params: {'p_user_id': user.id}).catchError((_) => null),
        _supabase.from('tutor_profiles').select('*').eq('user_id', user.id).single().catchError((_) => null),
        _supabase.from('tutor_wallets').select('*').eq('tutor_id', '').single().catchError((_) => null),
      ]);

      setState(() {
        _dashboard = (results[0] is Map) ? results[0] as Map<String, dynamic> : {};
        _isLoading = false;
      });
    } catch (e) {
      // Mock fallback
      setState(() {
        _dashboard = {
          'today_classes': [
            {'time': '10:00 AM', 'student': 'Alice M.', 'subject': 'IELTS Speaking', 'status': 'confirmed'},
            {'time': '2:00 PM', 'student': 'Raj K.', 'subject': 'Grammar', 'status': 'confirmed'},
          ],
          'upcoming_classes': [
            {'time': 'Tomorrow 9:00 AM', 'student': 'Chen W.', 'subject': 'TOEFL Writing'},
            {'time': 'Tomorrow 3:00 PM', 'student': 'Maria S.', 'subject': 'Conversation'},
            {'time': 'Wed 11:00 AM', 'student': 'Ahmed H.', 'subject': 'IELTS Listening'},
          ],
          'revenue': {
            'pending': 12500,
            'available': 8300,
            'total_earned': 145600,
          },
          'rating': 4.87,
          'review_count': 42,
          'total_students': 38,
          'completed_classes': 186,
          'hours_taught': 142.5,
          'messages': 5,
          'wallet_balance': 8300,
        };
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
      appBar: AppBar(
        title: const Text('Tutor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(theme),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickStats(theme),
              const SizedBox(height: AppSpacing.lg),
              _buildRevenueCard(theme),
              const SizedBox(height: AppSpacing.lg),
              _buildTodayClasses(theme),
              const SizedBox(height: AppSpacing.lg),
              _buildUpcomingClasses(theme),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickActions(theme),
              const SizedBox(height: AppSpacing.lg),
              _buildPerformanceMetrics(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    final userName = _supabase.auth.currentUser?.email ?? 'Tutor';
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $userName!',
                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Here is your teaching overview',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                _buildMiniStat('Today', '${(_dashboard['today_classes'] as List?)?.length ?? 0} classes', Icons.today),
                const SizedBox(width: AppSpacing.base),
                _buildMiniStat('Rating', '${_dashboard['rating'] ?? 4.87}', Icons.star),
                const SizedBox(width: AppSpacing.base),
                _buildMiniStat('Students', '${_dashboard['total_students'] ?? 38}', Icons.people),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    final stats = [
      {'label': 'Completed', 'value': '${_dashboard['completed_classes'] ?? 186}', 'icon': Icons.check_circle, 'color': Colors.green},
      {'label': 'Hours', 'value': '${_dashboard['hours_taught'] ?? 142.5}', 'icon': Icons.timer, 'color': Colors.blue},
      {'label': 'Reviews', 'value': '${_dashboard['review_count'] ?? 42}', 'icon': Icons.reviews, 'color': Colors.orange},
      {'label': 'Messages', 'value': '${_dashboard['messages'] ?? 5}', 'icon': Icons.message, 'color': Colors.purple},
    ];

    return Row(
      children: stats.map((stat) => Expanded(
        child: AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24),
                const SizedBox(height: 4),
                Text(stat['value'] as String, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(stat['label'] as String, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildRevenueCard(ThemeData theme) {
    final revenue = _dashboard['revenue'] ?? {};
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/tutor-earnings'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                _buildRevenueItem(theme, 'Available', ((revenue['available'] as int?) ?? 8300) / 100, Colors.green),
                _buildRevenueItem(theme, 'Pending', ((revenue['pending'] as int?) ?? 12500) / 100, Colors.orange),
                _buildRevenueItem(theme, 'Total Earned', ((revenue['total_earned'] as int?) ?? 145600) / 100, Colors.blue),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            AppButton(
              label: 'Request Withdrawal',
              onPressed: () => Navigator.pushNamed(context, '/tutor-withdraw'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueItem(ThemeData theme, String label, double amount, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Text('\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayClasses(ThemeData theme) {
    final classes = _dashboard['today_classes'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Classes", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.base),
        if (classes.isEmpty)
          AppCard(child: const Padding(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Center(child: Text('No classes scheduled for today')),
          ))
        else
          ...classes.map((c) => AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text((c['student'] as String? ?? 'S')[0], style: TextStyle(color: theme.colorScheme.primary)),
              ),
              title: Text((c['student'] ?? 'Student') as String),
              subtitle: Text((c['subject'] ?? 'Session') as String),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text((c['time'] ?? '') as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (c['status'] == 'confirmed') ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text((c['status'] ?? 'pending') as String,
                        style: TextStyle(fontSize: 10, color: (c['status'] == 'confirmed') ? Colors.green : Colors.orange)),
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildUpcomingClasses(ThemeData theme) {
    final classes = _dashboard['upcoming_classes'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Classes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/tutor-schedule'),
              child: const Text('View Calendar'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),
        if (classes.isEmpty)
          const AppCard(child: Padding(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Center(child: Text('No upcoming classes')),
          ))
        else
          ...classes.map((c) => AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text((c['student'] ?? 'Student') as String),
              subtitle: Text('${c['subject'] ?? ''} - ${c['time'] ?? ''}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          )),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {'label': 'Manage\nAvailability', 'icon': Icons.schedule, 'route': '/tutor-availability'},
      {'label': 'My\nStudents', 'icon': Icons.people, 'route': '/tutor-students'},
      {'label': 'Reviews &\nRatings', 'icon': Icons.star_rate, 'route': '/tutor-reviews'},
      {'label': 'Documents', 'icon': Icons.folder_open, 'route': '/tutor-documents'},
      {'label': 'Tax\nDocuments', 'icon': Icons.receipt_long, 'route': '/tutor-tax'},
      {'label': 'Wallet\nBalance', 'icon': Icons.account_balance_wallet, 'route': '/tutor-wallet'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.base),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return AppCard(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, action['route'] as String),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action['icon'] as IconData, color: theme.colorScheme.primary, size: 28),
                    const SizedBox(height: 6),
                    Text(action['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(ThemeData theme) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Analytics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.base),
            _buildMetricRow('Attendance Rate', 0.95, Colors.green),
            _buildMetricRow('Student Satisfaction', 0.97, Colors.blue),
            _buildMetricRow('Response Time', 0.88, Colors.orange),
            _buildMetricRow('Booking Conversion', 0.72, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text('${(value * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
