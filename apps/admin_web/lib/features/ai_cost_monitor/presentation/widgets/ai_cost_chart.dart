import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AiCostChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final NumberFormat currencyFormat;
  final bool showBar;

  const AiCostChart({
    super.key,
    required this.title,
    required this.data,
    required this.currencyFormat,
    this.showBar = false,
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Expanded(
              child: showBar ? _buildBarChart(context) : _buildPieChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final total = data.fold<double>(0, (sum, e) => sum + ((e['value'] as num?)?.toDouble() ?? 0));

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildSections(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildLegend(context, total),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) => ((b['value'] as num?)?.toDouble() ?? 0)
          .compareTo(((a['value'] as num?)?.toDouble() ?? 0)));

    final topItems = sortedData.length > 8 ? sortedData.sublist(0, 8) : sortedData;

    return topItems.asMap().entries.map((entry) {
      final value = (entry.value['value'] as num?)?.toDouble() ?? 0;
      if (value <= 0) return null;
      return PieChartSectionData(
        value: value,
        color: _colors[entry.key % _colors.length],
        radius: 50,
        title: '',
      );
    }).whereType<PieChartSectionData>().toList();
  }

  Widget _buildLegend(BuildContext context, double total) {
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) => ((b['value'] as num?)?.toDouble() ?? 0)
          .compareTo(((a['value'] as num?)?.toDouble() ?? 0)));

    final items = sortedData.length > 8 ? sortedData.sublist(0, 8) : sortedData;

    return SingleChildScrollView(
      child: Column(
        children: items.asMap().entries.map((entry) {
          final value = (entry.value['value'] as num?)?.toDouble() ?? 0;
          final percentage = total > 0 ? (value / total * 100) : 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colors[entry.key % _colors.length],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value['name'] ?? 'Unknown',
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
                  width: 40,
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final maxY = data.map((e) => (e['value'] as num?)?.toDouble() ?? 0).fold<double>(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                currencyFormat.format(rod.toY),
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  final name = data[value.toInt()]['name'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      name.length > 8 ? '${name.substring(0, 8)}...' : name,
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 5 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value['value'] as num?)?.toDouble() ?? 0,
                color: _colors[entry.key % _colors.length],
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
