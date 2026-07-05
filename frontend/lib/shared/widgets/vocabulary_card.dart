// lib/shared/widgets/vocabulary_card.dart
import 'package:flutter/material.dart';
import '../models/vocabulary_word.dart';

class VocabularyCard extends StatelessWidget {
  final VocabularyHistory vocabulary;
  final VoidCallback? onReview;
  final bool isFlipped;

  const VocabularyCard({
    super.key,
    required this.vocabulary,
    this.onReview,
    this.isFlipped = false,
  });

  @override
  Widget build(BuildContext context) {
    final word = vocabulary.word;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onReview,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (word != null) ...[
                Text(
                  word.word,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  word.pronunciation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                if (isFlipped) ...[
                  Text(
                    word.meaning,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (word.meaningMalayalam != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      word.meaningMalayalam!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    word.examples.firstOrNull ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Icon(
                    Icons.visibility_off,
                    color: colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to reveal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              _MasteryIndicator(masteryLevel: vocabulary.masteryLevel),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryIndicator extends StatelessWidget {
  final int masteryLevel;

  const _MasteryIndicator({required this.masteryLevel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isFilled = index < masteryLevel;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            size: 16,
            color: isFilled ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }
}
