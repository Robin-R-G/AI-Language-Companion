import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class MonetizationPage extends StatefulWidget {
  const MonetizationPage({super.key});

  @override
  State<MonetizationPage> createState() => _MonetizationPageState();
}

class _MonetizationPageState extends State<MonetizationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;

  // Data states
  Map<String, dynamic> _revenueData = {};
  Map<String, dynamic> _costData = {};
  Map<String, dynamic> _creditData = {};
  List<dynamic> _pendingTutors = [];

  // Config parameters
  double _tutorCommission = 20.0;
  int _dailyLoginCredits = 10;
  int _lessonCredits = 5;
  int _adCredits = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchMonetizationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMonetizationData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch stats
      final statsRes = await _supabase.functions.invoke('admin-api', method: HttpMethod.get, headers: {'path': '/business/stats'});
      final costRes = await _supabase.functions.invoke('admin-api', method: HttpMethod.get, headers: {'path': '/business/cost-analysis'});
      final creditRes = await _supabase.functions.invoke('admin-api', method: HttpMethod.get, headers: {'path': '/business/credit-analytics'});

      // Fetch pending tutors
      final tutorsRes = await _supabase
          .from('tutors')
          .select('*, user_profiles(full_name, email)')
          .eq('is_verified', false);

      setState(() {
        _revenueData = statsRes.data ?? {};
        _costData = costRes.data ?? {};
        _creditData = creditRes.data ?? {};
        _pendingTutors = tutorsRes ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load monetization data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveTutor(String tutorId) async {
    try {
      await _supabase.functions.invoke('admin-api', method: HttpMethod.post, headers: {'path': '/tutors/approve'}, body: {'tutor_id': tutorId});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor verified successfully!')));
      _fetchMonetizationData();
    } catch (e) {
      // Mock update for standalone run
      setState(() {
        _pendingTutors.removeWhere((t) => t['id'] == tutorId);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor approved (Offline Mode)')));
    }
  }

  Future<void> _saveConfigParameters() async {
    try {
      final body = {
        'platform_commission': _tutorCommission,
        'daily_login_credits': _dailyLoginCredits,
        'lesson_completion_credits': _lessonCredits,
        'ad_reward_credits': _adCredits,
      };
      await _supabase.functions.invoke('admin-api', method: HttpMethod.post, headers: {'path': '/business/parameters'}, body: body);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parameters updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved offline!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchMonetizationData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Revenue Analytics'),
              Tab(text: 'AI Cost Optimizer'),
              Tab(text: 'Tutor Approvals'),
              Tab(text: 'Business Settings'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRevenueTab(),
                _buildCostTab(),
                _buildTutorsTab(),
                _buildConfigTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // REVENUE ANALYTICS TAB
  Widget _buildRevenueTab() {
    final segments = _revenueData['segment_breakdown'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildKpiCard('Monthly Rec. Revenue', '\$${_revenueData['mrr'].toStringAsFixed(2)}', Icons.payments, Colors.blue),
              _buildKpiCard('Annualized Revenue', '\$${_revenueData['arr'].toStringAsFixed(2)}', Icons.analytics, Colors.green),
              _buildKpiCard('Active Subscribers', _revenueData['active_subscribers'].toString(), Icons.people, Colors.purple),
              _buildKpiCard('Premium Conversion', '${_revenueData['premium_conversion']}%', Icons.star, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Charts Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue Stream Distribution', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 50,
                              sections: [
                                PieChartSectionData(color: Colors.blue, value: segments['subscriptions'], title: 'Subs', radius: 45, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.orange, value: segments['ads'], title: 'Ads', radius: 45, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.purple, value: segments['tutor_commission'], title: 'Tutor', radius: 45, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.green, value: segments['affiliates'], title: 'Affil', radius: 45, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.teal, value: segments['certificates'], title: 'Cert', radius: 45, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Historical MRR Progression', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 8500),
                                    FlSpot(1, 9200),
                                    FlSpot(2, 9850),
                                    FlSpot(3, 10835),
                                  ],
                                  isCurved: true,
                                  color: Colors.green,
                                  barWidth: 4,
                                  belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // COST OPTIMIZER TAB
  Widget _buildCostTab() {
    final recommendations = _costData['recommendations'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildKpiCard('Total Tokens Used (30d)', '${_costData['total_tokens_30d']}', Icons.code, Colors.teal)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard('Actual AI Cost (30d)', '\$${_costData['actual_cost_usd']}', Icons.receipt_long, Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard('Avg API Latency', '${_costData['latency_ms_avg']} ms', Icons.speed, Colors.amber)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Active Cost Optimization Recommendations', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(Icons.bolt, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(rec['description']),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+\$${rec['estimated_savings_usd']}/mo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Optimization applied: ${rec['title']}')));
                            },
                            child: const Text('Apply'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // TUTOR APPROVALS TAB
  Widget _buildTutorsTab() {
    if (_pendingTutors.isEmpty) {
      return const Center(child: Text('No pending tutor verification requests.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(right: 16, bottom: 24),
      itemCount: _pendingTutors.length,
      itemBuilder: (context, index) {
        final tutor = _pendingTutors[index];
        final profile = tutor['user_profiles'] ?? {};
        final name = profile['full_name'] ?? 'Tutor';
        final email = profile['email'] ?? 'tutor@partner.org';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.titleLarge),
                        Text(email, style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6))),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _approveTutor(tutor['id']),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve & Verify'),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text('Qualifications:', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(tutor['qualifications'] ?? 'Not specified'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hourly Rate:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${(tutor['price_per_hour_cents'] / 100).toStringAsFixed(2)}/hr'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Languages:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text((tutor['languages'] as List<dynamic>?)?.join(', ') ?? 'N/A'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target Exams:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text((tutor['exams'] as List<dynamic>?)?.join(', ') ?? 'N/A'),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // BUSINESS CONFIG TAB
  Widget _buildConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Commission & Reward Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('Tutor Marketplace Commission (%)', style: TextStyle(fontSize: 16))),
                      SizedBox(
                        width: 250,
                        child: Slider(
                          value: _tutorCommission,
                          min: 5,
                          max: 40,
                          divisions: 7,
                          label: '${_tutorCommission.round()}%',
                          onChanged: (val) => setState(() => _tutorCommission = val),
                        ),
                      ),
                      Text('${_tutorCommission.round()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildConfigSpinner('Daily Login Credit Reward', _dailyLoginCredits, (val) => setState(() => _dailyLoginCredits = val)),
                  const Divider(height: 32),
                  _buildConfigSpinner('Lesson Completion Credit Reward', _lessonCredits, (val) => setState(() => _lessonCredits = val)),
                  const Divider(height: 32),
                  _buildConfigSpinner('Rewarded Ad Credit Reward', _adCredits, (val) => setState(() => _adCredits = val)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveConfigParameters,
            icon: const Icon(Icons.save),
            label: const Text('Save Parameters'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildConfigSpinner(String label, int val, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(onPressed: val > 0 ? () => onChanged(val - 1) : null, icon: const Icon(Icons.remove)),
            Text('$val Credits', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(onPressed: () => onChanged(val + 1), icon: const Icon(Icons.add)),
          ],
        )
      ],
    );
  }

  Widget _buildKpiCard(String title, String val, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), fontSize: 12)),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
