import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class PxPipeAnalyticsPage extends StatefulWidget {
  const PxPipeAnalyticsPage({super.key});

  @override
  State<PxPipeAnalyticsPage> createState() => _PxPipeAnalyticsPageState();
}

class _PxPipeAnalyticsPageState extends State<PxPipeAnalyticsPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _metrics = [];

  @override
  void initState() {
    super.initState();
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    setState(() => _isLoading = true);
    try {
      final res = await _supabase
          .from('pxpipe_analytics')
          .select('*')
          .order('created_at', ascending: false)
          .limit(100);
      setState(() {
        _metrics = res ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load PxPipe metrics: $e');
      setState(() {
        _metrics = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalRequests = _metrics.length;
    final cacheHits = _metrics.where((x) => x['is_cache_hit'] == true).length;
    final hitRate = totalRequests > 0 ? (cacheHits / totalRequests * 100).toStringAsFixed(1) : '0.0';
    
    final totalTokenSavings = _metrics.fold<int>(0, (sum, x) => sum + ((x['token_savings'] ?? 0) as int));
    final totalCostSavings = _metrics.fold<double>(0.0, (sum, x) => sum + (double.tryParse(x['cost_savings_usd']?.toString() ?? '0') ?? 0.0));
    final averageLatency = totalRequests > 0 
        ? (_metrics.fold<int>(0, (sum, x) => sum + ((x['latency_ms'] ?? 0) as int)) / totalRequests).toStringAsFixed(0)
        : '0';

    // Provider distribution
    final providers = <String, int>{};
    for (final x in _metrics) {
      final p = (x['provider_used'] ?? 'unknown') as String;
      providers[p] = (providers[p] ?? 0) + 1;
    }

    // Optimization ratios (original vs optimized)
    final totalOriginal = _metrics.fold<int>(0, (sum, x) => sum + ((x['original_prompt_size'] ?? 0) as int));
    final totalOptimized = _metrics.fold<int>(0, (sum, x) => sum + ((x['optimized_prompt_size'] ?? 0) as int));
    final optimizationRatio = totalOriginal > 0 
        ? ((totalOriginal - totalOptimized) / totalOriginal * 100).toStringAsFixed(1)
        : '0.0';

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
                    'PxPipe AI Optimization Center',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Analyze real-time prompt compaction, caching savings, and routing health logs',
                    style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _fetchMetrics,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh Logs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview KPI Row
          Row(
            children: [
              _buildKpiCard('Total API Requests', '$totalRequests', Icons.api, Colors.blue),
              const SizedBox(width: 16),
              _buildKpiCard('Cache Hit Rate', '$hitRate%', Icons.flash_on, Colors.green),
              const SizedBox(width: 16),
              _buildKpiCard('Tokens Compacted', '$totalTokenSavings', Icons.compress, Colors.purple),
              const SizedBox(width: 16),
              _buildKpiCard('Accumulated Cost Savings', '\$${totalCostSavings.toStringAsFixed(4)}', Icons.savings, Colors.teal),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Optimization Log Table
              Expanded(
                flex: 3,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Optimization Logs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (_metrics.isEmpty)
                          const Center(child: Text('No optimization records found'))
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _metrics.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final log = _metrics[index];
                              final isHit = log['is_cache_hit'] == true;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  isHit ? Icons.flash_on : Icons.bolt,
                                  color: isHit ? Colors.green : Colors.blue,
                                ),
                                title: Text('${log['intent']} (${log['provider_used']?.toString().toUpperCase()})'),
                                subtitle: Text(
                                  'Original: ${log['original_prompt_size']} ch | Optimized: ${log['optimized_prompt_size']} ch | Savings: ${log['token_savings']} tokens',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${log['latency_ms']} ms', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      '+\$${(double.tryParse(log['cost_savings_usd']?.toString() ?? '0') ?? 0.0).toStringAsFixed(4)}',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: Performance Summary Charts/Distributions
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Infrastructure Highlights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            _buildInfoRow('Average API Latency', '$averageLatency ms'),
                            const Divider(),
                            _buildInfoRow('Character Optimization Ratio', '$optimizationRatio%'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Active Providers Distribution', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ...providers.entries.map((e) {
                              final percent = totalRequests > 0 ? (e.value / totalRequests * 100).toStringAsFixed(1) : '0';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${e.value} requests ($percent%)', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
