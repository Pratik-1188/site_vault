import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:site_vault/shared/provider/firm_provider.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/utils/financial_year.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import '../provider/site_provider.dart';
import '../model/site.dart';

/// A consistent Material 3 screen that displays the list of sites under KK Group
/// using standard, default Material 3 widgets.
class SitesScreen extends ConsumerStatefulWidget {
  const SitesScreen({super.key});

  @override
  ConsumerState<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends ConsumerState<SitesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _onSearchChanged(String value) {
    ref.read(searchQueryProvider.notifier).update(value);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).update("");
  }

  void _onFirmChanged(String? firmId) {
    ref.read(selectedFirmProvider.notifier).update(firmId);
  }

  void _onStatusChanged(String? status) {
    ref.read(selectedStatusProvider.notifier).update(status);
  }

  void _resetAllFilters() {
    _clearSearch();
    ref.read(selectedStatusProvider.notifier).update('active');
    final fy = FinancialYear.current();
    ref.read(startedDateRangeProvider.notifier).update(
      DateRange(from: fy.startDate, to: fy.endDate),
    );
  }

  void _showDateFilterBottomSheet(BuildContext context) {
    final currentRange = ref.read(startedDateRangeProvider);
    final currentFY = FinancialYear.current();
    final fyList = [
      currentFY,
      FinancialYear(currentFY.startYear - 1),
      FinancialYear(currentFY.startYear - 2),
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date Range',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'FINANCIAL YEARS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ...fyList.map((fy) {
                  final isSelected = currentRange.from?.year == fy.startDate.year &&
                      currentRange.from?.month == fy.startDate.month &&
                      currentRange.from?.day == fy.startDate.day &&
                      currentRange.to?.year == fy.endDate.year &&
                      currentRange.to?.month == fy.endDate.month &&
                      currentRange.to?.day == fy.endDate.day;

                  return ListTile(
                     leading: Icon(
                       Icons.calendar_today_rounded,
                       color: isSelected ? Theme.of(context).colorScheme.primary : null,
                     ),
                     title: Text(
                       fy.label,
                       style: TextStyle(
                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                       ),
                     ),
                     subtitle: Text(
                       '${fy.startDate.toReadableString()} - ${fy.endDate.toReadableString()}',
                     ),
                     trailing: isSelected
                         ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                         : null,
                     onTap: () {
                       ref.read(startedDateRangeProvider.notifier).update(
                         DateRange(from: fy.startDate, to: fy.endDate),
                       );
                       Navigator.pop(context);
                     },
                  );
                }),
                const Divider(height: 16),
                ListTile(
                  leading: const Icon(Icons.date_range_rounded),
                  title: const Text('Custom Date Range...'),
                  subtitle: const Text('Select a custom start and end date'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectCustomDateRange(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final currentRange = ref.read(startedDateRangeProvider);
    final initialDateRange = (currentRange.from != null && currentRange.to != null)
        ? DateTimeRange(start: currentRange.from!, end: currentRange.to!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      ref.read(startedDateRangeProvider.notifier).update(
        DateRange(from: picked.start, to: picked.end),
      );
    }
  }

  String _getDateRangeLabel(DateRange dateRange) {
    if (dateRange.from == null || dateRange.to == null) {
      return 'Select Date Range';
    }
    final fy = FinancialYear.fromDate(dateRange.from!);
    if (fy.startDate.year == dateRange.from!.year &&
        fy.startDate.month == dateRange.from!.month &&
        fy.startDate.day == dateRange.from!.day &&
        fy.endDate.year == dateRange.to!.year &&
        fy.endDate.month == dateRange.to!.month &&
        fy.endDate.day == dateRange.to!.day) {
      return fy.label;
    }
    return '${dateRange.from!.toShortString()} - ${dateRange.to!.toShortString()}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Triggers the Sign Out process with a clean M3 warning dialog.
  Future<void> _showSignOutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'Are you sure you want to sign out of KK Group Site Vault?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(authRepositoryProvider).signOut();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to firmsProvider to default SelectedFirm to the first firm on startup
    ref.listen(firmsProvider, (previous, next) {
      next.whenData((firmsList) {
        final currentFirm = ref.read(selectedFirmProvider);
        if (currentFirm == null && firmsList.isNotEmpty) {
          ref.read(selectedFirmProvider.notifier).update(firmsList.first.id);
        }
      });
    });

    final sitesAsync = ref.watch(sitesProvider);
    final selectedFirm = ref.watch(selectedFirmProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: -1,
        onDestinationSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            context.push('/analytics');
          } else if (index == 1) {
            context.push('/admin');
          } else if (index == 2) {
            context.push('/admin');
          } else if (index == 3) {
            context.push('/admin');
          } else if (index == 4) {
            _showSignOutDialog(context);
          }
        },
        children: [
          const NavigationDrawerHeader(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome, Operations Team",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(),
          const NavigationDrawerDestination(
            icon: Icon(Icons.analytics_rounded),
            label: Text("Analytics"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.store_rounded),
            label: Text("Manage Vendors"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.category_rounded),
            label: Text("Manage Categories"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.badge_rounded),
            label: Text("Manage Users"),
          ),
          const Expanded(
            child: SizedBox.shrink(),
          ),
          const Divider(),
          const NavigationDrawerDestination(
            icon: Icon(Icons.logout_rounded),
            label: Text("Logout"),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Search sites by name...',
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                trailing: [
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Business Division",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: '0f140f6f-d994-4695-a838-bee13b3802f1',
                          label: Text('KK Electricals'),
                        ),
                        ButtonSegment<String>(
                          value: '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3',
                          label: Text('KK Associates'),
                        ),
                        ButtonSegment<String>(
                          value: '4e01a36a-87c0-4cca-9428-a2747a130c96',
                          label: Text('KK Solar'),
                        ),
                      ],
                      selected: <String>{
                        selectedFirm ?? '0f140f6f-d994-4695-a838-bee13b3802f1'
                      },
                      onSelectionChanged: (Set<String> newSelection) {
                        _onFirmChanged(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text("All Status"),
                    selected: selectedStatus == null,
                    onSelected: (_) => _onStatusChanged(null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Active"),
                    selected: selectedStatus == 'active',
                    onSelected: (_) => _onStatusChanged('active'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Completed"),
                    selected: selectedStatus == 'completed',
                    onSelected: (_) => _onStatusChanged('completed'),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 24,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                    label: Text(_getDateRangeLabel(ref.watch(startedDateRangeProvider))),
                    selected: true,
                    onSelected: (_) => _showDateFilterBottomSheet(context),
                  ),
                ],
              ),
            ),
          ),
          sitesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load sites: $error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (sites) {
              if (sites.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final site = sites[index];
                      return _buildSiteCard(site);
                    },
                    childCount: sites.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(Site site) {
    return Card(
      child: InkWell(
        onTap: () {
          context.push('/site/${site.id}', extra: site);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      site.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(context, site.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                site.description ?? 'No description provided for this site.',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        site.startedOn != null
                            ? site.startedOn!.toReadableString()
                            : 'Not started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    _getFirmName(site.firmId),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Icon(
              Icons.search_off_rounded,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'No Sites Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any sites matching your selected search criteria or filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetAllFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset All Filters'),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
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
}

class NavigationDrawerHeader extends StatelessWidget {
  final Widget child;

  const NavigationDrawerHeader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        child: child,
      ),
    );
  }
}
