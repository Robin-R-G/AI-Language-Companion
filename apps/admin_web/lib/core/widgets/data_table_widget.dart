import 'package:flutter/material.dart';

class AdminDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final Function(int)? onRowTap;
  final Widget? emptyState;
  final int? rowCount;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.emptyState,
    this.rowCount,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return emptyState ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('No data available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          )),
                ],
              ),
            ),
          );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns
              .map((c) => DataColumn(
                    label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ))
              .toList(),
          rows: List.generate(rows.length, (i) {
            return DataRow(
              cells: rows[i].map((w) => DataCell(w)).toList(),
              onSelectChanged: onRowTap != null ? (_) => onRowTap!(i) : null,
            );
          }),
        ),
      ),
    );
  }
}
