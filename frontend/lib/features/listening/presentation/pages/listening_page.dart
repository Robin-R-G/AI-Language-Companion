import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Listening Practice screen with audio exercises and comprehension checks.
class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _hasError = false;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  double _progress = 0.0;
  late AnimationController _waveController;

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Airport Announcement',
      'level': 'Beginner',
      'duration': '1:30',
      'description': 'Listen to an airport announcement about gate changes.',
    },
    {
      'title': 'Restaurant Order',
      'level': 'Intermediate',
      'duration': '2:15',
      'description': 'A conversation between a waiter and a customer.',
    },
    {
      'title': 'Lecture: Climate Change',
      'level': 'Advanced',
      'duration': '4:00',
      'description': 'An academic lecture on climate change effects.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening Practice'),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_hasError) return ErrorView(onRetry: _loadData);
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        // Audio Player Card
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(
                      Icons.headphones,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Airport Announcement',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Beginner • 1:30',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Waveform visualization
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(20, (index) {
                        final height = _isPlaying
                            ? (12.0 + (index % 3) * 8.0 + (_waveController.value * 16))
                            : 8.0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 3,
                          height: height.clamp(8.0, 40.0),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(
                              _isPlaying ? 200 : 77,
                            ),
                            borderRadius: AppRadius.roundAll,
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // Progress bar
              Row(
                children: [
                  Text(
                    '0:00',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _progress,
                      onChanged: (val) => setState(() => _progress = val),
                    ),
                  ),
                  Text(
                    '1:30',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlay,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppSpacing.base),
                  // Speed control
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: DropdownButton<double>(
                      value: _playbackSpeed,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      items: [0.75, 1.0, 1.25].map((speed) {
                        return DropdownMenuItem(
                          value: speed,
                          child: Text('${speed}x', style: theme.textTheme.labelMedium),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _playbackSpeed = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Exercises list
        Text(
          'More Exercises',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._exercises.map((exercise) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(
                  Icons.headphones,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                exercise['title'] as String,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${exercise['level']} • ${exercise['duration']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
