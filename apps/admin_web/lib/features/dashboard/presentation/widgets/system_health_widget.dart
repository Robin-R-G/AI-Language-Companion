import 'package:flutter/material.dart';
import '../../../../core/theme/admin_theme.dart';

class SystemHealthWidget extends StatelessWidget {
  final Map<String, dynamic> health;

  const SystemHealthWidget({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System Health',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _overallStatusBadge(context),
              ],
            ),
            const SizedBox(height: 20),
            _buildServiceRow(
              context,
              name: 'Supabase Database',
              status: health['supabase_db'] ?? false,
              icon: Icons.storage_rounded,
              latency: '12ms',
            ),
            _buildServiceRow(
              context,
              name: 'OpenAI API',
              status: health['openai'] ?? false,
              icon: Icons.smart_toy_rounded,
              latency: '245ms',
            ),
            _buildServiceRow(
              context,
              name: 'Google Gemini',
              status: health['gemini'] ?? false,
              icon: Icons.auto_awesome_rounded,
              latency: '180ms',
            ),
            _buildServiceRow(
              context,
              name: 'LiveKit Server',
              status: health['livekit'] ?? false,
              icon: Icons.video_call_rounded,
              latency: '28ms',
            ),
            _buildServiceRow(
              context,
              name: 'RevenueCat',
              status: health['revenuecat'] ?? false,
              icon: Icons.receipt_rounded,
              latency: '95ms',
            ),
          ],
        ),
      ),
    );
  }

  Widget _overallStatusBadge(BuildContext context) {
    final allHealthy = health.values.every((v) => v == true);
    final healthyCount = health.values.where((v) => v == true).length;
    final total = health.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: allHealthy
            ? AdminTheme.success.withOpacity(0.1)
            : AdminTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: allHealthy ? AdminTheme.success : AdminTheme.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            allHealthy ? 'All Systems Operational' : '$healthyCount/$total Operational',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: allHealthy ? AdminTheme.success : AdminTheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(
    BuildContext context, {
    required String name,
    required bool status,
    required IconData icon,
    required String latency,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: status
                  ? AdminTheme.success.withOpacity(0.1)
                  : AdminTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: status ? AdminTheme.success : AdminTheme.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            latency,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status ? AdminTheme.success : AdminTheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
