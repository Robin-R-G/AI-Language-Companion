import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _exams = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedExamType = 'All';

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() => _isLoading = true);
    try {
      var query = supabase.from('exams').select('*');

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$_searchQuery%');
      }
      if (_selectedExamType != 'All') {
        query = query.eq('exam_type', _selectedExamType);
      }

      final res = await query.order('created_at', ascending: false);
      setState(() {
        _exams = res ?? [];
        _isLoading = false;
      });
    } catch (e) {
      // Fallback local mock exams
      setState(() {
        _exams = [
          {
            'id': 'e1',
            'name': 'IELTS Academic',
            'code': 'IELTS_A',
            'description': 'International English Language Testing System - Academic',
            'exam_type': 'IELTS',
            'duration_minutes': 165,
            'max_score': 9,
            'passing_score': 6,
            'sections': [
              {'name': 'Listening', 'duration_minutes': 30, 'max_score': 9},
              {'name': 'Reading', 'duration_minutes': 60, 'max_score': 9},
              {'name': 'Writing', 'duration_minutes': 60, 'max_score': 9},
              {'name': 'Speaking', 'duration_minutes': 15, 'max_score': 9}
            ],
            'is_active': true,
          },
          {
            'id': 'e2',
            'name': 'TOEFL iBT',
            'code': 'TOEFL',
            'description': 'Test of English as a Foreign Language',
            'exam_type': 'TOEFL',
            'duration_minutes': 180,
            'max_score': 120,
            'passing_score': 80,
            'sections': [
              {'name': 'Reading', 'duration_minutes': 54, 'max_score': 30},
              {'name': 'Listening', 'duration_minutes': 41, 'max_score': 30},
              {'name': 'Speaking', 'duration_minutes': 17, 'max_score': 30},
              {'name': 'Writing', 'duration_minutes': 50, 'max_score': 30}
            ],
            'is_active': true,
          }
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exam Configuration'),
        content: const Text('Are you sure you want to delete this exam model? System references will be detached.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await supabase.from('exams').delete().eq('id', id);
      _fetchExams();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete exam: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showFormDialog([Map<String, dynamic>? exam]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: exam != null ? exam['name'] : '');
    final codeController = TextEditingController(text: exam != null ? exam['code'] : '');
    final descController = TextEditingController(text: exam != null ? exam['description'] : '');
    final durationController = TextEditingController(text: exam != null ? '${exam['duration_minutes']}' : '120');
    final maxScoreController = TextEditingController(text: exam != null ? '${exam['max_score']}' : '100');
    final passingScoreController = TextEditingController(text: exam != null ? '${exam['passing_score']}' : '50');

    String typeValue = exam != null ? exam['exam_type'] : 'IELTS';
    final sectionsController = TextEditingController(
      text: exam != null ? jsonEncode(exam['sections']) : '[]',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exam != null ? 'Edit Exam Configuration' : 'Add New Exam Configuration'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Exam Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Unique Code (e.g. IELTS_A)'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: typeValue,
                    decoration: const InputDecoration(labelText: 'Exam Type'),
                    items: ['IELTS', 'TOEFL', 'PTE', 'OET', 'Duolingo'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) => typeValue = val ?? 'IELTS',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: durationController,
                          decoration: const InputDecoration(labelText: 'Duration (min)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: maxScoreController,
                          decoration: const InputDecoration(labelText: 'Max Score'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: passingScoreController,
                          decoration: const InputDecoration(labelText: 'Passing Score'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: sectionsController,
                    decoration: const InputDecoration(
                      labelText: 'Exam Sections (JSON Array Format)',
                      hintText: '[{"name": "Listening", "duration_minutes": 30}]',
                    ),
                    maxLines: 4,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      try {
                        final parsed = jsonDecode(v);
                        if (parsed is! List) return 'Must be a JSON array';
                      } catch (e) {
                        return 'Invalid JSON format';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              final Map<String, dynamic> data = {
                'name': nameController.text.trim(),
                'code': codeController.text.trim(),
                'description': descController.text.trim(),
                'exam_type': typeValue,
                'duration_minutes': int.tryParse(durationController.text) ?? 120,
                'max_score': int.tryParse(maxScoreController.text) ?? 100,
                'passing_score': int.tryParse(passingScoreController.text) ?? 50,
                'sections': jsonDecode(sectionsController.text),
              };

              try {
                if (exam != null) {
                  await supabase.from('exams').update(data).eq('id', exam['id']);
                } else {
                  await supabase.from('exams').insert(data);
                }
                _fetchExams();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save exam model: $e')),
                );
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Model'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Configurations',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Define mock exams configurations, weight structures, and sections timings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showFormDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Exam'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _fetchExams();
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search exams by name...',
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedExamType,
                  items: ['All', 'IELTS', 'TOEFL', 'PTE', 'OET', 'Duolingo'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedExamType = val ?? 'All');
                    _fetchExams();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _exams.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final exam = _exams[index];
                      final sectionsList = exam['sections'] as List<dynamic>? ?? [];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        title: Row(
                          children: [
                            Text(
                              exam['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 12),
                            Chip(
                              label: Text(
                                exam['exam_type'] ?? 'IELTS',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AdminTheme.primary.withOpacity(0.08),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exam['description'] ?? 'No description provided.'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 16,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text('${exam['duration_minutes']} min', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_outline_rounded, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text('Max Score: ${exam['max_score']}', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text('Pass Score: ${exam['passing_score']}', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sections: ${sectionsList.map((s) => s['name']).join(', ')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                              onPressed: () => _showFormDialog(exam),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Colors.red),
                              onPressed: () => _handleDelete(exam['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
