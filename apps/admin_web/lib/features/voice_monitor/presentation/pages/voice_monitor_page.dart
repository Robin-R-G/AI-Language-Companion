import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';

class VoiceMonitorPage extends StatefulWidget {
  const VoiceMonitorPage({super.key});

  @override
  State<VoiceMonitorPage> createState() => _VoiceMonitorPageState();
}

class _VoiceMonitorPageState extends State<VoiceMonitorPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _voiceSessions = [];
  int _activeRoomsCount = 0;
  double _avgLatency = 0;
  final List<Map<String, dynamic>> _liveLogs = [];
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _fetchVoiceSessions();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    _channel = _supabase.channel('voice_sessions_changes');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'voice_sessions',
      callback: (payload) {
        final now = DateTime.now();
        final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        setState(() {
          _liveLogs.insert(0, {
            'time': timeStr,
            'event': 'Change on voice_sessions',
            'type': 'info',
          });
          if (_liveLogs.length > 50) _liveLogs.removeLast();
        });
      },
    ).subscribe();
  }

  Future<void> _fetchVoiceSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _supabase
          .from('voice_sessions')
          .select('*, user_profiles(full_name)')
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _voiceSessions = res;
        _activeRoomsCount = _voiceSessions
            .where((s) => s['duration'] == null || s['duration'] == 0)
            .length;
        // Compute average latency from sessions that have a latency_ms field
        final latencies = _voiceSessions
            .where((s) => s['latency_ms'] != null && (s['latency_ms'] as num) > 0)
            .map<double>((s) => (s['latency_ms'] as num).toDouble())
            .toList();
        _avgLatency = latencies.isNotEmpty
            ? latencies.fold<double>(0, (s, l) => s + l) / latencies.length
            : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load voice sessions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Voice Session Monitor',
            subtitle:
                'Monitor LiveKit room activities, connection latency, and audio metrics',
            actions: [
              IconButton(
                onPressed: _fetchVoiceSessions,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AdminTheme.error),
                    const SizedBox(height: 16),
                    Text(_error!,
                        style: const TextStyle(color: AdminTheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _fetchVoiceSessions,
                        child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricsRow(),
                          const SizedBox(height: 24),
                          Expanded(child: _buildSessionsList()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildLiveLogsPanel(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Active LiveKit Rooms',
            value: '$_activeRoomsCount',
            subtitle: 'Currently streaming',
            icon: Icons.mic_rounded,
            color: AdminTheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Total Sessions',
            value: '${_voiceSessions.length}',
            subtitle: 'Last 50 records',
            icon: Icons.record_voice_over_rounded,
            color: AdminTheme.tertiary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Avg Audio Latency',
            value: _avgLatency > 0 ? '${_avgLatency.toStringAsFixed(0)} ms' : 'N/A',
            subtitle: 'WebRTC gateway',
            icon: Icons.speed_rounded,
            color: AdminTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Voice Sessions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: _voiceSessions.isEmpty
                  ? const Center(child: Text('No voice sessions found'))
                  : ListView.separated(
                      itemCount: _voiceSessions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final session = _voiceSessions[index];
        final profile = session['user_profiles'];
        final fullName =
            profile != null ? profile['full_name'] ?? 'User' : 'User';
                        final isActive = session['duration'] == null ||
                            session['duration'] == 0;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                AdminTheme.primary.withOpacity(0.1),
                            child: Icon(Icons.keyboard_voice_rounded,
                                color: AdminTheme.primary),
                          ),
                          title: Text(fullName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Room: ${session['room_id']} (${session['provider'] ?? 'livekit'})'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusBadge(
                                label: isActive ? 'ACTIVE' : 'ENDED',
                                type: isActive
                                    ? BadgeType.success
                                    : BadgeType.neutral,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pronunciation: ${session['pronunciation_score'] ?? 0}%',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Fluency: ${session['fluency_score'] ?? 0}%',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.5)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveLogsPanel() {
    return Card(
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Real-Time WebRTC Logs',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Continuous logs feed from voice servers gateway',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AdminTheme.darkBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminTheme.darkBorder),
                ),
                padding: const EdgeInsets.all(12),
                child: _liveLogs.isEmpty
                    ? const Center(
                        child: Text(
                          '// Waiting for live events...',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: AdminTheme.darkTextSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _liveLogs.length,
                        itemBuilder: (context, index) {
                          final log = _liveLogs[index];
                          final isWarning = log['type'] == 'warning';
                          final isSuccess = log['type'] == 'success';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '[${log['time']}]',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: AdminTheme.darkTextSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    log['event'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: isWarning
                                          ? AdminTheme.warning
                                          : isSuccess
                                              ? AdminTheme.success
                                              : AdminTheme.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
