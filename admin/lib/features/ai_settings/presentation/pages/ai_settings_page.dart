import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  // AI Parameters
  String _selectedModel = 'gpt-4o';
  String _fallbackModel = 'gemini-1.5-pro';
  double _temperature = 0.7;
  double _topP = 0.9;
  int _maxTokens = 2048;

  // Prompts Library
  final List<Map<String, dynamic>> _prompts = [
    {
      'id': 'p1',
      'role': 'Tutor Assistant',
      'content': 'You are an advanced AI language tutor. Provide helpful explanations, grammar feedback, and converse naturally inside vocabulary boundaries.',
      'version': 'v1.4',
      'active': true
    },
    {
      'id': 'p2',
      'role': 'Speech Reviewer',
      'content': 'Analyze speech pronunciation and fluency records, checking accent structures and syntax anomalies.',
      'version': 'v2.1',
      'active': true
    }
  ];

  // Playground States
  final _testInputController = TextEditingController();
  final List<Map<String, String>> _playgroundMessages = [];
  bool _isPlaying = false;

  @override
  void dispose() {
    _testInputController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    // Simulating database storage update on system configuration table
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Engine parameters saved successfully!')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testPromptPlayground() async {
    final text = _testInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _playgroundMessages.add({'role': 'User', 'text': text});
      _isPlaying = true;
      _testInputController.clear();
    });

    try {
      // Direct mock response matching tutor prompt characteristics
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _playgroundMessages.add({
          'role': 'AI Response',
          'text': 'Hello! That is a great question. In English, we use the Present Perfect tense to describe an experience that happened at an unspecified time in the past. For example: "I have visited London." Would you like to practice another sentence?'
        });
      });
    } catch (e) {
      setState(() {
        _playgroundMessages.add({'role': 'System Error', 'text': 'Connection failure.'});
      });
    } finally {
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Parameters & Prompts
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Orchestration Engine',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage system prompt versions, parameter sliders, fallback models, and token boundaries',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Core Parameters Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Model Configurations', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedModel,
                                  decoration: const InputDecoration(labelText: 'Primary LLM Model'),
                                  items: ['gpt-4o', 'gpt-4-turbo', 'gemini-1.5-pro', 'claude-3-5-sonnet'].map((m) {
                                    return DropdownMenuItem(value: m, child: Text(m));
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedModel = val ?? 'gpt-4o'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _fallbackModel,
                                  decoration: const InputDecoration(labelText: 'Secondary Fallback Model'),
                                  items: ['gpt-4-turbo', 'gemini-1.5-flash', 'claude-3-haiku'].map((m) {
                                    return DropdownMenuItem(value: m, child: Text(m));
                                  }).toList(),
                                  onChanged: (val) => setState(() => _fallbackModel = val ?? 'gemini-1.5-flash'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text('Temperature: ${_temperature.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Slider(
                            value: _temperature,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            activeColor: AdminTheme.primary,
                            onChanged: (val) => setState(() => _temperature = val),
                          ),
                          const SizedBox(height: 12),
                          Text('Top P: ${_topP.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Slider(
                            value: _topP,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            activeColor: AdminTheme.secondary,
                            onChanged: (val) => setState(() => _topP = val),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: '$_maxTokens',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Max Completion Tokens'),
                            onChanged: (val) => _maxTokens = int.tryParse(val) ?? 2048,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Save Parameters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Prompt Library Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('System Prompt Library', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _prompts.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final p = _prompts[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  children: [
                                    Text(p['role'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 12),
                                    Chip(
                                      label: Text(p['version'], style: const TextStyle(fontSize: 10)),
                                      backgroundColor: AdminTheme.secondary.withOpacity(0.08),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(p['content']),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                  onPressed: () {},
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
        ),

        // Right Column: Playground console
        Expanded(
          flex: 3,
          child: Card(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Prompt Playground',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Test current system prompt instructions instantly',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
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
                        itemCount: _playgroundMessages.length,
                        itemBuilder: (context, index) {
                          final msg = _playgroundMessages[index];
                          final isUser = msg['role'] == 'User';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['role']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isUser ? AdminTheme.primary : AdminTheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? AdminTheme.primary.withOpacity(0.08)
                                        : AdminTheme.secondary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    msg['text']!,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _testInputController,
                          decoration: const InputDecoration(
                            hintText: 'Type diagnostic user query...',
                            filled: true,
                          ),
                          onFieldSubmitted: (_) => _testPromptPlayground(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isPlaying ? null : _testPromptPlayground,
                        icon: _isPlaying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AdminTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
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
