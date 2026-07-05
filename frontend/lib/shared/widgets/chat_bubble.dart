// lib/shared/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isOwn;

  const ChatBubble({
    super.key,
    required this.message,
    this.isOwn = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isOwn ? 48 : 16,
          right: isOwn ? 16 : 48,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isOwn
              ? colorScheme.primary
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isOwn ? 16 : 4),
            bottomRight: Radius.circular(isOwn ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isOwn
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
            if (message.grammarFeedback != null) ...[
              const SizedBox(height: 8),
              _GrammarFeedback(
                feedback: message.grammarFeedback!,
                isOwn: isOwn,
              ),
            ],
            if (message.translation != null) ...[
              const SizedBox(height: 8),
              Text(
                message.translation!,
                style: TextStyle(
                  color: isOwn
                      ? colorScheme.onPrimary.withOpacity(0.8)
                      : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GrammarFeedback extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final bool isOwn;

  const _GrammarFeedback({
    required this.feedback,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = feedback['is_correct'] ?? true;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error_outline,
                size: 16,
                color: isCorrect ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                isCorrect ? 'Correct' : 'Grammar Note',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isCorrect ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            if (feedback['corrected'] != null)
              Text(
                feedback['corrected'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (feedback['explanation'] != null)
              Text(
                feedback['explanation'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
