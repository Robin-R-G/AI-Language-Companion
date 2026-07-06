import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/status_badge.dart';

class TutorDetailDialog extends StatefulWidget {
  final Map<String, dynamic> tutor;

  const TutorDetailDialog({super.key, required this.tutor});

  @override
  State<TutorDetailDialog> createState() => _TutorDetailDialogState();
}

class _TutorDetailDialogState extends State<TutorDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _sessions = [];
  Map<String, dynamic>? _earnings;
  Map<String, dynamic>? _availability;
  Map<String, dynamic>? _tutorProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadTutorDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadTutorDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tutorId = widget.tutor['id'];

      final results = await Future.wait([
        _supabase
            .from('tutor_profiles')
            .select()
            .eq('user_id', tutorId)
            .maybeSingle(),
        _supabase
            .from('tutor_reviews')
            .select('*, user_profiles(full_name)')
            .eq('tutor_id', tutorId)
            .order('created_at', ascending: false)
            .limit(50),
        _supabase
            .from('tutor_sessions')
            .select('*, user_profiles(full_name)')
            .eq('tutor_id', tutorId)
            .order('scheduled_at', ascending: false)
            .limit(50),
        _supabase
            .from('tutor_earnings')
            .select()
            .eq('tutor_id', tutorId)
            .maybeSingle(),
        _supabase
            .from('tutor_availability')
            .select()
            .eq('tutor_id', tutorId)
            .order('day_of_week'),
      ]);

      setState(() {
        _tutorProfile = results[0] as Map<String, dynamic>?;
        _reviews = List<Map<String, dynamic>>.from(results[1] as List);
        _sessions = List<Map<String, dynamic>>.from(results[2] as List);
        _earnings = results[3] as Map<String, dynamic>?;
        _availability = results[4] is List
            ? (results[4] as List).isNotEmpty
                ? (results[4] as List)[0] as Map<String, dynamic>
                : null
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load details: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final val = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(symbol: '\$').format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width > 800
            ? 720
            : MediaQuery.of(context).size.width * 0.95,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final fullName = widget.tutor['full_name'] ?? 'Unknown Tutor';
    final email = widget.tutor['email'] ?? '';
    final isSuspended = widget.tutor['is_suspended'] == true;
    final verificationStatus =
        widget.tutor['verification_status'] ?? 'pending';
    final avatarLetter =
        fullName.toString().isNotEmpty ? fullName.toString()[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AdminTheme.primary.withOpacity(0.1),
            child: Text(
              avatarLetter,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AdminTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  email.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(
                      label: verificationStatus.toString().toUpperCase(),
                      type: verificationStatus == 'verified'
                          ? BadgeType.success
                          : verificationStatus == 'pending'
                              ? BadgeType.warning
                              : BadgeType.error,
                    ),
                    const SizedBox(width: 8),
                    if (isSuspended)
                      const StatusBadge(
                        label: 'SUSPENDED',
                        type: BadgeType.error,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AdminTheme.error),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminTheme.error)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTutorDetails,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Documents'),
            Tab(text: 'Reviews'),
            Tab(text: 'Sessions'),
            Tab(text: 'Availability'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildDocumentsTab(),
              _buildReviewsTab(),
              _buildSessionsTab(),
              _buildAvailabilityTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final profile = _tutorProfile;
    final rating = profile?['average_rating'] ?? 0.0;
    final totalReviews = _reviews.length;
    final totalSessions = _sessions.length;
    final totalEarnings = _earnings?['total_earnings'] ?? 0;
    final pendingPayout = _earnings?['pending_payout'] ?? 0;
    final languages = profile?['languages'] ?? [];
    final specializations = profile?['specializations'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Performance Metrics'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2,
                children: [
                  _buildMetricCard(
                      'Rating', '$rating', Icons.star_rounded, AdminTheme.warning),
                  _buildMetricCard(
                      'Reviews', '$totalReviews', Icons.reviews_rounded, AdminTheme.info),
                  _buildMetricCard('Sessions', '$totalSessions',
                      Icons.event_available_rounded, AdminTheme.primary),
                  _buildMetricCard(
                      'Earnings', _formatCurrency(totalEarnings),
                      Icons.account_balance_wallet_rounded, AdminTheme.success),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          if (pendingPayout != null &&
              (double.tryParse(pendingPayout.toString()) ?? 0) > 0) ...[
            _buildSectionTitle('Pending Payout'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdminTheme.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded,
                      color: AdminTheme.warning, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _formatCurrency(pendingPayout),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.warning,
                    ),
                  ),
                  const Spacer(),
                  const Text('Awaiting payout',
                      style: TextStyle(color: AdminTheme.warning, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildSectionTitle('Languages'),
          const SizedBox(height: 8),
          if (languages.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (languages as List).map<Widget>((lang) {
                return Chip(
                  label: Text(lang.toString(), style: const TextStyle(fontSize: 12)),
                  backgroundColor: AdminTheme.primary.withOpacity(0.08),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            )
          else
            Text('No languages specified',
                style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          _buildSectionTitle('Specializations'),
          const SizedBox(height: 8),
          if (specializations.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (specializations as List).map<Widget>((spec) {
                return Chip(
                  label:
                      Text(spec.toString(), style: const TextStyle(fontSize: 12)),
                  backgroundColor: AdminTheme.secondary.withOpacity(0.08),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            )
          else
            Text('No specializations specified',
                style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          _buildSectionTitle('Profile Details'),
          const SizedBox(height: 12),
          _buildInfoRow('Bio',
              widget.tutor['bio'] ?? _tutorProfile?['bio'] ?? 'No bio provided'),
          _buildInfoRow('Hourly Rate',
              _formatCurrency(_tutorProfile?['hourly_rate'] ?? 0)),
          _buildInfoRow(
              'Experience', '${_tutorProfile?['years_of_experience'] ?? 0} years'),
          _buildInfoRow('Timezone', _tutorProfile?['timezone'] ?? 'UTC'),
          _buildInfoRow(
              'Joined', _formatDate(widget.tutor['created_at'])),
          _buildInfoRow('Profile Updated',
              _formatDate(_tutorProfile?['updated_at'])),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    final documents = widget.tutor['documents'] ?? _tutorProfile?['documents'];
    final documentList =
        documents is List ? List<Map<String, dynamic>>.from(documents) : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Submitted Documents'),
          const SizedBox(height: 16),
          if (documentList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_off_rounded,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text('No documents submitted',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            )
          else
            ...documentList.map((doc) {
              final status = doc['status'] ?? 'pending';
              final name = doc['name'] ?? doc['type'] ?? 'Document';
              final uploadedAt = doc['uploaded_at'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AdminTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description_rounded,
                            color: AdminTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              'Uploaded ${_formatDate(uploadedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: status.toString().toUpperCase(),
                        type: status == 'approved'
                            ? BadgeType.success
                            : status == 'rejected'
                                ? BadgeType.error
                                : BadgeType.warning,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Reviews (${_reviews.length})'),
              if (_reviews.isNotEmpty)
                _buildAverageRatingChip(),
            ],
          ),
          const SizedBox(height: 16),
          if (_reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.reviews_rounded,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text('No reviews yet',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            )
          else
            ..._reviews.map((review) {
              final reviewer =
                  review['user_profiles']?['full_name'] ?? 'Anonymous';
              final rating = review['rating'] ?? 0;
              final comment = review['comment'] ?? '';
              final createdAt = review['created_at'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                AdminTheme.primary.withOpacity(0.1),
                            child: Text(
                              reviewer.toString().isNotEmpty
                                  ? reviewer.toString()[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AdminTheme.primary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reviewer.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text(_formatDate(createdAt),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          _buildStarRow(rating),
                        ],
                      ),
                      if (comment.toString().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(comment.toString(),
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Recent Sessions (${_sessions.length})'),
          const SizedBox(height: 16),
          if (_sessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_rounded,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text('No sessions recorded',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            )
          else
            ..._sessions.map((session) {
              final student =
                  session['user_profiles']?['full_name'] ?? 'Unknown';
              final scheduledAt = session['scheduled_at'];
              final status = session['status'] ?? 'completed';
              final duration = session['duration_minutes'] ?? 0;
              final amount = session['amount'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (status == 'completed'
                              ? AdminTheme.success
                              : AdminTheme.warning)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      status == 'completed'
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      color: status == 'completed'
                          ? AdminTheme.success
                          : AdminTheme.warning,
                      size: 18,
                    ),
                  ),
                  title: Text('Student: $student',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${_formatDate(scheduledAt)} · ${duration}min · ${_formatCurrency(amount)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: StatusBadge(
                    label: status.toString().toUpperCase(),
                    type: status == 'completed'
                        ? BadgeType.success
                        : status == 'cancelled'
                            ? BadgeType.error
                            : BadgeType.warning,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAvailabilityTab() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Weekly Availability'),
          const SizedBox(height: 16),
          ...days.map((day) {
            final dayLower = day.toLowerCase();
            final slots = _availability?[dayLower] ?? _availability?['$dayLower'];
            final hasSlots = slots != null &&
                slots is List &&
                slots.isNotEmpty;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  hasSlots
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color:
                      hasSlots ? AdminTheme.success : AdminTheme.error,
                  size: 20,
                ),
                title: Text(day,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: hasSlots
                    ? Text(
                        slots is List
                            ? slots.map((s) => s.toString()).join(', ')
                            : slots.toString(),
                        style: const TextStyle(fontSize: 12),
                      )
                    : Text('Not available',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.5))),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 14,
          color: AdminTheme.warning,
        );
      }),
    );
  }

  Widget _buildAverageRatingChip() {
    final avgRating = _reviews.fold<double>(
        0,
        (sum, r) =>
            sum + (double.tryParse(r['rating'].toString()) ?? 0));
    final avg = _reviews.isNotEmpty ? avgRating / _reviews.length : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AdminTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AdminTheme.warning),
          const SizedBox(width: 4),
          Text(
            avg.toStringAsFixed(1),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AdminTheme.warning),
          ),
        ],
      ),
    );
  }
}
