import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../providers/vocabulary_providers.dart';

/// Vocabulary page with Spaced Repetition System (SRS) flashcards.
class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  int _currentCardIndex = 0;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyVocabularyProvider.notifier).loadVocabulary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(dailyVocabularyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bar_chart)),
        ],
      ),
      body: words.isEmpty ? _buildEmptyState() : _buildCardView(words),
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
                ref.read(dailyVocabularyProvider.notifier).loadVocabulary();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Load Words'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView(List<VocabularyWord> words) {
    final card = words[_currentCardIndex.clamp(0, words.length - 1)];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Text(
                '${_currentCardIndex + 1} / ${words.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentCardIndex + 1) / words.length,
                ),
              ),
            ],
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionChip(
                label: 'Hard',
                icon: Icons.sentiment_dissatisfied,
                color: AppColors.error,
                onTap: () => _rateCard(words, 1),
              ),
              _ActionChip(
                label: 'Good',
                icon: Icons.sentiment_neutral,
                color: AppColors.warning,
                onTap: () => _rateCard(words, 3),
              ),
              _ActionChip(
                label: 'Easy',
                icon: Icons.sentiment_satisfied,
                color: AppColors.success,
                onTap: () => _rateCard(words, 5),
              ),
            ],
          ),
        ),
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
              TextButton(onPressed: () {}, child: const Text('View All')),
              const SizedBox(width: AppSpacing.xl),
              IconButton(
                onPressed: _currentCardIndex < words.length - 1
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

  Widget _buildFrontCard(VocabularyWord card) {
    return Card(
      key: const ValueKey('front'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (card.cefrLevel.isNotEmpty)
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
            if (card.pronunciation.isNotEmpty)
              Text(
                card.pronunciation,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio playback coming soon')),
                );
              },
              icon: Icon(
                Icons.volume_up,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (card.meaningMalayalam.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                card.meaningMalayalam,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
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

  Widget _buildBackCard(VocabularyWord card) {
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
            if (card.examples.isNotEmpty) ...[
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
                      'Example${card.examples.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...card.examples.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '"$e"',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.base),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Mastery: ${card.masteryLevel}/5',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Reviews: ${card.reviewCount}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
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

  void _rateCard(List<VocabularyWord> words, int rating) {
    final card = words[_currentCardIndex];
    ref.read(dailyVocabularyProvider.notifier).updateMastery(card.id, rating);

    if (_currentCardIndex < words.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showFront = true;
      });
    } else {
      showDialog<void>(
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
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
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
      ),
    );
  }
}
