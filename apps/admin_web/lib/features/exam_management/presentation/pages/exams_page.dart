import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/data_table_widget.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> _filteredExams = [];

  int _totalExams = 0;
  int _activeCount = 0;
  double _avgScore = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final examsRes = await _supabase
          .from('exams')
          .select('*')
          .order('created_at', ascending: false);

      final attemptsRes = await _supabase.from('exam_attempts').select('score, estimated_score');

      final exams = List<Map<String, dynamic>>.from(examsRes);
      final attempts = List<Map<String, dynamic>>.from(attemptsRes);

      double avgScore = 0;
      if (attempts.isNotEmpty) {
        final totalScore = attempts.fold<double>(
          0,
          (sum, a) {
            final s = a['score'] ?? a['estimated_score'] ?? 0;
            return sum + (s as num).toDouble();
          },
        );
        avgScore = totalScore / attempts.length;
      }

      if (mounted) {
        setState(() {
          _exams = exams;
          _totalExams = exams.length;
          _activeCount = exams.where((e) => e['is_active'] == true).length;
          _avgScore = avgScore;
          _applySearch();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load exams: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExams = _exams.where((exam) {
        return query.isEmpty ||
            (exam['title'] ?? '').toString().toLowerCase().contains(query) ||
            (exam['description'] ?? '').toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _showExamDialog({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final descController = TextEditingController(text: existing?['description'] ?? '');
    final durationController = TextEditingController(
      text: existing?['duration_minutes']?.toString() ?? '60',
    );
    final passingScoreController = TextEditingController(
      text: existing?['passing_score']?.toString() ?? '60',
    );
    bool isActive = existing?['is_active'] ?? false;
    bool isMock = existing?['is_mock'] ?? false;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Exam' : 'Create Exam'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Exam Title'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passingScoreController,
                      decoration: const InputDecoration(labelText: 'Passing Score (%)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mock Exam'),
                      subtitle: const Text('Allow unlimited retakes'),
                      value: isMock,
                      onChanged: (v) => setDialogState(() => isMock = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: Text(isEdit ? 'Save Changes' : 'Create Exam'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final data = {
          'title': titleController.text.trim(),
          'description': descController.text.trim(),
          'duration_minutes': int.tryParse(durationController.text) ?? 60,
          'passing_score': int.tryParse(passingScoreController.text) ?? 60,
          'is_active': isActive,
          'is_mock': isMock,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (isEdit) {
          await _supabase.from('exams').update(data).eq('id', existing['id']);
        } else {
          data['created_at'] = DateTime.now().toIso8601String();
          await _supabase.from('exams').insert(data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? 'Exam updated' : 'Exam created'),
              backgroundColor: AdminTheme.success,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  Future<void> _deleteExam(Map<String, dynamic> exam) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Exam',
      content: 'Delete "${exam['title']}"? All attempts will be removed.',
      confirmLabel: 'Delete',
      confirmColor: AdminTheme.error,
    );

    if (confirmed) {
      try {
        await _supabase.from('exams').delete().eq('id', exam['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam deleted'), backgroundColor: AdminTheme.success),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  void _showCertificateSettings(Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Certificate: ${exam['title']}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Certificate'),
                value: exam['certificate_enabled'] ?? false,
                onChanged: (v) async {
                  await _supabase
                      .from('exams')
                      .update({'certificate_enabled': v}).eq('id', exam['id']);
                  Navigator.pop(ctx);
                  _loadData();
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image_outlined),
                title: const Text('Certificate Template'),
                subtitle: const Text('Default template'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_outlined),
                title: const Text('Passing Score for Certificate'),
                subtitle: Text('${exam['passing_score'] ?? 60}%'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Exams',
            subtitle: 'Manage exams, question banks, and certifications',
            actions: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question bank management')),
                  );
                },
                icon: const Icon(Icons.question_answer_outlined, size: 18),
                label: const Text('Question Bank'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showExamDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Exam'),
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
                    ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
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
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildSearch(),
                    const SizedBox(height: 16),
                    _buildTable(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 800 ? 3 : 1;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Total Exams',
              value: '$_totalExams',
              subtitle: 'All exams',
              icon: Icons.quiz_outlined,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Active',
              value: '$_activeCount',
              subtitle: 'Currently live',
              icon: Icons.check_circle_outline,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Avg Score',
              value: '${_avgScore.toStringAsFixed(1)}%',
              subtitle: 'Across all attempts',
              icon: Icons.analytics_outlined,
              color: AdminTheme.info,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SearchField(
          hintText: 'Search exams...',
          controller: _searchController,
        ),
      ),
    );
  }

  Widget _buildTable() {
    return AdminDataTable(
      columns: ['Title', 'Duration', 'Pass Score', 'Status', 'Mock', 'Actions'],
      rows: _filteredExams.map((exam) {
        return [
          Text(exam['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text('${exam['duration_minutes'] ?? 60} min'),
          Text('${exam['passing_score'] ?? 60}%'),
          StatusBadge(
            label: (exam['is_active'] ?? false) ? 'Active' : 'Inactive',
            type: (exam['is_active'] ?? false) ? BadgeType.success : BadgeType.neutral,
          ),
          StatusBadge(
            label: (exam['is_mock'] ?? false) ? 'Yes' : 'No',
            type: (exam['is_mock'] ?? false) ? BadgeType.info : BadgeType.neutral,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit',
                onPressed: () => _showExamDialog(existing: exam),
              ),
              IconButton(
                icon: const Icon(Icons.verified_outlined, size: 18),
                tooltip: 'Certificate Settings',
                onPressed: () => _showCertificateSettings(exam),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart_outlined, size: 18),
                tooltip: 'View Attempts',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Attempts for "${exam['title']}"')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: 'Delete',
                onPressed: () => _deleteExam(exam),
              ),
            ],
          ),
        ];
      }).toList(),
    );
  }
}
