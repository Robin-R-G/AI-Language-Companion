import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/admin_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/data_table_widget.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> _filteredListings = [];
  List<Map<String, dynamic>> _categories = [];

  int _totalListings = 0;
  int _activeListings = 0;
  int _pendingReview = 0;
  int _totalBookings = 0;
  double _totalCommission = 0;

  final _statusFilters = ['All', 'active', 'pending', 'rejected', 'featured'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketplace();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadMarketplace() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _supabase
            .from('marketplace_listings')
            .select('*, user_profiles(full_name, email)')
            .order('created_at', ascending: false),
        _supabase
            .from('marketplace_categories')
            .select()
            .order('name'),
        _supabase
            .from('marketplace_bookings')
            .select('id, commission_amount, status')
            .order('created_at', ascending: false),
      ]);

      final listings = List<Map<String, dynamic>>.from(results[0] as List);
      final categories = List<Map<String, dynamic>>.from(results[1] as List);
      final bookings = List<Map<String, dynamic>>.from(results[2] as List);

      _totalListings = listings.length;
      _activeListings =
          listings.where((l) => (l['status'] ?? '') == 'active').length;
      _pendingReview =
          listings.where((l) => (l['status'] ?? '') == 'pending').length;
      _totalBookings = bookings.length;
      _totalCommission = bookings.fold<double>(
          0,
          (sum, b) =>
              sum + (double.tryParse(b['commission_amount'].toString()) ?? 0));

      setState(() {
        _listings = listings;
        _categories = categories;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load marketplace: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    var results = List<Map<String, dynamic>>.from(_listings);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((l) {
        final title = (l['title'] ?? '').toString().toLowerCase();
        final tutor =
            (l['user_profiles']?['full_name'] ?? '').toString().toLowerCase();
        final category = (l['category'] ?? '').toString().toLowerCase();
        return title.contains(q) || tutor.contains(q) || category.contains(q);
      }).toList();
    }

    if (_statusFilter != 'All') {
      if (_statusFilter == 'featured') {
        results = results.where((l) => l['is_featured'] == true).toList();
      } else {
        results = results
            .where((l) =>
                (l['status'] ?? '').toString().toLowerCase() ==
                _statusFilter.toLowerCase())
            .toList();
      }
    }

    setState(() => _filteredListings = results);
  }

  Future<void> _approveListing(Map<String, dynamic> listing) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Approve Listing',
      content: 'Approve "${listing['title'] ?? 'this listing'}"? It will be visible to students.',
      confirmLabel: 'Approve',
      confirmColor: AdminTheme.success,
    );
    if (!confirmed) return;

    try {
      await _supabase.from('marketplace_listings').update({
        'status': 'active',
        'approved_at': DateTime.now().toIso8601String(),
      }).eq('id', listing['id']);

      await _loadMarketplace();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing approved'),
            backgroundColor: AdminTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  Future<void> _rejectListing(Map<String, dynamic> listing) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Reject Listing',
      content: 'Reject "${listing['title'] ?? 'this listing'}"? The tutor will be notified.',
      confirmLabel: 'Reject',
      confirmColor: AdminTheme.error,
    );
    if (!confirmed) return;

    try {
      await _supabase.from('marketplace_listings').update({
        'status': 'rejected',
        'rejected_at': DateTime.now().toIso8601String(),
      }).eq('id', listing['id']);

      await _loadMarketplace();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing rejected'),
            backgroundColor: AdminTheme.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  Future<void> _toggleFeatured(Map<String, dynamic> listing) async {
    final isFeatured = listing['is_featured'] == true;

    try {
      await _supabase.from('marketplace_listings').update({
        'is_featured': !isFeatured,
      }).eq('id', listing['id']);

      await _loadMarketplace();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFeatured
                ? 'Removed from featured'
                : 'Added to featured'),
            backgroundColor: AdminTheme.info,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final val = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(symbol: '\$').format(val);
  }

  BadgeType _statusBadge(String? status) {
    return switch (status) {
      'active' => BadgeType.success,
      'pending' => BadgeType.warning,
      'rejected' => BadgeType.error,
      'featured' => BadgeType.info,
      _ => BadgeType.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Tutor Marketplace',
          subtitle: 'Manage listings, bookings, and marketplace settings',
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AdminTheme.error),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AdminTheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadMarketplace,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildMainContent(),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 600
                ? 3
                : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              title: 'Total Listings',
              value: '$_totalListings',
              subtitle: 'All marketplace listings',
              icon: Icons.store_rounded,
              color: AdminTheme.primary,
            ),
            StatCard(
              title: 'Active Listings',
              value: '$_activeListings',
              subtitle: 'Live on marketplace',
              icon: Icons.check_circle_rounded,
              color: AdminTheme.success,
            ),
            StatCard(
              title: 'Pending Review',
              value: '$_pendingReview',
              subtitle: 'Awaiting approval',
              icon: Icons.pending_actions_rounded,
              color: AdminTheme.warning,
            ),
            StatCard(
              title: 'Total Bookings',
              value: '$_totalBookings',
              subtitle: 'All-time bookings',
              icon: Icons.event_available_rounded,
              color: AdminTheme.info,
            ),
            StatCard(
              title: 'Commission Earned',
              value: _formatCurrency(_totalCommission),
              subtitle: 'Platform revenue',
              icon: Icons.payments_rounded,
              color: AdminTheme.tertiary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Listings'),
            Tab(text: 'Categories'),
            Tab(text: 'Ratings Overview'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildListingsTab(),
              _buildCategoriesTab(),
              _buildRatingsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListingsTab() {
    return Column(
      children: [
        _buildFiltersAndSearch(),
        const SizedBox(height: 12),
        Expanded(child: _buildListingsTable()),
      ],
    );
  }

  Widget _buildFiltersAndSearch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              controller: _searchController,
              hintText: 'Search listings by title, tutor, or category...',
              onChanged: (value) {
                _searchQuery = value;
                _applyFilter();
              },
            ),
            const SizedBox(height: 12),
            isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildStatusFilterChips()],
                  )
                : Row(
                    children: [_buildStatusFilterChips()],
                  ),
          ],
        );
      },
    );
  }

  Widget _buildStatusFilterChips() {
    return Wrap(
      spacing: 6,
      children: _statusFilters.map((status) {
        final isActive = _statusFilter == status;
        final label = status == 'All'
            ? 'All'
            : status[0].toUpperCase() + status.substring(1);
        return ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: isActive,
          onSelected: (_) {
            setState(() => _statusFilter = status);
            _applyFilter();
          },
          selectedColor: AdminTheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive
                ? AdminTheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListingsTable() {
    final columns = [
      'Listing',
      'Tutor',
      'Category',
      'Price',
      'Status',
      'Bookings',
      'Actions',
    ];

    final rows = _filteredListings.map((listing) {
      final title = listing['title'] ?? 'Untitled';
      final tutorName =
          listing['user_profiles']?['full_name'] ?? 'Unknown';
      final category = listing['category'] ?? 'N/A';
      final price = listing['price'] ?? 0;
      final status = listing['status'] ?? 'pending';
      final bookingCount = listing['booking_count'] ?? 0;
      final isFeatured = listing['is_featured'] == true;
      final rating = listing['average_rating'] ?? 0.0;

      return [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title.toString(),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isFeatured) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.star_rounded,
                            size: 14, color: AdminTheme.warning),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12, color: AdminTheme.warning),
                      const SizedBox(width: 2),
                      Text(rating.toString(),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(tutorName.toString(),
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Text(category.toString(), style: const TextStyle(fontSize: 12)),
        Text(_formatCurrency(price),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        StatusBadge(
          label: status.toString().toUpperCase(),
          type: _statusBadge(status),
        ),
        Text(bookingCount.toString()),
        _buildActionsMenu(listing),
      ];
    }).toList();

    return AdminDataTable(
      columns: columns,
      rows: rows,
    );
  }

  Widget _buildActionsMenu(Map<String, dynamic> listing) {
    final status = listing['status'] ?? 'pending';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18),
      onSelected: (action) {
        switch (action) {
          case 'approve':
            _approveListing(listing);
            break;
          case 'reject':
            _rejectListing(listing);
            break;
          case 'feature':
          case 'unfeature':
            _toggleFeatured(listing);
            break;
        }
      },
      itemBuilder: (context) => [
        if (status == 'pending') ...[
          const PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 16, color: AdminTheme.success),
                SizedBox(width: 8),
                Text('Approve', style: TextStyle(color: AdminTheme.success)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'reject',
            child: Row(
              children: [
                Icon(Icons.cancel_rounded,
                    size: 16, color: AdminTheme.error),
                SizedBox(width: 8),
                Text('Reject', style: TextStyle(color: AdminTheme.error)),
              ],
            ),
          ),
        ],
        if (status == 'active' || listing['is_featured'] == true)
          PopupMenuItem(
            value: listing['is_featured'] == true ? 'unfeature' : 'feature',
            child: Row(
              children: [
                Icon(
                  listing['is_featured'] == true
                      ? Icons.star_border_rounded
                      : Icons.star_rounded,
                  size: 16,
                  color: AdminTheme.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  listing['is_featured'] == true
                      ? 'Remove Featured'
                      : 'Feature Listing',
                  style: const TextStyle(color: AdminTheme.warning),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories (${_categories.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Category'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_categories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_rounded,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('No categories defined',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categories.map((cat) {
                  final name = cat['name'] ?? 'Unknown';
                  final listingCount = cat['listing_count'] ?? 0;
                  final isActive = cat['is_active'] ?? true;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(name.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Switch(
                                  value: isActive,
                                  onChanged: (val) =>
                                      _toggleCategory(cat['id'], val),
                                  activeColor: AdminTheme.success,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('$listingCount listings',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCategory(String? id, bool isActive) async {
    if (id == null) return;
    try {
      await _supabase
          .from('marketplace_categories')
          .update({'is_active': isActive}).eq('id', id);
      await _loadMarketplace();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Business English',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              try {
                await _supabase.from('marketplace_categories').insert({
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'is_active': true,
                });
                if (mounted) Navigator.pop(context);
                await _loadMarketplace();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AdminTheme.error),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsTab() {
    final tutorsWithRatings = _listings
        .where((l) => (l['average_rating'] ?? 0) > 0)
        .toList()
      ..sort((a, b) =>
          (b['average_rating'] ?? 0).compareTo(a['average_rating'] ?? 0));

    final topRatings = tutorsWithRatings.take(10).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Rated Listings',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildRatingsList(topRatings)),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildRatingsDistribution()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildRatingsList(topRatings),
                        const SizedBox(height: 16),
                        _buildRatingsDistribution(),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList(List<Map<String, dynamic>> topRatings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: topRatings.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No ratings yet'),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: topRatings.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final listing = entry.value;
                  final title = listing['title'] ?? 'Untitled';
                  final rating = listing['average_rating'] ?? 0;
                  final tutor =
                      listing['user_profiles']?['full_name'] ?? 'Unknown';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: rank <= 3
                          ? AdminTheme.warning.withOpacity(0.1)
                          : Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.05),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: rank <= 3
                              ? AdminTheme.warning
                              : Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.6),
                        ),
                      ),
                    ),
                    title: Text(title.toString(),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(tutor.toString(),
                        style: Theme.of(context).textTheme.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AdminTheme.warning),
                        const SizedBox(width: 2),
                        Text(rating.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildRatingsDistribution() {
    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final listing in _listings) {
      final rating = (listing['average_rating'] ?? 0).round();
      if (rating >= 1 && rating <= 5) {
        dist[rating] = (dist[rating] ?? 0) + 1;
      }
    }

    final total = dist.values.fold<int>(0, (sum, v) => sum + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ratings Distribution',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: total > 0 ? total.toDouble() : 10,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} listings',
                          const TextStyle(
                              color: Colors.white, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final star = 5 - value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$star',
                                    style: const TextStyle(fontSize: 10)),
                                const Icon(Icons.star_rounded,
                                    size: 10, color: AdminTheme.warning),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: dist.entries.toList().reversed.map((entry) {
                    final idx = 5 - entry.key;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: AdminTheme.primary.withOpacity(0.8),
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...dist.entries.toList().reversed.map((entry) {
              final pct =
                  total > 0 ? (entry.value / total * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      child: Text('${entry.key}',
                          style: const TextStyle(fontSize: 11)),
                    ),
                    const Icon(Icons.star_rounded,
                        size: 12, color: AdminTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: total > 0 ? entry.value / total : 0,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AdminTheme.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text('${pct.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
