import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';

/// AI components for the AI Language Coach application.
/// Follows the Flutter Component Library specification.

/// Typing indicator animation for AI responses.
class TypingIndicator extends StatefulWidget {
  final Color? color;
  final double dotSize;

  const TypingIndicator({
    super.key,
    this.color,
    this.dotSize = 8,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _animation1 = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)),
    );
    _animation2 = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5)),
    );
    _animation3 = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation1.value),
                child: _buildDot(color),
              );
            },
          ),
          SizedBox(width: widget.dotSize * 0.5),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation2.value),
                child: _buildDot(color),
              );
            },
          ),
          SizedBox(width: widget.dotSize * 0.5),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation3.value),
                child: _buildDot(color),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: widget.dotSize,
      height: widget.dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// AI avatar widget.
class AIAvatar extends StatelessWidget {
  final double size;
  final bool isOnline;

  const AIAvatar({
    super.key,
    this.size = 40,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Streaming response widget for AI text output.
class StreamingResponse extends StatelessWidget {
  final String text;
  final bool isStreaming;
  final TextStyle? style;

  const StreamingResponse({
    super.key,
    required this.text,
    this.isStreaming = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: style ??
              theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
        ),
        if (isStreaming)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Generating...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Conversation history list item.
class ConversationHistoryItem extends StatelessWidget {
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final bool isSelected;
  final VoidCallback? onTap;

  const ConversationHistoryItem({
    super.key,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
      leading: Icon(
        Icons.chat_bubble_outline,
        color: isSelected ? theme.colorScheme.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(timestamp),
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}

/// AI thinking indicator with message.
class AIThinkingIndicator extends StatelessWidget {
  final String message;

  const AIThinkingIndicator({
    super.key,
    this.message = 'AI is thinking...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Suggestion chips for AI prompts.
class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String>? onSelected;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(suggestion),
          onPressed: () => onSelected?.call(suggestion),
          avatar: Icon(
            Icons.lightbulb_outline,
            size: 18,
          ),
        );
      }).toList(),
    );
  }
}

/// Prompt card for AI interactions.
class PromptCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const PromptCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.auto_awesome,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Context preview widget for AI conversations.
class ContextPreview extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onRemove;

  const ContextPreview({
    super.key,
    required this.title,
    required this.content,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// AI status widget showing current AI state.
class AIStatusWidget extends StatelessWidget {
  final AIStatus status;

  const AIStatusWidget({
    super.key,
    this.status = AIStatus.ready,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(theme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(theme),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _getStatusText(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getStatusColor(theme),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (status) {
      case AIStatus.ready:
        return AppColors.success;
      case AIStatus.processing:
        return AppColors.warning;
      case AIStatus.error:
        return AppColors.error;
      case AIStatus.offline:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (status) {
      case AIStatus.ready:
        return 'Ready';
      case AIStatus.processing:
        return 'Processing';
      case AIStatus.error:
        return 'Error';
      case AIStatus.offline:
        return 'Offline';
    }
  }
}

enum AIStatus {
  ready,
  processing,
  error,
  offline,
}
