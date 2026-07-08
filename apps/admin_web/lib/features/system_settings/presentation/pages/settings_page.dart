import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/page_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  final _appNameController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _stripeKeyController = TextEditingController();
  final _stripeSecretController = TextEditingController();
  final _paypalClientIdController = TextEditingController();
  final _walletSignupBonusController = TextEditingController();
  final _walletReferralBonusController = TextEditingController();
  final _walletDailyBonusController = TextEditingController();
  final _creditGrammarCheckController = TextEditingController();
  final _creditTranslationController = TextEditingController();
  final _creditAiChatController = TextEditingController();
  final _referralRewardController = TextEditingController();
  final _referralMaxPerUserController = TextEditingController();
  final _adBannerPriceController = TextEditingController();
  final _adInterstitialPriceController = TextEditingController();

  // UPI Payment
  final _upiIdController = TextEditingController(text: 'metherobin@oksbi');
  bool _upiEnabled = true;

  // Tutor Commission
  final _tutorCommissionRateController = TextEditingController(text: '20');
  final _tutorMinPayoutController = TextEditingController(text: '50');
  String _tutorPayoutSchedule = 'weekly';

  bool _maintenanceMode = false;
  bool _voiceEngineActive = true;
  bool _translationsActive = true;
  bool _subOnlyAssessments = false;

  final _liveKitUrlController = TextEditingController(text: 'wss://livekit.ailanguagecoach.com');
  final _revenueCatSecretController = TextEditingController(text: '');

  bool _walletEnabled = true;
  bool _referralsEnabled = true;
  bool _adsEnabled = false;

  Map<String, String> _envVariables = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _supportEmailController.dispose();
    _timezoneController.dispose();
    _stripeKeyController.dispose();
    _stripeSecretController.dispose();
    _paypalClientIdController.dispose();
    _liveKitUrlController.dispose();
    _revenueCatSecretController.dispose();
    _walletSignupBonusController.dispose();
    _walletReferralBonusController.dispose();
    _walletDailyBonusController.dispose();
    _creditGrammarCheckController.dispose();
    _creditTranslationController.dispose();
    _creditAiChatController.dispose();
    _referralRewardController.dispose();
    _referralMaxPerUserController.dispose();
    _adBannerPriceController.dispose();
    _adInterstitialPriceController.dispose();
    _upiIdController.dispose();
    _tutorCommissionRateController.dispose();
    _tutorMinPayoutController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final settingsRes = await _supabase
          .from('system_settings')
          .select('key, value');

      final settingsMap = <String, String>{};
      for (final s in settingsRes) {
        settingsMap[s['key']] = s['value']?.toString() ?? '';
      }

      if (mounted) {
        setState(() {
          _appNameController.text = settingsMap['app_name'] ?? 'AI Language Coach';
          _supportEmailController.text = settingsMap['support_email'] ?? '';
          _timezoneController.text = settingsMap['timezone'] ?? 'UTC';
          _stripeKeyController.text = settingsMap['stripe_publishable_key'] ?? '';
          _stripeSecretController.text = settingsMap['stripe_secret_key'] ?? '';
          _paypalClientIdController.text = settingsMap['paypal_client_id'] ?? '';
          _walletEnabled = settingsMap['wallet_enabled'] != 'false';
          _walletSignupBonusController.text = settingsMap['wallet_signup_bonus'] ?? '50';
          _walletReferralBonusController.text = settingsMap['wallet_referral_bonus'] ?? '25';
          _walletDailyBonusController.text = settingsMap['wallet_daily_bonus'] ?? '5';
          _creditGrammarCheckController.text = settingsMap['credit_grammar_check'] ?? '2';
          _creditTranslationController.text = settingsMap['credit_translation'] ?? '3';
          _creditAiChatController.text = settingsMap['credit_ai_chat'] ?? '1';
          _referralsEnabled = settingsMap['referrals_enabled'] != 'false';
          _referralRewardController.text = settingsMap['referral_reward_amount'] ?? '5';
          _referralMaxPerUserController.text = settingsMap['max_referrals_per_user'] ?? '10';
          _maintenanceMode = settingsMap['maintenance_mode'] == 'true';
          _voiceEngineActive = settingsMap['voice_engine_active'] != 'false';
          _translationsActive = settingsMap['translations_active'] != 'false';
          _subOnlyAssessments = settingsMap['sub_only_assessments'] == 'true';
          _liveKitUrlController.text = settingsMap['livekit_url'] ?? 'wss://livekit.ailanguagecoach.com';
          _revenueCatSecretController.text = settingsMap['revenuecat_secret'] ?? '';
          _adsEnabled = settingsMap['ads_enabled'] == 'true';
          _adBannerPriceController.text = settingsMap['ad_banner_price'] ?? '0.50';
          _adInterstitialPriceController.text = settingsMap['ad_interstitial_price'] ?? '1.00';

          // UPI
          _upiIdController.text = settingsMap['upi_id'] ?? 'metherobin@oksbi';
          _upiEnabled = settingsMap['upi_enabled'] != 'false';

          // Tutor Commission
          _tutorCommissionRateController.text = settingsMap['tutor_commission_rate'] ?? '20';
          _tutorMinPayoutController.text = settingsMap['tutor_min_payout'] ?? '50';
          _tutorPayoutSchedule = settingsMap['tutor_payout_schedule'] ?? 'weekly';

          _envVariables = {
            'SUPABASE_URL': 'https://your-project.supabase.co',
            'SUPABASE_ANON_KEY': '••••••••',
            'OPENAI_API_KEY': '••••••••',
            'STRIPE_SECRET': '••••••••',
            'ENVIRONMENT': 'production',
          };
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final settings = [
        {'key': 'app_name', 'value': _appNameController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'support_email', 'value': _supportEmailController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'timezone', 'value': _timezoneController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'stripe_publishable_key', 'value': _stripeKeyController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'stripe_secret_key', 'value': _stripeSecretController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'paypal_client_id', 'value': _paypalClientIdController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'wallet_enabled', 'value': _walletEnabled.toString(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'wallet_signup_bonus', 'value': _walletSignupBonusController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'wallet_referral_bonus', 'value': _walletReferralBonusController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'wallet_daily_bonus', 'value': _walletDailyBonusController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'credit_grammar_check', 'value': _creditGrammarCheckController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'credit_translation', 'value': _creditTranslationController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'credit_ai_chat', 'value': _creditAiChatController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'referrals_enabled', 'value': _referralsEnabled.toString(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'referral_reward_amount', 'value': _referralRewardController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'max_referrals_per_user', 'value': _referralMaxPerUserController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'ads_enabled', 'value': _adsEnabled.toString(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'ad_banner_price', 'value': _adBannerPriceController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'ad_interstitial_price', 'value': _adInterstitialPriceController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'maintenance_mode', 'value': _maintenanceMode.toString(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'voice_engine_active', 'value': _voiceEngineActive.toString(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'translations_active', 'value': _translationsActive.toString(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'sub_only_assessments', 'value': _subOnlyAssessments.toString(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'livekit_url', 'value': _liveKitUrlController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'revenuecat_secret', 'value': _revenueCatSecretController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        // UPI
        {'key': 'upi_id', 'value': _upiIdController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'upi_enabled', 'value': _upiEnabled.toString(), 'updated_at': DateTime.now().toIso8601String()},
        // Tutor Commission
        {'key': 'tutor_commission_rate', 'value': _tutorCommissionRateController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'tutor_min_payout', 'value': _tutorMinPayoutController.text.trim(), 'updated_at': DateTime.now().toIso8601String()},
        {'key': 'tutor_payout_schedule', 'value': _tutorPayoutSchedule, 'updated_at': DateTime.now().toIso8601String()},
      ];

      await _supabase.from('system_settings').upsert(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AdminTheme.success,
          ),
        );
        _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            title: 'System Settings',
            subtitle: 'Configure platform settings and rules',
            actions: [
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save All'),
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
                    const Icon(Icons.error_outline, size: 48, color: AdminTheme.error),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadSettings, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _buildGeneralSection(),
                  const SizedBox(height: 24),
                  _buildPlatformOperationsSection(),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                    const SizedBox(height: 24),
                    _buildUpiSection(),
                    const SizedBox(height: 24),
                    _buildTutorCommissionSection(),
                    const SizedBox(height: 24),
                    _buildWalletSection(),
                    const SizedBox(height: 24),
                    _buildCreditsSection(),
                    const SizedBox(height: 24),
                    _buildReferralSection(),
                    const SizedBox(height: 24),
                    _buildAdsSection(),
                    const SizedBox(height: 24),
                    _buildEnvSection(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return _buildSectionCard(
      title: 'General Settings',
      children: [
        TextFormField(
          controller: _appNameController,
          decoration: const InputDecoration(labelText: 'App Name'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _supportEmailController,
          decoration: const InputDecoration(labelText: 'Support Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _timezoneController,
          decoration: const InputDecoration(labelText: 'Default Timezone'),
        ),
      ],
    );
  }

  Widget _buildPlatformOperationsSection() {
    return _buildSectionCard(
      title: 'Platform Operations',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Maintenance Mode'),
          subtitle: const Text('Restricts all client app network traffic and displays static maintenance notification page.'),
          value: _maintenanceMode,
          activeColor: AdminTheme.error,
          onChanged: (v) => setState(() => _maintenanceMode = v),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Voice Conversation Module'),
          subtitle: const Text('Enable or disable LiveKit voice call streaming globally.'),
          value: _voiceEngineActive,
          activeColor: AdminTheme.primary,
          onChanged: (v) => setState(() => _voiceEngineActive = v),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Bilingual Helper Translations'),
          subtitle: const Text('Renders word translations option on lessons vocabulary exercises.'),
          value: _translationsActive,
          activeColor: AdminTheme.primary,
          onChanged: (v) => setState(() => _translationsActive = v),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Premium-Only Placement Exam'),
          subtitle: const Text('Restricts placements exams access strictly to active paying subscriptions.'),
          value: _subOnlyAssessments,
          activeColor: AdminTheme.primary,
          onChanged: (v) => setState(() => _subOnlyAssessments = v),
        ),
        const Divider(),
        TextFormField(
          controller: _liveKitUrlController,
          decoration: const InputDecoration(
            labelText: 'LiveKit Server Gateway Host URL',
            prefixIcon: Icon(Icons.cell_tower_rounded, size: 18),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _revenueCatSecretController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'RevenueCat Webhook Shared Secret Key',
            prefixIcon: Icon(Icons.lock_outline, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return _buildSectionCard(
      title: 'Payment Gateway',
      children: [
        TextFormField(
          controller: _stripeKeyController,
          decoration: const InputDecoration(
            labelText: 'Stripe Publishable Key',
            prefixIcon: Icon(Icons.key_outlined, size: 18),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _stripeSecretController,
          decoration: const InputDecoration(
            labelText: 'Stripe Secret Key',
            prefixIcon: Icon(Icons.lock_outline, size: 18),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _paypalClientIdController,
          decoration: const InputDecoration(
            labelText: 'PayPal Client ID',
            prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildUpiSection() {
    return _buildSectionCard(
      title: 'UPI Payment Receiving',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable UPI Payments'),
          subtitle: const Text('Accept payments via UPI (India)'),
          value: _upiEnabled,
          onChanged: (v) => setState(() => _upiEnabled = v),
        ),
        const Divider(),
        TextFormField(
          controller: _upiIdController,
          decoration: const InputDecoration(
            labelText: 'UPI ID',
            hintText: 'e.g. yourname@oksbi',
            helperText: 'Default receiving UPI address for all payments',
            prefixIcon: Icon(Icons.account_balance_rounded, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildTutorCommissionSection() {
    return _buildSectionCard(
      title: 'Tutor Commission & Payouts',
      children: [
        TextFormField(
          controller: _tutorCommissionRateController,
          decoration: const InputDecoration(
            labelText: 'Commission Rate (%)',
            helperText: 'Platform commission deducted from tutor earnings',
            prefixIcon: Icon(Icons.percent_rounded, size: 18),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tutorMinPayoutController,
          decoration: const InputDecoration(
            labelText: 'Minimum Payout Amount',
            helperText: 'Minimum balance required to request a payout',
            prefixIcon: Icon(Icons.monetization_on_outlined, size: 18),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _tutorPayoutSchedule,
          decoration: const InputDecoration(
            labelText: 'Payout Schedule',
            prefixIcon: Icon(Icons.schedule_rounded, size: 18),
          ),
          items: const [
            DropdownMenuItem(value: 'daily', child: Text('Daily')),
            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
            DropdownMenuItem(value: 'biweekly', child: Text('Bi-Weekly')),
            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _tutorPayoutSchedule = v);
          },
        ),
      ],
    );
  }

  Widget _buildWalletSection() {
    return _buildSectionCard(
      title: 'Wallet Rules',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable Wallet System'),
          subtitle: const Text('Allow users to earn and spend credits'),
          value: _walletEnabled,
          onChanged: (v) => setState(() => _walletEnabled = v),
        ),
        const Divider(),
        TextFormField(
          controller: _walletSignupBonusController,
          decoration: const InputDecoration(
            labelText: 'Signup Bonus Credits',
            helperText: 'Credits given on new user registration',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _walletReferralBonusController,
          decoration: const InputDecoration(
            labelText: 'Referral Bonus Credits',
            helperText: 'Credits given for successful referral',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _walletDailyBonusController,
          decoration: const InputDecoration(
            labelText: 'Daily Login Bonus',
            helperText: 'Credits given for daily login',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildCreditsSection() {
    return _buildSectionCard(
      title: 'Credit Costs',
      children: [
        TextFormField(
          controller: _creditGrammarCheckController,
          decoration: const InputDecoration(labelText: 'Grammar Check (credits)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _creditTranslationController,
          decoration: const InputDecoration(labelText: 'Translation (credits)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _creditAiChatController,
          decoration: const InputDecoration(labelText: 'AI Chat (credits per message)'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildReferralSection() {
    return _buildSectionCard(
      title: 'Referral Rewards Configuration',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable Referral Program'),
          value: _referralsEnabled,
          onChanged: (v) => setState(() => _referralsEnabled = v),
        ),
        const Divider(),
        TextFormField(
          controller: _referralRewardController,
          decoration: const InputDecoration(
            labelText: 'Referral Reward Amount (Credits)',
            helperText: 'Credits given to both referrer and referred user',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _referralMaxPerUserController,
          decoration: const InputDecoration(
            labelText: 'Max Referrals Per User',
            helperText: 'Maximum number of referrals allowed',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildAdsSection() {
    return _buildSectionCard(
      title: 'Advertisement Rules',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable Advertisements'),
          value: _adsEnabled,
          onChanged: (v) => setState(() => _adsEnabled = v),
        ),
        const Divider(),
        TextFormField(
          controller: _adBannerPriceController,
          decoration: const InputDecoration(
            labelText: 'Banner Ad Price (\$)',
            helperText: 'Cost per 1000 impressions',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _adInterstitialPriceController,
          decoration: const InputDecoration(
            labelText: 'Interstitial Ad Price (\$)',
            helperText: 'Cost per 1000 impressions',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildEnvSection() {
    return _buildSectionCard(
      title: 'Environment Variables',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdminTheme.darkBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminTheme.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _envVariables.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AdminTheme.primaryLight,
                        ),
                      ),
                    ),
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AdminTheme.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Environment variables are masked for security. Edit in Supabase dashboard.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
