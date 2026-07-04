import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';

/// Vocabulary page with Spaced Repetition System (SRS) flashcards.
class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  int _currentCardIndex = 0;
  bool _showFront = true;

  // TODO: Replace with actual vocabulary data from repository
  final List<_VocabularyCard> _cards = [
    const _VocabularyCard(
      word: 'Ephemeral',
      pronunciation: '/ɪˈfɛm(ə)r(ə)l/',
      meaning: 'Lasting for a very short time',
      example: 'The ephemeral beauty of cherry blossoms',
      cefrLevel: 'C1',
    ),
    const _VocabularyCard(
      word: 'Ubiquitous',
      pronunciation: '/juːˈbɪkwɪtəs/',
      meaning: 'Present, appearing, or found everywhere',
      example: 'Smartphones have become ubiquitous in modern life',
      cefrLevel: 'C1',
    ),
    const _VocabularyCard(
      word: 'Serendipity',
      pronunciation: '/ˌsɛr(ə)nˈdɪpɪti/',
      meaning: 'The occurrence of events by chance in a happy way',
      example: 'Finding that book was pure serendipity',
      cefrLevel: 'B2',
    ),
    const _VocabularyCard(
      word: 'Resilient',
      pronunciation: '/rɪˈzɪliənt/',
      meaning: 'Able to recover quickly from difficulties',
      example: 'Children are remarkably resilient',
      cefrLevel: 'B2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show vocabulary stats
            },
            icon: const Icon(Icons.bar_chart),
          ),
        ],
      ),
      body: _cards.isEmpty ? _buildEmptyState() : _buildCardView(),
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
              Icons.book_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'No Words Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start learning new words to build your vocabulary.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add vocabulary
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Words'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView() {
    final card = _cards[_currentCardIndex];

    return Column(
      children: [
        // Progress Indicator
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Text(
                '${_currentCardIndex + 1} / ${_cards.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentCardIndex + 1) / _cards.length,
                ),
              ),
            ],
          ),
        ),

        // Flashcard
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFront = !_showFront;
                });
              },
              child: AnimatedSwitcher(
                duration: AppDuration.normal,
                transitionBuilder: (child, animation) {
                  return RotationTransition(turns: animation, child: child);
                },
                child: _showFront
                    ? _buildFrontCard(card)
                    : _buildBackCard(card),
              ),
            ),
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionChip(
                label: 'Hard',
                icon: Icons.sentiment_dissatisfied,
                color: AppColors.error,
                onTap: () => _rateCard(0),
              ),
              _ActionChip(
                label: 'Good',
                icon: Icons.sentiment_neutral,
                color: AppColors.warning,
                onTap: () => _rateCard(1),
              ),
              _ActionChip(
                label: 'Easy',
                icon: Icons.sentiment_satisfied,
                color: AppColors.success,
                onTap: () => _rateCard(2),
              ),
            ],
          ),
        ),

        // Navigation
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentCardIndex > 0
                    ? () {
                        setState(() {
                          _currentCardIndex--;
                          _showFront = true;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(width: AppSpacing.xl),
              TextButton(
                onPressed: () {
                  // TODO: Show vocabulary list
                },
                child: const Text('View All'),
              ),
              const SizedBox(width: AppSpacing.xl),
              IconButton(
                onPressed: _currentCardIndex < _cards.length - 1
                    ? () {
                        setState(() {
                          _currentCardIndex++;
                          _showFront = true;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrontCard(_VocabularyCard card) {
    return Card(
      key: const ValueKey('front'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                card.cefrLevel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              card.word,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              card.pronunciation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            IconButton(
              onPressed: () {
                // TODO: Play pronunciation audio
              },
              icon: Icon(
                Icons.volume_up,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tap to flip',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(_VocabularyCard card) {
    return Card(
      key: const ValueKey('back'),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Meaning',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              card.meaning,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  Text(
                    'Example',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '"${card.example}"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tap to flip back',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rateCard(int rating) {
    // TODO: Update SRS interval based on rating
    if (_currentCardIndex < _cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showFront = true;
      });
    } else {
      // Show completion dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Session Complete!'),
          content: const Text('Great job! You\'ve reviewed all cards.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentCardIndex = 0;
                  _showFront = true;
                });
              },
              child: const Text('Start Over'),
            ),
          ],
        ),
      );
    }
  }
}

class _VocabularyCard {
  final String word;
  final String pronunciation;
  final String meaning;
  final String example;
  final String cefrLevel;

  const _VocabularyCard({
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.example,
    required this.cefrLevel,
  });
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.round),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.round),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
