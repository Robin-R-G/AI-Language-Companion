import 'package:flutter/material.dart';
import '../../../../core/theme/admin_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _maintenanceMode = false;
  bool _voiceEngineActive = true;
  bool _translationsActive = true;
  bool _subOnlyAssessments = false;

  final _liveKitUrlController = TextEditingController(text: 'wss://livekit.ailanguagecoach.com');
  final _revenueCatSecretController = TextEditingController(text: 'rc_sk_948194a284e');

  @override
  void dispose() {
    _liveKitUrlController.dispose();
    _revenueCatSecretController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System configuration settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Configurations',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Control global platform states, toggle maintenance mode, and manage feature flags',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Platform Operations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Restricts all client app network traffic and displays static maintenance notification page.'),
                    value: _maintenanceMode,
                    activeColor: Colors.red,
                    onChanged: (val) => setState(() => _maintenanceMode = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Voice Conversation Module', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Enable or disable LiveKit voice call streaming globally.'),
                    value: _voiceEngineActive,
                    activeColor: AdminTheme.primary,
                    onChanged: (val) => setState(() => _voiceEngineActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Bilingual Helper Translations', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Renders word translations option on lessons vocabulary exercises.'),
                    value: _translationsActive,
                    activeColor: AdminTheme.primary,
                    onChanged: (val) => setState(() => _translationsActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Premium-Only Placement Exam', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Restricts placements exams access strictly to active paying subscriptions.'),
                    value: _subOnlyAssessments,
                    activeColor: AdminTheme.primary,
                    onChanged: (val) => setState(() => _subOnlyAssessments = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Environment Gateways Keys', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _liveKitUrlController,
                    decoration: const InputDecoration(labelText: 'LiveKit Server Gateway Host URL'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _revenueCatSecretController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'RevenueCat Webhook Shared Secret Key'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveSettings,
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
        ],
      ),
    );
  }
}
