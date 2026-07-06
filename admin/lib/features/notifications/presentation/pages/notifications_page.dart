import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedSegment = 'all';
  bool _isSending = false;

  final List<Map<String, String>> _templates = [
    {
      'name': 'streak_reminder',
      'title': 'Keep Your Streak Alive!',
      'body': 'You haven\'t practiced today. Complete a lesson to maintain your streak!'
    },
    {
      'name': 'new_achievement',
      'title': 'New Achievement Unlocked!',
      'body': 'Congratulations! You\'ve earned a new badge!'
    }
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      final res = await supabase.functions.invoke(
        'admin-api',
        method: HttpMethod.post,
        headers: {'path': '/notifications/broadcast'},
        body: {
          'title': _titleController.text.trim(),
          'body': _bodyController.text.trim(),
          'segment': _selectedSegment,
          'type': 'broadcast'
        },
      );

      final count = res.data['data']['count'] ?? 0;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully broadcasted notification to $count users.')),
        );
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Broadcast failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Campaign creator
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Center',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Create custom segmentation notification campaigns and trigger broadcasts',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trigger Broadcast Campaign', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            value: _selectedSegment,
                            decoration: const InputDecoration(labelText: 'Target User Segment'),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Registered Users')),
                              DropdownMenuItem(value: 'premium', child: Text('Active Premium Subscribers Only')),
                            ],
                            onChanged: (val) => setState(() => _selectedSegment = val ?? 'all'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Notification Banner Title'),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bodyController,
                            decoration: const InputDecoration(labelText: 'Message Body Content'),
                            maxLines: 4,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _isSending ? null : _handleBroadcast,
                            icon: const Icon(Icons.send_rounded),
                            label: _isSending ? const Text('Processing Broadcast...') : const Text('Send Broadcast Notification'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Column: Template logs
        Expanded(
          flex: 3,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Templates Library', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Quick templates triggers pre-defined configurations', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _templates.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final tmpl = _templates[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tmpl['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('"${tmpl['title']}"\n${tmpl['body']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _titleController.text = tmpl['title']!;
                              _bodyController.text = tmpl['body']!;
                            });
                          },
                        ),
                      );
                    },
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
