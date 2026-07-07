import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class VoiceMonitorPage extends StatefulWidget {
  const VoiceMonitorPage({super.key});

  @override
  State<VoiceMonitorPage> createState() => _VoiceMonitorPageState();
}

class _VoiceMonitorPageState extends State<VoiceMonitorPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _voiceSessions = [];
  bool _isLoading = true;
  int _activeRoomsCount = 0;

  // Real-time events list
  final List<Map<String, dynamic>> _liveLogs = [
    {'time': '16:04:12', 'event': 'Room room-341a created successfully', 'type': 'info'},
    {'time': '16:04:15', 'event': 'User u1 joined room-341a (LiveKit WebRTC)', 'type': 'info'},
    {'time': '16:04:45', 'event': 'Packet loss warning on room-341a: 2.1%', 'type': 'warning'},
    {'time': '16:05:01', 'event': 'Speech-to-Text finalized on u1: "Present Simple rules"', 'type': 'success'}
  ];

  @override
  void initState() {
    super.initState();
    _fetchVoiceSessions();
  }

  Future<void> _fetchVoiceSessions() async {
    setState(() => _isLoading = true);
    try {
      final res = await supabase
          .from('voice_sessions')
          .select('*, user_profiles(full_name)')
          .order('created_at', ascending: false)
          .limit(10);

      setState(() {
        _voiceSessions = res ?? [];
        _activeRoomsCount = _voiceSessions.where((s) => s['duration'] == null || s['duration'] == 0).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load voice sessions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Sessions list
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice Session Monitor',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitor LiveKit room activities, connection latency, and audio metrics',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _fetchVoiceSessions,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Active LiveKit Rooms', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('$_activeRoomsCount rooms', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Avg Audio Latency', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              const Text('114 ms', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sessions List Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Voice Sessions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _voiceSessions.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final session = _voiceSessions[index];
                                  final fullName = session['user_profiles'] != null ? session['user_profiles']['full_name'] ?? 'User' : 'User';

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: AdminTheme.primary.withOpacity(0.08),
                                      child: Icon(Icons.keyboard_voice_rounded, color: AdminTheme.primary),
                                    ),
                                    title: Text(
                                      fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Room ID: ${session['room_id']} (${session['provider']})'),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Pronunciation: ${session['pronunciation_score']}%',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Fluency: ${session['fluency_score']}%',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Column: Live Logs console
        Expanded(
          flex: 3,
          child: Card(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Real-Time WebRTC Logs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Continuous logs feed from voice servers gateway', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: ListView.builder(
                        itemCount: _liveLogs.length,
                        itemBuilder: (context, index) {
                          final log = _liveLogs[index];
                          final isWarning = log['type'] == 'warning';
                          final isSuccess = log['type'] == 'success';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '[${log['time']}]',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    log['event'],
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: isWarning
                                          ? Colors.orange[800]
                                          : (isSuccess ? Colors.green[800] : Theme.of(context).colorScheme.onBackground),
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
          ),
        ),
      ],
    );
  }
}
