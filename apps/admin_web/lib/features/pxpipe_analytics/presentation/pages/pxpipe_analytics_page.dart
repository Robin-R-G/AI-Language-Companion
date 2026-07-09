import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/stat_card.dart';

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
        _metrics = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _metrics = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalRequests = _metrics.length;
    final cacheHits =
        _metrics.where((x) => x['is_cache_hit'] == true).length;
    final hitRate = totalRequests > 0
        ? (cacheHits / totalRequests * 100).toStringAsFixed(1)
        : '0.0';

    final totalTokenSavings = _metrics.fold<int>(0,
        (sum, x) => sum + ((x['token_savings'] ?? 0) as int));
    final totalCostSavings = _metrics.fold<double>(0.0,
        (sum, x) => sum + (double.tryParse(x['cost_savings_usd']?.toString() ?? '0') ?? 0.0));
    final averageLatency = totalRequests > 0
        ? (_metrics.fold<int>(0,
                    (sum, x) => sum + ((x['latency_ms'] ?? 0) as int)) /
                totalRequests)
            .toStringAsFixed(0)
        : '0';

    final providers = <String, int>{};
    for (final x in _metrics) {
      final p = (x['provider_used'] ?? 'unknown') as String;
      providers[p] = (providers[p] ?? 0) + 1;
    }

    final totalOriginal = _metrics.fold<int>(0,
        (sum, x) => sum + ((x['original_prompt_size'] ?? 0) as int));
    final totalOptimized = _metrics.fold<int>(0,
        (sum, x) => sum + ((x['optimized_prompt_size'] ?? 0) as int));
    final optimizationRatio = totalOriginal > 0
        ? ((totalOriginal - totalOptimized) / totalOriginal * 100)
            .toStringAsFixed(1)
        : '0.0';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'PxPipe AI Optimization Center',
            subtitle:
                'Analyze real-time prompt compaction, caching savings, and routing health logs',
            actions: [
              ElevatedButton.icon(
                onPressed: _fetchMetrics,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh Logs'),
              ),
            ],
          ),
          _buildKpiRow(totalRequests, hitRate, totalTokenSavings,
              totalCostSavings),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildOptimizationLogTable(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildInfrastructureCard(
                          averageLatency, optimizationRatio),
                      const SizedBox(height: 16),
                      _buildProviderDistribution(providers, totalRequests),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(int totalRequests, String hitRate,
      int totalTokenSavings, double totalCostSavings) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total API Requests',
            value: '$totalRequests',
            subtitle: 'Last 100 entries',
            icon: Icons.api_rounded,
            color: AdminTheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Cache Hit Rate',
            value: '$hitRate%',
            subtitle: 'Prompt cache performance',
            icon: Icons.flash_on_rounded,
            color: AdminTheme.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Tokens Compacted',
            value: '$totalTokenSavings',
            subtitle: 'Total savings',
            icon: Icons.compress_rounded,
            color: AdminTheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Cost Savings',
            value: '\$${totalCostSavings.toStringAsFixed(4)}',
            subtitle: 'Accumulated',
            icon: Icons.savings_rounded,
            color: AdminTheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizationLogTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Optimization Logs',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: _metrics.isEmpty
                  ? const Center(child: Text('No optimization records found'))
                  : ListView.separated(
                      itemCount: _metrics.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final log = _metrics[index];
                        final isHit = log['is_cache_hit'] == true;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            isHit ? Icons.flash_on : Icons.bolt,
                            color:
                                isHit ? AdminTheme.success : AdminTheme.primary,
                          ),
                          title: Text(
                              '${log['intent']} (${(log['provider_used'] ?? '').toString().toUpperCase()})'),
                          subtitle: Text(
                            'Original: ${log['original_prompt_size']} ch | Optimized: ${log['optimized_prompt_size']} ch | Savings: ${log['token_savings']} tokens',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${log['latency_ms']} ms',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '+\$${(double.tryParse(log['cost_savings_usd']?.toString() ?? '0') ?? 0.0).toStringAsFixed(4)}',
                                style: const TextStyle(
                                    color: AdminTheme.success,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfrastructureCard(String averageLatency, String optimizationRatio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Infrastructure Highlights',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInfoRow('Average API Latency', '$averageLatency ms'),
            const Divider(),
            _buildInfoRow('Character Optimization Ratio', '$optimizationRatio%'),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderDistribution(
      Map<String, int> providers, int totalRequests) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Providers Distribution',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...providers.entries.map((e) {
              final percent = totalRequests > 0
                  ? (e.value / totalRequests * 100).toStringAsFixed(1)
                  : '0';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${e.value} requests ($percent%)',
                        style: const TextStyle(color: AdminTheme.neutral)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
