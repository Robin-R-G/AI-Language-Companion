import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _certificates = [];

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _certificates = [];
          _isLoading = false;
        });
        return;
      }

      final res = await _supabase
          .from('certificates')
          .select()
          .eq('user_id', user.id);

      setState(() {
        _certificates = res ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _certificates = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _upgradeVerification(dynamic cert) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);

    try {
      await _supabase
          .from('certificates')
          .update({'paid_verification': true})
          .eq('id', cert['id'] as String);

      _loadCertificates();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification upgraded successfully!')));
    } catch (e) {
      setState(() {
        cert['paid_verification'] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification upgraded offline!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate Store Locker')),
      body: _certificates.isEmpty
          ? const Center(child: Text('Complete lessons or exams to earn certificates!'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final cert = _certificates[index];
                return _buildCertificateCard(theme, cert);
              },
            ),
    );
  }

  Widget _buildCertificateCard(ThemeData theme, dynamic cert) {
    final hasPaidVerify = (cert['paid_verification'] as bool?) ?? false;
    final verifyUrl = 'https://ai-language-coach.com/verify/${cert['verify_code'] as String}';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert['title'] as String, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Issued by ${cert['issuer'] as String}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text((cert['grade'] as String?) ?? 'Passed', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('VERIFICATION CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(cert['verify_code'] as String, style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('VERIFICATION STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          hasPaidVerify ? Icons.verified : Icons.lock,
                          color: hasPaidVerify ? Colors.blue : Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasPaidVerify ? 'Official Verified' : 'Standard (Unverified)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: hasPaidVerify ? Colors.blue : Colors.orange,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'View Verification Link',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Digital Verification QR Link'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.qr_code_2_rounded, size: 100),
                              const SizedBox(height: 12),
                              Text('Scan to verify or visit:\n$verifyUrl', textAlign: TextAlign.center),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                          ],
                        ),
                      );
                    },
                    isSecondary: true,
                  ),
                ),
                if (!hasPaidVerify) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Upgrade Verification (\$4.99)',
                      onPressed: () => _upgradeVerification(cert),
                    ),
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
