import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:site_vault/shared/theme/firm_colors.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import '../model/site.dart';

/// A premium, highly polished Material 3 screen that displays comprehensive
/// details for a specific project site.
///
/// Features a collapsible NestedScrollView header with a collapsible layout,
/// and a top-level custom TabBar directing the user through four areas:
/// 1. [Overview] - Timelines, metadata, and status adjustment capabilities.
/// 2. [Expenses] - Visual listing of categorized expenses and spending tallies.
/// 3. [Documents] - Attached files vault, receipts list, and upload hooks.
/// 4. [Analytics] - Beautiful cost distribution indicators and spending splits.
class SiteDetailScreen extends StatefulWidget {
  final String siteId;
  final Site? site;

  const SiteDetailScreen({
    super.key,
    required this.siteId,
    this.site,
  });

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentStatus = widget.site?.status ?? 'active';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getFirmName(String firmId) {
    switch (firmId.toLowerCase()) {
      case '0f140f6f-d994-4695-a838-bee13b3802f1':
        return 'KK Electricals';
      case '4e01a36a-87c0-4cca-9428-a2747a130c96':
        return 'KK Solar';
      case '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3':
        return 'KK Associates';
      default:
        return 'KK Group';
    }
  }

  void _showStatusUpdateDialog(BuildContext context, String firmId) {
    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final baseColor = firmColors.getFirmColor(firmId);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Site Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the operational status for this project site. This affects filters and active logs.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _statusSelectionTile(context, 'active', 'Active', 'Site is actively running with ongoing expenses.', Icons.play_arrow_rounded, const Color(0xFF059669), baseColor),
                _statusSelectionTile(context, 'completed', 'Completed', 'Project is finished. Records are sealed.', Icons.check_circle_outline_rounded, const Color(0xFF2563EB), baseColor),
                _statusSelectionTile(context, 'archived', 'Archived', 'Site is archived. Read-only review mode.', Icons.archive_outlined, const Color(0xFF475569), baseColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusSelectionTile(
    BuildContext context,
    String statusKey,
    String label,
    String description,
    IconData icon,
    Color statusColor,
    Color activeIndicatorColor,
  ) {
    final isSelected = _currentStatus == statusKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentStatus = statusKey;
          });
          Navigator.pop(context);
          // TODO: Hook provider state update to push database changes
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Site status set to ${label.toUpperCase()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: statusColor,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? activeIndicatorColor : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? activeIndicatorColor.withValues(alpha: 0.05) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: statusColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? activeIndicatorColor : null,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, color: activeIndicatorColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    if (site == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Details...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final baseColor = firmColors.getFirmColor(site.firmId);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final softSurfaceColor = firmColors.getFirmSurfaceColor(site.firmId, isDarkMode);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
              title: innerBoxIsScrolled
                  ? Text(
                      site.name,
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 50, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Sub-row: Firm indicator
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: softSurfaceColor,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: baseColor.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              _getFirmName(site.firmId),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: baseColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Main name display
                      Text(
                        site.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Meta info: Date & Interactive Status Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                site.startedOn != null
                                    ? site.startedOn!.toReadableString()
                                    : 'Not started',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showStatusUpdateDialog(context, site.firmId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_currentStatus).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(_currentStatus).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(_currentStatus),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _currentStatus.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(_currentStatus),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 10,
                                    color: _getStatusColor(_currentStatus),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: baseColor,
                  unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.black54,
                  indicatorColor: baseColor,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Expenses'),
                    Tab(text: 'Documents'),
                    Tab(text: 'Analytics'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(site, isDarkMode),
            _buildExpensesTab(site, baseColor),
            _buildDocumentsTab(site, baseColor),
            _buildAnalyticsTab(site, baseColor),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open FAB according to active tab (add expense, add document, etc.)
          final tabIndex = _tabController.index;
          if (tabIndex == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add Expense dialog clicked!')),
            );
          } else if (tabIndex == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload Document dialog clicked!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Float action clicked!')),
            );
          }
        },
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildOverviewTab(Site site, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Project',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    site.description ?? 'No description provided for this site.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: site.description == null ? Colors.grey : null,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Timeline and Details Grid
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timelines & Info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.play_arrow_rounded, 'Started On',
                      site.startedOn != null ? site.startedOn!.toReadableString() : 'Not started yet'),
                  const Divider(height: 24, thickness: 0.5),
                  _infoRow(Icons.check_circle_outline_rounded, 'Completed On',
                      site.completedOn != null ? site.completedOn!.toReadableString() : 'Active (In progress)'),
                  const Divider(height: 24, thickness: 0.5),
                  _infoRow(Icons.domain_rounded, 'Parent Firm', _getFirmName(site.firmId)),
                  const Divider(height: 24, thickness: 0.5),
                  _infoRow(Icons.fingerprint_rounded, 'Site UUID', site.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesTab(Site site, Color baseColor) {
    // Beautiful placeholder layout waiting for integration in the next phases
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // High-fidelity expense aggregate card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [baseColor, baseColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Expenses Spent',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹4,25,850.00',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Records',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded, size: 14),
                label: const Text('Filter', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final mockExpenses = [
                  {'title': 'Transformer Installation Cable', 'amount': '₹1,45,000.00', 'date': '24 May, 2026', 'mode': 'NEFT', 'category': 'Cables & Wiring'},
                  {'title': 'Site Worker Wages (Week 12)', 'amount': '₹48,500.00', 'date': '22 May, 2026', 'mode': 'CASH', 'category': 'Labor'},
                  {'title': 'Junction Boxes Purchase', 'amount': '₹32,350.00', 'date': '19 May, 2026', 'mode': 'UPI', 'category': 'Hardware'},
                  {'title': 'Concrete Foundation & Support', 'amount': '₹2,00,000.00', 'date': '12 May, 2026', 'mode': 'RTGS', 'category': 'Civil Work'},
                ];
                final expense = mockExpenses[index];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: baseColor.withValues(alpha: 0.1),
                        child: Icon(Icons.bolt_rounded, color: baseColor),
                      ),
                      title: Text(
                        expense['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        '${expense['date']} • ${expense['mode']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            expense['amount']!,
                            style: TextStyle(
                              color: baseColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              expense['category']!,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(Site site, Color baseColor) {
    // Beautiful placeholder document list
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded Documents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '3 Files',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final mockDocs = [
                  {'name': 'Invoice_CityMall_Wiring.pdf', 'size': '2.4 MB', 'uploadedBy': 'Amit Sharma', 'date': '24 May, 2026'},
                  {'name': 'SiteLayoutDrawing_V2.dwg', 'size': '15.8 MB', 'uploadedBy': 'Suresh Patel', 'date': '20 May, 2026'},
                  {'name': 'GST_Receipt_Hardware.pdf', 'size': '850 KB', 'uploadedBy': 'Amit Sharma', 'date': '19 May, 2026'},
                ];
                final doc = mockDocs[index];
                final isPdf = doc['name']!.endsWith('.pdf');
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isPdf ? Colors.redAccent : Colors.teal).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
                          color: isPdf ? Colors.redAccent : Colors.teal,
                        ),
                      ),
                      title: Text(
                        doc['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${doc['size']} • By ${doc['uploadedBy']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.file_download_rounded, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Downloading ${doc['name']}...')),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(Site site, Color baseColor) {
    // Beautiful placeholder visual cost-split charts
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Cost breakdown by business expense categories for this site.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Cost breakdown list meters
          _analyticsProgressBar('Civil Work', '₹2,00,000.00', 0.47, baseColor),
          const SizedBox(height: 16),
          _analyticsProgressBar('Cables & Wiring', '₹1,45,000.00', 0.34, baseColor),
          const SizedBox(height: 16),
          _analyticsProgressBar('Labor Wages', '₹48,500.00', 0.11, baseColor),
          const SizedBox(height: 16),
          _analyticsProgressBar('Hardware & Fuses', '₹32,350.00', 0.08, baseColor),
          
          const SizedBox(height: 32),
          // Summary card
          Card(
            color: baseColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.insights_rounded, color: baseColor, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spending Insight',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Civil Work represents the largest single expense factor at 47% of total cost on this site.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyticsProgressBar(String label, String value, double percentage, Color baseColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: baseColor, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: baseColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(baseColor),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF059669); // Emerald 600
      case 'completed':
        return const Color(0xFF2563EB); // Blue 600
      case 'archived':
      default:
        return const Color(0xFF475569); // Slate 600
    }
  }
}

/// Helper Persistent Header Delegate to anchor the custom TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
