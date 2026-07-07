import 'package:flutter/material.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitSupportTicket() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support ticket submitted successfully! We will get back to you soon.')),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Customer Support',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Have questions or found a bug? Send us a ticket and our support team will help you shortly.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.base),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g. Question about billing/credits',
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: AppSpacing.base),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message details',
                ),
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter message details' : null,
              ),
              const SizedBox(height: AppSpacing.base),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _isSubmitting ? 'Submitting...' : 'Submit Support Ticket',
                  onPressed: _isSubmitting ? () {} : _submitSupportTicket,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Frequently Asked Questions',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildFaqTile('How do I earn AI Credits?', 'You can earn credits by maintaining your daily learning streak, watching optional rewarded ads, or purchasing starter/value packages directly from the subscription screen.'),
              _buildFaqTile('How does manual payment verification work?', 'After submitting your payment proof (receipt screenshot and UTR number), our support staff validates the transaction against the bank logs and awards your plan features or credits.'),
              _buildFaqTile('Can I get a refund on credit packs?', 'Purchases of credit packs are non-refundable once any credits from that pack are consumed. For assistance, contact support via this screen.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Text(answer, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
