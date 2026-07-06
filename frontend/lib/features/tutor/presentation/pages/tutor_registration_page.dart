import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';

class TutorRegistrationPage extends StatefulWidget {
  const TutorRegistrationPage({super.key});
  @override
  State<TutorRegistrationPage> createState() => _TutorRegistrationPageState();
}

class _TutorRegistrationPageState extends State<TutorRegistrationPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;
  final _bioController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _priceController = TextEditingController(text: '20');
  List<String> _selectedLanguages = ['English'];
  List<String> _selectedExams = [];
  List<String> _specializations = [];
  String? _governmentIdUrl;
  String? _certificateUrl;
  String? _introVideoUrl;

  @override
  void dispose() {
    _bioController.dispose();
    _qualificationsController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      await _supabase.from('tutor_profiles').upsert({
        'user_id': user.id,
        'bio': _bioController.text,
        'qualifications': _qualificationsController.text,
        'education': _educationController.text,
        'years_of_experience': int.tryParse(_experienceController.text) ?? 0,
        'languages_spoken': _selectedLanguages,
        'target_exams': _selectedExams,
        'specializations': _specializations,
        'proposed_price_cents': (double.tryParse(_priceController.text) ?? 20) * 100,
        'government_id_url': _governmentIdUrl,
        'certificate_url': _certificateUrl,
        'intro_video_url': _introVideoUrl,
        'status': 'draft',
      }, onConflict: 'user_id');
      await _supabase.from('tutors').upsert({
        'user_id': user.id,
        'bio': _bioController.text,
        'qualifications': _qualificationsController.text,
        'languages': _selectedLanguages,
        'exams': _selectedExams,
        'experience_years': int.tryParse(_experienceController.text) ?? 0,
        'price_per_hour_cents': (double.tryParse(_priceController.text) ?? 20) * 100,
      }, onConflict: 'user_id');
      await _supabase.from('user_profiles').update({'role': 'tutor'}).eq('auth_user_id', user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration saved! Submit for review when ready.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Tutor'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_currentStep + 1) / 6),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 5) setState(() => _currentStep++);
            else _submitRegistration();
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.base),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back')),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 5 ? 'Submit for Review' : 'Continue',
                      onPressed: details.onStepContinue,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Personal Info'),
              isActive: _currentStep >= 0,
              content: Column(children: [
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio', hintText: 'Tell students about yourself...', border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: (v) => v?.isEmpty ?? true ? 'Bio is required' : null,
                ),
                const SizedBox(height: AppSpacing.base),
                TextFormField(controller: _educationController, decoration: const InputDecoration(labelText: 'Education', hintText: 'e.g., MA in English Literature', border: OutlineInputBorder())),
              ]),
            ),
            Step(
              title: const Text('Qualifications'),
              isActive: _currentStep >= 1,
              content: Column(children: [
                TextFormField(
                  controller: _qualificationsController,
                  decoration: const InputDecoration(labelText: 'Teaching Certifications', hintText: 'e.g., TEFL, CELTA', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.base),
                TextFormField(controller: _experienceController, decoration: const InputDecoration(labelText: 'Years of Experience', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: AppSpacing.base),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  'English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Arabic', 'Hindi', 'Malayalam',
                ].map((lang) => FilterChip(
                  label: Text(lang),
                  selected: _selectedLanguages.contains(lang),
                  onSelected: (s) => setState(() => s ? _selectedLanguages.add(lang) : _selectedLanguages.remove(lang)),
                )).toList()),
                const SizedBox(height: AppSpacing.base),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  'IELTS', 'TOEFL', 'PTE', 'CELPIP', 'Cambridge', 'Duolingo',
                ].map((exam) => FilterChip(
                  label: Text(exam),
                  selected: _selectedExams.contains(exam),
                  onSelected: (s) => setState(() => s ? _selectedExams.add(exam) : _selectedExams.remove(exam)),
                )).toList()),
              ]),
            ),
            Step(
              title: const Text('Teaching Details'),
              isActive: _currentStep >= 2,
              content: Wrap(spacing: 8, runSpacing: 8, children: [
                'IELTS Preparation', 'TOEFL Prep', 'Business English', 'Conversational', 'Academic Writing', 'Pronunciation', 'Grammar', 'Vocabulary', 'Kids Teaching',
              ].map((spec) => FilterChip(
                label: Text(spec),
                selected: _specializations.contains(spec),
                onSelected: (s) => setState(() => s ? _specializations.add(spec) : _specializations.remove(spec)),
              )).toList()),
            ),
            Step(
              title: const Text('Documents'),
              isActive: _currentStep >= 3,
              content: Column(children: [
                _buildDocUpload('Government ID', _governmentIdUrl, (url) => setState(() => _governmentIdUrl = url)),
                _buildDocUpload('Teaching Certificate', _certificateUrl, (url) => setState(() => _certificateUrl = url)),
                _buildDocUpload('Intro Video (Optional)', _introVideoUrl, (url) => setState(() => _introVideoUrl = url)),
              ]),
            ),
            Step(
              title: const Text('Pricing'),
              isActive: _currentStep >= 4,
              content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Set your hourly rate (admin approval required)'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price per hour (USD)', prefixText: '\$ ', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final price = double.tryParse(v ?? '');
                    if (price == null || price < 5 || price > 100) return 'Price must be between \$5 and \$100';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text('Price changes require admin approval.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Step(
              title: const Text('Review'),
              isActive: _currentStep >= 5,
              content: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Review Your Application', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.base),
                    _reviewRow('Bio', _bioController.text),
                    _reviewRow('Qualifications', _qualificationsController.text),
                    _reviewRow('Education', _educationController.text),
                    _reviewRow('Experience', '${_experienceController.text} years'),
                    _reviewRow('Languages', _selectedLanguages.join(', ')),
                    _reviewRow('Exams', _selectedExams.join(', ')),
                    _reviewRow('Price', '\$${_priceController.text}/hr'),
                    _reviewRow('ID Uploaded', _governmentIdUrl != null ? 'Yes' : 'No'),
                    _reviewRow('Certificate', _certificateUrl != null ? 'Yes' : 'No'),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocUpload(String label, String? url, Function(String?) onUrlSet) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(url != null ? Icons.check_circle : Icons.upload_file, color: url != null ? Colors.green : Colors.grey),
        title: Text(label),
        subtitle: Text(url != null ? 'Uploaded' : 'Tap to upload'),
        trailing: url != null
            ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onUrlSet(null))
            : const Icon(Icons.chevron_right),
        onTap: () {
          // In production, use file_picker + Supabase Storage
          onUrlSet('https://storage.example.com/docs/${label.toLowerCase().replaceAll(' ', '_')}.pdf');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label uploaded (mock)')));
        },
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
        Expanded(child: Text(value.isEmpty ? 'Not provided' : value)),
      ]),
    );
  }
}
