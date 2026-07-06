import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';

class TutorMarketplacePage extends StatefulWidget {
  const TutorMarketplacePage({super.key});

  @override
  State<TutorMarketplacePage> createState() => _TutorMarketplacePageState();
}

class _TutorMarketplacePageState extends State<TutorMarketplacePage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _tutors = [];
  String _searchQuery = '';
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _fetchTutors();
  }

  Future<void> _fetchTutors() async {
    setState(() => _isLoading = true);
    try {
      final res = await _supabase
          .from('tutors')
          .select('*, user_profiles(full_name, email, avatar_url)')
          .eq('is_verified', true);

      setState(() {
        _tutors = res ?? [];
        _isLoading = false;
      });
    } catch (e) {
      // Mock Fallback
      setState(() {
        _tutors = [
          {
            'id': 'tutor_oxford',
            'user_profiles': {
              'full_name': 'Prof. Sarah Jenkins',
              'email': 'sarah@ieltsacademy.org',
              'avatar_url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100'
            },
            'bio': 'TEFL certified linguist and former IELTS examiner. Specializing in advanced conversational fluency, academic writing corrections, and speech accent training.',
            'qualifications': 'MA in Applied Linguistics (Oxford), Cambridge DELTA.',
            'price_per_hour_cents': 2500,
            'rating': 4.95,
            'review_count': 38,
            'experience_years': 8,
            'languages': ['English', 'Spanish'],
            'exams': ['IELTS', 'TOEFL'],
          },
          {
            'id': 'tutor_cambridge',
            'user_profiles': {
              'full_name': 'David Vance',
              'email': 'david@eslboost.com',
              'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'
            },
            'bio': 'Fun and interactive conversational coach. Focused on CEFR levels A2-B2, vocabulary build-ups, and native pronunciation confidence.',
            'qualifications': 'BA in Communications, TESOL Certified.',
            'price_per_hour_cents': 1800,
            'rating': 4.82,
            'review_count': 24,
            'experience_years': 5,
            'languages': ['English', 'French'],
            'exams': ['PTE', 'CELPIP'],
          }
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredTutors = _tutors.where((tutor) {
      final profile = tutor['user_profiles'] ?? {};
      final name = (profile['full_name'] as String? ?? '').toLowerCase();
      final bio = (tutor['bio'] as String? ?? '').toLowerCase();
      final matchQuery = name.contains(_searchQuery.toLowerCase()) || bio.contains(_searchQuery.toLowerCase());
      
      if (_selectedLanguage == null) return matchQuery;
      final languages = (tutor['languages'] as List<dynamic>?)?.map((l) => l.toString().toLowerCase()).toList() ?? [];
      return matchQuery && languages.contains(_selectedLanguage!.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tutor Marketplace')),
      body: Column(
        children: [
          // Filter Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tutors or qualifications...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppBorderRadius.base)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  hint: const Text('Language'),
                  underline: const SizedBox(),
                  items: ['English', 'Spanish', 'French', 'Malayalam']
                      .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedLanguage = val),
                ),
                if (_selectedLanguage != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _selectedLanguage = null),
                  )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              itemCount: filteredTutors.length,
              itemBuilder: (context, index) {
                final tutor = filteredTutors[index];
                return _buildTutorCard(theme, tutor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(ThemeData theme, dynamic tutor) {
    final profile = tutor['user_profiles'] ?? {};
    final name = profile['full_name'] ?? 'Tutor';
    final avatar = profile['avatar_url'] ?? '';
    final rate = tutor['price_per_hour_cents'] / 100;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(tutor['qualifications'] ?? 'ESL Certified Instructor', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${rate.toStringAsFixed(2)}/hr', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(tutor['rating'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(' (${tutor['review_count']})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                )
              ],
            ),
            const Divider(height: 24),
            Text(tutor['bio'] ?? 'Hello!', maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.language, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Speaks: ${(tutor['languages'] as List<dynamic>?)?.join(', ') ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                AppButton(
                  text: 'Book Consultation',
                  onPressed: () => _showBookingDialog(tutor),
                  isCompact: true,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(dynamic tutor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Book Session with ${tutor['user_profiles']['full_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Date & Time (Mock Booking)'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Tomorrow, 4:00 PM - 5:00 PM'),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.payments),
                title: Text('Price: \$${(tutor['price_per_hour_cents'] / 100).toStringAsFixed(2)}'),
                subtitle: const Text('Equivalent to 150 AI Credits'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startLiveClassroom(tutor);
              },
              child: const Text('Confirm & Pay'),
            ),
          ],
        );
      },
    );
  }

  void _startLiveClassroom(dynamic tutor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LiveClassroomScreen(tutor: tutor)),
    );
  }
}

// LIVE CLASSROOM SCREEN WITH INTERACTIVE WHITEBOARD
class LiveClassroomScreen extends StatefulWidget {
  final dynamic tutor;
  const LiveClassroomScreen({super.key, required this.tutor});

  @override
  State<LiveClassroomScreen> createState() => _LiveClassroomScreenState();
}

class _LiveClassroomScreenState extends State<LiveClassroomScreen> {
  final List<Offset?> _points = [];
  bool _audioMuted = false;
  bool _videoMuted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.tutor['user_profiles']['full_name'] ?? 'Tutor';

    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom: $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _points.clear()),
            tooltip: 'Clear Whiteboard',
          )
        ],
      ),
      body: Column(
        children: [
          // Whiteboard Area
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Interactive Whiteboard (Draw to practice)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject() as RenderBox;
                        _points.add(renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _points.add(null);
                      });
                    },
                    child: CustomPaint(
                      painter: WhiteboardPainter(points: _points),
                      size: Size.infinite,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Video Feed Mock + Media Controls
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(AppBorderRadius.base),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: _videoMuted
                                ? const Text('Video Paused', style: TextStyle(color: Colors.white70))
                                : Icon(Icons.person, color: theme.colorScheme.primary, size: 48),
                          ),
                          const Positioned(bottom: 8, left: 8, child: Text('Student (You)', style: TextStyle(color: Colors.white, fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(AppBorderRadius.base),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(Icons.person, color: theme.colorScheme.secondary, size: 48),
                          ),
                          Positioned(bottom: 8, left: 8, child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () => setState(() => _audioMuted = !_audioMuted),
                  icon: Icon(_audioMuted ? Icons.mic_off : Icons.mic),
                  backgroundColor: _audioMuted ? Colors.red : theme.colorScheme.primary,
                ),
                const SizedBox(width: 24),
                IconButton.filled(
                  onPressed: () => setState(() => _videoMuted = !_videoMuted),
                  icon: Icon(_videoMuted ? Icons.videocam_off : Icons.videocam),
                  backgroundColor: _videoMuted ? Colors.red : theme.colorScheme.primary,
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.call_end),
                  label: const Text('End Class'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class WhiteboardPainter extends CustomPainter {
  final List<Offset?> points;
  WhiteboardPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Adjust coordinates relative to canvas drawing boundary
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WhiteboardPainter oldDelegate) => true;
}
