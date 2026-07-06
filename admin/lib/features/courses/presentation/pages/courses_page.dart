import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  // Search & Pagination States
  String _searchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalCount = 0;
  bool _isLoading = true;

  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _searchQuery = '';
        _currentPage = 1;
        _totalCount = 0;
        _items = [];
      });
      _fetchData();
    });
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final isVocab = _tabController.index == 1;
    final table = isVocab ? 'vocabulary' : 'lessons';

    try {
      var query = supabase.from(table).select('*');

      if (_searchQuery.isNotEmpty) {
        if (isVocab) {
          query = query.ilike('word', '%$_searchQuery%');
        } else {
          query = query.ilike('title', '%$_searchQuery%');
        }
      }

      final start = (_currentPage - 1) * _pageSize;
      final end = start + _pageSize - 1;

      final res = await query
          .order(isVocab ? 'word' : 'created_at', ascending: isVocab)
          .range(start, end)
          .count(CountOption.exact);

      setState(() {
        _items = res.data ?? [];
        _totalCount = res.count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback seeds
      setState(() {
        if (isVocab) {
          _items = [
            {'id': 'v1', 'word': 'Fluent', 'meaning': 'Able to express oneself easily and articulately', 'pronunciation': '/ˈfluːənt/', 'cefr_level': 'B2'},
            {'id': 'v2', 'word': 'Coherent', 'meaning': 'Logical and consistent', 'pronunciation': '/kəʊˈhɪərənt/', 'cefr_level': 'C1'}
          ];
        } else {
          _items = [
            {'id': 'l1', 'title': 'Grammar Basics: Present Perfect', 'category': 'Grammar', 'difficulty': 'Intermediate', 'estimated_minutes': 20, 'xp_reward': 150},
            {'id': 'l2', 'title': 'Speaking Fluency: At the airport', 'category': 'Speaking', 'difficulty': 'Beginner', 'estimated_minutes': 15, 'xp_reward': 100}
          ];
        }
        _totalCount = _items.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Curriculum Item'),
        content: const Text('Are you sure you want to delete this item? This action is permanent.'),
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

    final isVocab = _tabController.index == 1;
    final table = isVocab ? 'vocabulary' : 'lessons';

    setState(() => _isLoading = true);
    try {
      await supabase.from(table).delete().eq('id', id);
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showFormDialog([Map<String, dynamic>? item]) {
    final isVocab = _tabController.index == 1;
    final formKey = GlobalKey<FormState>();

    // Controllers
    final nameTitleController = TextEditingController(text: item != null ? (isVocab ? item['word'] : item['title']) : '');
    final meaningDescController = TextEditingController(text: item != null ? (isVocab ? item['meaning'] : item['description']) : '');
    final pronunciationCategoryController = TextEditingController(text: item != null ? (isVocab ? item['pronunciation'] : item['category']) : 'Grammar');
    final cefrDifficultyController = TextEditingController(text: item != null ? (isVocab ? item['cefr_level'] : item['difficulty']) : 'Beginner');

    final xpMinutesController = TextEditingController(
      text: item != null ? (isVocab ? '' : '${item['estimated_minutes'] ?? 15}') : '15',
    );
    final xpRewardController = TextEditingController(
      text: item != null ? (isVocab ? '' : '${item['xp_reward'] ?? 100}') : '100',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item != null ? 'Edit Curriculum Item' : 'Add New Curriculum Item'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameTitleController,
                  decoration: InputDecoration(
                    labelText: isVocab ? 'Vocabulary Word' : 'Lesson Title',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Field cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: meaningDescController,
                  decoration: InputDecoration(
                    labelText: isVocab ? 'Meaning / Translation' : 'Description',
                  ),
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Field cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                if (isVocab) ...[
                  TextFormField(
                    controller: pronunciationCategoryController,
                    decoration: const InputDecoration(labelText: 'Pronunciation (IPA)'),
                    validator: (v) => v == null || v.isEmpty ? 'Field cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: cefrDifficultyController.text,
                    decoration: const InputDecoration(labelText: 'CEFR Level'),
                    items: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((l) {
                      return DropdownMenuItem(value: l, child: Text(l));
                    }).toList(),
                    onChanged: (val) => cefrDifficultyController.text = val ?? 'A1',
                  ),
                ] else ...[
                  DropdownButtonFormField<String>(
                    value: pronunciationCategoryController.text,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['Grammar', 'Vocabulary', 'Speaking', 'Listening', 'Reading', 'Writing'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) => pronunciationCategoryController.text = val ?? 'Grammar',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: cefrDifficultyController.text,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: ['Beginner', 'Elementary', 'Intermediate', 'Upper Intermediate', 'Advanced', 'Proficiency'].map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (val) => cefrDifficultyController.text = val ?? 'Beginner',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: xpMinutesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duration (min)'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: xpRewardController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'XP Reward'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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

              final table = isVocab ? 'vocabulary' : 'lessons';
              final Map<String, dynamic> data = isVocab
                  ? {
                      'word': nameTitleController.text.trim(),
                      'meaning': meaningDescController.text.trim(),
                      'pronunciation': pronunciationCategoryController.text.trim(),
                      'cefr_level': cefrDifficultyController.text,
                    }
                  : {
                      'title': nameTitleController.text.trim(),
                      'description': meaningDescController.text.trim(),
                      'category': pronunciationCategoryController.text,
                      'difficulty': cefrDifficultyController.text,
                      'estimated_minutes': int.tryParse(xpMinutesController.text) ?? 15,
                      'xp_reward': int.tryParse(xpRewardController.text) ?? 100,
                    };

              try {
                if (item != null) {
                  await supabase.from(table).update(data).eq('id', item['id']);
                } else {
                  await supabase.from(table).insert(data);
                }
                _fetchData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Save failed: $e')),
                );
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Item'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVocab = _tabController.index == 1;

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
                  'Course Curriculum',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Create, modify, and manage lessons, grammar blocks, and spacing vocab lists',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showFormDialog(),
              icon: const Icon(Icons.add_rounded),
              label: Text(isVocab ? 'Add Word' : 'Create Lesson'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TabBar(
          controller: _tabController,
          labelColor: AdminTheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          indicatorColor: AdminTheme.primary,
          tabs: const [
            Tab(text: 'Lessons Curriculum', icon: Icon(Icons.menu_book_rounded)),
            Tab(text: 'Vocabulary Dictionary', icon: Icon(Icons.translate_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _fetchData();
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: isVocab ? 'Search vocabulary words...' : 'Search lesson title...',
                      filled: true,
                    ),
                  ),
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
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: isVocab
                                  ? const [
                                      DataColumn(label: Text('Word')),
                                      DataColumn(label: Text('Meaning')),
                                      DataColumn(label: Text('Pronunciation')),
                                      DataColumn(label: Text('CEFR Level')),
                                      DataColumn(label: Text('Actions')),
                                    ]
                                  : const [
                                      DataColumn(label: Text('Title')),
                                      DataColumn(label: Text('Category')),
                                      DataColumn(label: Text('Difficulty')),
                                      DataColumn(label: Text('Minutes')),
                                      DataColumn(label: Text('XP Reward')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                              rows: _items.map((item) {
                                return DataRow(
                                  cells: isVocab
                                      ? [
                                          DataCell(Text(item['word'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                          DataCell(Text(item['meaning'] ?? '')),
                                          DataCell(Text(item['pronunciation'] ?? '')),
                                          DataCell(
                                            Chip(
                                              label: Text(item['cefr_level'] ?? 'A1', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                              backgroundColor: AdminTheme.secondary.withOpacity(0.08),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                                  onPressed: () => _showFormDialog(item),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                                  onPressed: () => _handleDelete(item['id']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                      : [
                                          DataCell(Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                          DataCell(Text(item['category'] ?? '')),
                                          DataCell(Text(item['difficulty'] ?? '')),
                                          DataCell(Text('${item['estimated_minutes']} min')),
                                          DataCell(Text('${item['xp_reward']} XP')),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                                  onPressed: () => _showFormDialog(item),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                                  onPressed: () => _handleDelete(item['id']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${((_currentPage - 1) * _pageSize) + 1} to ${((_currentPage - 1) * _pageSize) + _items.length} of $_totalCount items',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() => _currentPage--);
                                          _fetchData();
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  onPressed: (_currentPage * _pageSize) < _totalCount
                                      ? () {
                                          setState(() => _currentPage++);
                                          _fetchData();
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
