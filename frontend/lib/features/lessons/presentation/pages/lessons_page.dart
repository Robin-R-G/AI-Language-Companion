import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/models/lesson.dart';
import '../controllers/lessons_controller.dart';

/// Lessons page showing available courses and progress.
class LessonsPage extends ConsumerStatefulWidget {
  const LessonsPage({super.key});

  @override
  ConsumerState<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends ConsumerState<LessonsPage> {
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() {
    final category = _selectedCategory == 'All' ? null : _selectedCategory;
    final difficulty = _selectedDifficulty == 'All' ? null : _selectedDifficulty;
    ref.read(lessonsControllerProvider.notifier).loadLessons(
      category: category,
      difficulty: difficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show filter options
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilters(),

          // Lessons List
          Expanded(
            child: ref.watch(lessonsControllerProvider).when(
              data: (lessons) => lessons.isEmpty
                  ? _buildEmptyState()
                  : _buildLessonsList(lessons),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: AppSpacing.base),
                    Text('Failed to load lessons'),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _loadLessons,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Row(
        children: [
          // Category Filter
          _FilterChip(
            label: _selectedCategory,
            options: const [
              'All',
              'Grammar',
              'Vocabulary',
              'Speaking',
              'Writing',
              'Listening',
            ],
            onSelected: (value) {
              setState(() => _selectedCategory = value);
              _loadLessons();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          // Difficulty Filter
          _FilterChip(
            label: _selectedDifficulty,
            options: const ['All', 'Beginner', 'Intermediate', 'Advanced'],
            onSelected: (value) {
              setState(() => _selectedDifficulty = value);
              _loadLessons();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'No Lessons Found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your filters or check back later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsList(List<Lesson> lessons) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _LessonCard(
          lesson: lessons[index],
          onTap: () {
            context.push('${RouteNames.lessonDetail}/${lessons[index].id}');
          },
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        lesson.category,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      _getCategoryIcon(lesson.category),
                      color: _getCategoryColor(lesson.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (lesson.content != null)
                          Text(
                            lesson.content!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  // Difficulty Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(
                        lesson.difficulty,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      lesson.difficulty,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getDifficultyColor(lesson.difficulty),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Duration
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${lesson.estimatedMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Grammar':
        return AppColors.info;
      case 'Vocabulary':
        return AppColors.success;
      case 'Speaking':
        return AppColors.error;
      case 'Writing':
        return AppColors.warning;
      case 'Listening':
        return AppColors.secondary;
      default:
        return AppColors.primary500;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Grammar':
        return Icons.rule;
      case 'Vocabulary':
        return Icons.book;
      case 'Speaking':
        return Icons.mic;
      case 'Writing':
        return Icons.edit;
      case 'Listening':
        return Icons.hearing;
      default:
        return Icons.school;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return AppColors.success;
      case 'Intermediate':
        return AppColors.warning;
      case 'Advanced':
        return AppColors.error;
      default:
        return AppColors.primary500;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final List<String> options;
  final Function(String) onSelected;

  const _FilterChip({
    required this.label,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((option) {
          return PopupMenuItem(
            value: option,
            child: Row(
              children: [
                if (option == label)
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: AppSpacing.sm),
                Text(option),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
