// lib/features/vocabulary/presentation/widgets/flashcard_deck_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_language_coach/shared/theme/app_theme.dart';

class FlashcardDeckWidget extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> flashcards;
  final Function(String cardId, int quality) onCardReviewed;

  const FlashcardDeckWidget({
    super.key,
    required this.flashcards,
    required this.onCardReviewed,
  });

  @override
  ConsumerState<FlashcardDeckWidget> createState() => _FlashcardDeckWidgetState();
}

class _FlashcardDeckWidgetState extends ConsumerState<FlashcardDeckWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;
  bool _showFront = true;
  bool _isDragging = false;
  double _dragExtent = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _showFront = !_showFront;
    });
    if (_showFront) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _swipeCard(int direction) {
    final quality = direction > 0 ? 4 : 2; // 4=good, 2=hard
    widget.onCardReviewed(widget.flashcards[_currentIndex]['id'] as String, quality);

    setState(() {
      _currentIndex++;
      _showFront = true;
      _dragExtent = 0;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: AppColors.success),
            SizedBox(height: 16),
            Text(
              'No cards due for review!',
              style: AppTextStyles.headingMedium,
            ),
            Text(
              'Come back later for more practice.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_currentIndex >= widget.flashcards.length) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 64, color: AppColors.warning),
            SizedBox(height: 16),
            Text(
              'Session Complete!',
              style: AppTextStyles.headingMedium,
            ),
            Text(
              'Great job reviewing your flashcards!',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    final card = widget.flashcards[_currentIndex];

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${_currentIndex + 1}/${widget.flashcards.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.flashcards.length,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        // Flashcard
        Expanded(
          child: GestureDetector(
            onTap: _flipCard,
            onHorizontalDragStart: (details) {
              _isDragging = true;
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragExtent += details.delta.dx;
              });
            },
            onHorizontalDragEnd: (details) {
              if (_dragExtent.abs() > 100) {
                _swipeCard(_dragExtent > 0 ? 1 : -1);
              } else {
                setState(() {
                  _dragExtent = 0;
                });
              }
              _isDragging = false;
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value * 3.14159;
                final isFront = angle < 3.14159 / 2;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle)
                    ..translate(_dragExtent, 0.0),
                  alignment: Alignment.center,
                  child: isFront
                      ? _buildFrontCard(card)
                      : Transform(
                          transform: Matrix4.identity()..rotateY(3.14159),
                          alignment: Alignment.center,
                          child: _buildBackCard(card),
                        ),
                );
              },
            ),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                label: 'Hard',
                color: AppColors.error,
                onTap: () => _swipeCard(-1),
              ),
              _buildActionButton(
                icon: Icons.remove,
                label: 'Good',
                color: AppColors.warning,
                onTap: () {
                  widget.onCardReviewed(card['id'] as String, 3);
                  setState(() => _currentIndex++);
                },
              ),
              _buildActionButton(
                icon: Icons.check,
                label: 'Easy',
                color: AppColors.success,
                onTap: () => _swipeCard(1),
              ),
            ],
          ),
        ),

        // Tap hint
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Tap to flip • Swipe to rate',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (card['word'] as String?) ?? '',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (card['pronunciation'] != null)
              Text(
                (card['pronunciation'] as String?) ?? '',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 16),
            Icon(
              Icons.touch_app,
              size: 32,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildBackCard(Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (card['word'] as String?) ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                (card['definition'] as String?) ?? '',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (card['example'] != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Example:',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (card['example'] as String?) ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
