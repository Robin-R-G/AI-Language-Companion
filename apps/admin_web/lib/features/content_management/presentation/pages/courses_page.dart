import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/data_table_widget.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _filteredCourses = [];

  int _totalCourses = 0;
  int _publishedCount = 0;
  int _draftCount = 0;
  int _totalLessons = 0;

  String _selectedCefrFilter = 'All';
  String _selectedLanguageFilter = 'All';
  String _selectedStatusFilter = 'All';

  final _cefrLevels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final _statusOptions = ['All', 'published', 'draft', 'archived'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
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
      final coursesRes = await _supabase
          .from('courses')
          .select('*')
          .order('created_at', ascending: false);

      final lessonsRes = await _supabase.from('lessons').select('id, course_id');

      final courses = List<Map<String, dynamic>>.from(coursesRes);
      final lessons = List<Map<String, dynamic>>.from(lessonsRes);

      if (mounted) {
        setState(() {
          _courses = courses;
          _totalCourses = courses.length;
          _publishedCount = courses.where((c) => c['status'] == 'published').length;
          _draftCount = courses.where((c) => c['status'] == 'draft').length;
          _totalLessons = lessons.length;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load courses: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _courses.where((course) {
        final matchesSearch = query.isEmpty ||
            (course['title'] ?? '').toString().toLowerCase().contains(query) ||
            (course['description'] ?? '').toString().toLowerCase().contains(query);
        final matchesCefr = _selectedCefrFilter == 'All' ||
            course['cefr_level'] == _selectedCefrFilter;
        final matchesLanguage = _selectedLanguageFilter == 'All' ||
            course['language'] == _selectedLanguageFilter;
        final matchesStatus = _selectedStatusFilter == 'All' ||
            course['status'] == _selectedStatusFilter;
        return matchesSearch && matchesCefr && matchesLanguage && matchesStatus;
      }).toList();
    });
  }

  List<String> get _availableLanguages {
    final langs = _courses
        .map((c) => (c['language'] ?? '').toString())
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList();
    return ['All', ...langs];
  }

  Future<void> _showCourseDialog({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final descController = TextEditingController(text: existing?['description'] ?? '');
    String cefrLevel = existing?['cefr_level'] ?? 'A1';
    String language = existing?['language'] ?? 'English';
    String status = existing?['status'] ?? 'draft';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Course' : 'New Course'),
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
                      decoration: const InputDecoration(labelText: 'Course Title'),
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
                    DropdownButtonFormField<String>(
                      value: cefrLevel,
                      decoration: const InputDecoration(labelText: 'CEFR Level'),
                      items: _cefrLevels
                          .where((l) => l != 'All')
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => cefrLevel = v ?? cefrLevel),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: language,
                      decoration: const InputDecoration(labelText: 'Language'),
                      items: ['English', 'Spanish', 'French', 'German', 'Japanese', 'Chinese']
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => language = v ?? language),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: ['draft', 'published', 'archived']
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s[0].toUpperCase() + s.substring(1))))
                          .toList(),
                      onChanged: (v) => setDialogState(() => status = v ?? status),
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
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Create Course'),
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
          'cefr_level': cefrLevel,
          'language': language,
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (isEdit) {
          await _supabase.from('courses').update(data).eq('id', existing['id']);
        } else {
          data['created_at'] = DateTime.now().toIso8601String();
          await _supabase.from('courses').insert(data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? 'Course updated' : 'Course created'),
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

  Future<void> _deleteCourse(Map<String, dynamic> course) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Course',
      content: 'Are you sure you want to delete "${course['title']}"? This will also remove all associated lessons.',
      confirmLabel: 'Delete',
      confirmColor: AdminTheme.error,
    );

    if (confirmed) {
      try {
        await _supabase.from('courses').delete().eq('id', course['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course deleted'),
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

  BadgeType _statusBadgeType(String? status) {
    switch (status) {
      case 'published':
        return BadgeType.success;
      case 'draft':
        return BadgeType.warning;
      case 'archived':
        return BadgeType.neutral;
      default:
        return BadgeType.info;
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
            title: 'Courses',
            subtitle: 'Manage learning content and courses',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showCourseDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Course'),
              ),
            ],
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
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
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
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
                    _buildFilters(),
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
        final crossCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Total Courses',
              value: '$_totalCourses',
              subtitle: 'All courses',
              icon: Icons.menu_book_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Published',
              value: '$_publishedCount',
              subtitle: 'Live courses',
              icon: Icons.check_circle_outline_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Drafts',
              value: '$_draftCount',
              subtitle: 'In progress',
              icon: Icons.edit_note_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Total Lessons',
              value: '$_totalLessons',
              subtitle: 'Across all courses',
              icon: Icons.article_outlined,
              color: AdminTheme.secondary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SearchField(
                hintText: 'Search courses...',
                controller: _searchController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCefrFilter,
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _cefrLevels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedCefrFilter = v ?? 'All');
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLanguageFilter,
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _availableLanguages
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedLanguageFilter = v ?? 'All');
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatusFilter,
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s == 'All'
                              ? 'All Status'
                              : s[0].toUpperCase() + s.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedStatusFilter = v ?? 'All');
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return AdminDataTable(
      columns: ['Title', 'Language', 'CEFR', 'Status', 'Lessons', 'Actions'],
      rows: _filteredCourses.map((course) {
        return [
          Text(course['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(course['language'] ?? '-'),
          StatusBadge(label: course['cefr_level'] ?? '-', type: BadgeType.info),
          StatusBadge(
            label: (course['status'] ?? 'draft'),
            type: _statusBadgeType(course['status']),
          ),
          Text('${course['lesson_count'] ?? 0}'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit',
                onPressed: () => _showCourseDialog(existing: course),
              ),
              IconButton(
                icon: const Icon(Icons.school_outlined, size: 18),
                tooltip: 'Manage Lessons',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lesson builder for "${course['title']}"'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: 'Delete',
                onPressed: () => _deleteCourse(course),
              ),
            ],
          ),
        ];
      }).toList(),
      emptyState: const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 64, color: AdminTheme.primaryLight),
              SizedBox(height: 16),
              Text('No courses found', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
