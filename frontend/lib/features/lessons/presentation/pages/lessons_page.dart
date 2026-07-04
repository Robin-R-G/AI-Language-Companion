import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';

/// Lessons page showing available courses and progress.
class LessonsPage extends ConsumerStatefulWidget {
  const LessonsPage({super.key});

  @override
  ConsumerState<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends ConsumerState<LessonsPage> {
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  // TODO: Replace with actual lesson data from repository
  final List<_Lesson> _lessons = [
    const _Lesson(
      id: '1',
      title: 'English Basics',
      description: 'Introduction to everyday English',
      category: 'Grammar',
      difficulty: 'Beginner',
      estimatedMinutes: 15,
      xpReward: 100,
      progress: 100,
    ),
    const _Lesson(
      id: '2',
      title: 'German A1 Greetings',
      description: 'Learn common greetings',
      category: 'Vocabulary',
      difficulty: 'Beginner',
      estimatedMinutes: 20,
      xpReward: 120,
      progress: 60,
    ),
    const _Lesson(
      id: '3',
      title: 'IELTS Writing Task 1',
      description: 'Describe charts and graphs',
      category: 'Writing',
      difficulty: 'Intermediate',
      estimatedMinutes: 30,
      xpReward: 200,
      progress: 0,
    ),
    const _Lesson(
      id: '4',
      title: 'Business English Email',
      description: 'Write professional emails',
      category: 'Writing',
      difficulty: 'Advanced',
      estimatedMinutes: 25,
      xpReward: 180,
      progress: 0,
    ),
    const _Lesson(
      id: '5',
      title: 'Daily Conversation',
      description: 'Everyday dialogues and phrases',
      category: 'Speaking',
      difficulty: 'Beginner',
      estimatedMinutes: 15,
      xpReward: 100,
      progress: 30,
    ),
  ];

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
            child: _lessons.isEmpty ? _buildEmptyState() : _buildLessonsList(),
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
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          // Difficulty Filter
          _FilterChip(
            label: _selectedDifficulty,
            options: const ['All', 'Beginner', 'Intermediate', 'Advanced'],
            onSelected: (value) {
              setState(() => _selectedDifficulty = value);
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

  Widget _buildLessonsList() {
    final filteredLessons = _lessons.where((lesson) {
      final categoryMatch =
          _selectedCategory == 'All' || lesson.category == _selectedCategory;
      final difficultyMatch =
          _selectedDifficulty == 'All' ||
          lesson.difficulty == _selectedDifficulty;
      return categoryMatch && difficultyMatch;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: filteredLessons.length,
      itemBuilder: (context, index) {
        return _LessonCard(
          lesson: filteredLessons[index],
          onTap: () {
            // TODO: Navigate to lesson detail
          },
        );
      },
    );
  }
}

class _Lesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int estimatedMinutes;
  final int xpReward;
  final int progress;

  const _Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.progress,
  });
}

class _LessonCard extends StatelessWidget {
  final _Lesson lesson;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.progress == 100;
    final isInProgress = lesson.progress > 0 && lesson.progress < 100;

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
                        Text(
                          lesson.description,
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
                  // Status Icon
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: AppColors.success)
                  else if (isInProgress)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: lesson.progress / 100,
                        strokeWidth: 3,
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
                  const Spacer(),
                  // XP Reward
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '+${lesson.xpReward} XP',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Progress Bar (if in progress)
              if (isInProgress) ...[
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: lesson.progress / 100,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                ),
              ],
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
