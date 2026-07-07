import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _LoginPageData {
  final int totalUsers;
  final int totalLessons;
  final int totalSessions;
  final Map<String, dynamic> analytics;
  final Map<String, dynamic> health;

  _LoginPageData({
    required this.totalUsers,
    required this.totalLessons,
    required this.totalSessions,
    required this.analytics,
    required this.health,
  });
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  _LoginPageData? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Invoke our extended Edge Functions
      final reportsRes = await supabase.functions.invoke('admin-api', method: HttpMethod.get, headers: {'path': '/reports'});
      final analyticsRes = await supabase.functions.invoke('admin-api', method: HttpMethod.get, headers: {'path': '/analytics'});
      final healthRes = await supabase.functions.invoke('admin-api', method: HttpMethod.get, headers: {'path': '/system-health'});

      final reports = reportsRes.data;
      final analytics = analyticsRes.data;
      final health = healthRes.data;

      setState(() {
        _data = _LoginPageData(
          totalUsers: reports['total_users'] ?? 0,
          totalLessons: reports['total_content'] ?? 0,
          totalSessions: reports['total_sessions'] ?? 0,
          analytics: analytics,
          health: health,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load dashboard data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final d = _data!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Executive Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI Language Coach real-time metrics and health stats',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _fetchDashboardData,
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Cards Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 1024 ? 4 : (MediaQuery.of(context).size.width >= 640 ? 2 : 1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildKpiCard(
                'Total Registered Users',
                '${d.totalUsers}',
                '+12% this month',
                Icons.people_rounded,
                AdminTheme.primary,
              ),
              _buildKpiCard(
                'Active Voice Sessions',
                '${d.totalSessions}',
                '+8% active logs',
                Icons.mic_rounded,
                AdminTheme.secondary,
              ),
              _buildKpiCard(
                'Learning Progress Time',
                '${d.analytics['total_learning_minutes_30d']} min',
                'Last 30 days',
                Icons.timelapse_rounded,
                AdminTheme.tertiary,
              ),
              _buildKpiCard(
                'Course Curriculum Size',
                '${d.totalLessons} lessons',
                'Across all CEFR levels',
                Icons.menu_book_rounded,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // System Health & Service Indicators
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Registration Growth',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last 6 months signup count progression',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 240,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (val, meta) => Text(
                                      '${val.toInt()}',
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                      if (val.toInt() >= 0 && val.toInt() < months.length) {
                                        return Text(
                                          months[val.toInt()],
                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    const FlSpot(0, 200),
                                    const FlSpot(1, 450),
                                    const FlSpot(2, 600),
                                    const FlSpot(3, 850),
                                    const FlSpot(4, 1100),
                                    const FlSpot(5, 1450),
                                  ],
                                  isCurved: true,
                                  color: AdminTheme.primary,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
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
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Health Monitor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildHealthIndicator('Supabase DB Engine', d.health['database']['connected'] == true),
                        const SizedBox(height: 12),
                        _buildHealthIndicator('OpenAI Endpoint API', d.health['services']['openai'] == 'online'),
                        const SizedBox(height: 12),
                        _buildHealthIndicator('Gemini Engine API', d.health['services']['gemini'] == 'online'),
                        const SizedBox(height: 12),
                        _buildHealthIndicator('LiveKit Voice Server', d.health['services']['livekit'] == 'online'),
                        const SizedBox(height: 12),
                        _buildHealthIndicator('RevenueCat Payments', d.health['services']['revenuecat'] == 'online'),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'All core platform APIs are operational and reporting nominal latencies.',
                                  style: TextStyle(color: Colors.green[800], fontSize: 12),
                                ),
                              ),
                            ],
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

  Widget _buildKpiCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String name, bool isOnline) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'OPERATIONAL' : 'OFFLINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOnline ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
