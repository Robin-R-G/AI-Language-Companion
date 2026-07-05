// lib/shared/widgets/exam_card.dart
import 'package:flutter/material.dart';

class ExamCard extends StatelessWidget {
  final String examType;
  final String title;
  final String? subtitle;
  final bool isLocked;
  final VoidCallback? onTap;

  const ExamCard({
    super.key,
    required this.examType,
    required this.title,
    this.subtitle,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final examColor = _getExamColor(examType);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: examColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    examType.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: examColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (isLocked)
                Icon(
                  Icons.lock,
                  color: colorScheme.onSurfaceVariant,
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getExamColor(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return Colors.blue;
      case 'TOEFL':
        return Colors.green;
      case 'PTE':
        return Colors.orange;
      case 'OET':
        return Colors.red;
      case 'GOETHE':
        return Colors.purple;
      case 'JLPT':
        return Colors.pink;
      case 'TOPIK':
        return Colors.teal;
      case 'HSK':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
