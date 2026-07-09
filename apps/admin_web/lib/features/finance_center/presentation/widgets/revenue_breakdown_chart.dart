import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RevenueBreakdownChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final NumberFormat currencyFormat;

  const RevenueBreakdownChart({
    super.key,
    required this.title,
    required this.data,
    required this.currencyFormat,
  });

  static const _colors = [
    Color(0xff2563eb),
    Color(0xff7c3aed),
    Color(0xff14b8a6),
    Color(0xfff59e0b),
    Color(0xffef4444),
    Color(0xff06b6d4),
    Color(0xff8b5cf6),
    Color(0xff10b981),
    Color(0xfff97316),
    Color(0xff6366f1),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              const Center(
                child: Text('No data available', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      );
    }

    final total = data.fold<double>(0, (sum, e) => sum + ((e['value'] as num?)?.toDouble() ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildSections(context),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildLegend(context, total),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(BuildContext context) {
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) => ((b['value'] as num?)?.toDouble() ?? 0)
          .compareTo(((a['value'] as num?)?.toDouble() ?? 0)));

    final topItems = sortedData.length > 8 ? sortedData.sublist(0, 8) : sortedData;
    final othersValue = sortedData.length > 8
        ? sortedData.sublist(8).fold<double>(0, (sum, e) => sum + ((e['value'] as num?)?.toDouble() ?? 0))
        : 0.0;

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < topItems.length; i++) {
      final value = (topItems[i]['value'] as num?)?.toDouble() ?? 0;
      if (value <= 0) continue;
      sections.add(PieChartSectionData(
        value: value,
        color: _colors[i % _colors.length],
        radius: 50,
        title: '',
      ));
    }

    if (othersValue > 0) {
      sections.add(PieChartSectionData(
        value: othersValue,
        color: Colors.grey.shade400,
        radius: 50,
        title: '',
      ));
    }

    return sections;
  }

  Widget _buildLegend(BuildContext context, double total) {
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) => ((b['value'] as num?)?.toDouble() ?? 0)
          .compareTo(((a['value'] as num?)?.toDouble() ?? 0)));

    final items = sortedData.length > 8 ? sortedData.sublist(0, 8) : sortedData;
    final othersValue = sortedData.length > 8
        ? sortedData.sublist(8).fold<double>(0, (sum, e) => sum + ((e['value'] as num?)?.toDouble() ?? 0))
        : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            _buildLegendItem(
              context,
              items[i]['name'] ?? 'Unknown',
              (items[i]['value'] as num?)?.toDouble() ?? 0,
              total,
              _colors[i % _colors.length],
            ),
          if (othersValue > 0)
            _buildLegendItem(context, 'Others', othersValue, total, Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    double value,
    double total,
    Color color,
  ) {
    final percentage = total > 0 ? (value / total * 100) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            currencyFormat.format(value),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 45,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
