import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:site_vault/shared/theme/firm_colors.dart';
import 'package:site_vault/shared/provider/firm_provider.dart';
import 'package:site_vault/shared/model/firm.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/utils/financial_year.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import '../provider/site_provider.dart';
import '../model/site.dart';

/// A premium, highly consistent Material 3 screen that displays the list of
/// sites under KK Group.
///
/// Features dynamic firm-level color coding, advanced real-time search & filters,
/// custom status badges, and server-side filtering.
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Sites Directory'),
            sitesAsync.maybeWhen(
              data: (sites) => Text(
                '${sites.length} total ${sites.length == 1 ? 'site' : 'sites'} matching',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded),
            tooltip: 'Executive Analytics',
            onPressed: () => context.push('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_suggest_rounded),
            tooltip: 'Administration Hub',
            onPressed: () => context.push('/admin'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => _showSignOutDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                'KK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(context),
          _buildFilterSection(context),
          const Divider(height: 1, thickness: 1, color: Colors.transparent),
          Expanded(child: _buildListSection(sitesAsync)),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black26
                  : Colors.black12.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search sites by name...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: _clearSearch,
                    splashRadius: 20,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final selectedFirm = ref.watch(selectedFirmProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);
    final firmsAsync = ref.watch(firmsProvider);
    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Firms horizontal chips
          firmsAsync.when(
            loading: () => _buildShimmerChips(),
            error: (error, _) =>
                _buildFirmChipsFallback(selectedFirm, firmColors),
            data: (firms) =>
                _buildFirmChips(firms, selectedFirm, firmColors, isDarkMode),
          ),
          const SizedBox(height: 6),
          // Row 2: Status horizontal chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatusChip(
                  'All Status',
                  selectedStatus == null,
                  () => _onStatusChanged(null),
                ),
                _buildStatusChip(
                  'Active',
                  selectedStatus == 'active',
                  () => _onStatusChanged('active'),
                ),
                _buildStatusChip(
                  'Completed',
                  selectedStatus == 'completed',
                  () => _onStatusChanged('completed'),
                ),
                _buildStatusChip(
                  'Deleted',
                  selectedStatus == 'deleted',
                  () => _onStatusChanged('deleted'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Row 3: Date Range horizontal chip (Premium, theme-consistent styling)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ActionChip(
                  avatar: Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    _getDateRangeLabel(ref.watch(startedDateRangeProvider)),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _showDateFilterBottomSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 100,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFirmChipsFallback(String? selectedFirm, FirmColors firmColors) {
    final staticFirms = [
      {"id": "0f140f6f-d994-4695-a838-bee13b3802f1", "name": "KK Electricals"},
      {"id": "4e01a36a-87c0-4cca-9428-a2747a130c96", "name": "KK Solar"},
      {"id": "169eceeb-dfc3-4535-b6ad-2e9f8eb884d3", "name": "KK Associates"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: staticFirms.map((f) {
          final isSelected = selectedFirm == f['id'];
          final color = firmColors.getFirmColor(f['id']!);
          return _buildChoiceChip(
            f['name']!,
            isSelected,
            () {
              if (!isSelected) {
                _onFirmChanged(f['id']);
              }
            },
            color,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFirmChips(
    List<Firm> firms,
    String? selectedFirm,
    FirmColors firmColors,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: firms.map((firm) {
          final isSelected = selectedFirm == firm.id;
          final color = firmColors.getFirmColor(firm.id);
          return _buildChoiceChip(
            firm.name,
            isSelected,
            () {
              if (!isSelected) {
                _onFirmChanged(firm.id);
              }
            },
            color,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    bool selected,
    VoidCallback onTap,
    Color? firmColor,
  ) {
    final isAll = firmColor == null;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAll) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: firmColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildListSection(AsyncValue<List<Site>> sitesAsync) {
    return sitesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
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
      data: (sites) {
        if (sites.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: sites.length,
          itemBuilder: (_, index) {
            final site = sites[index];
            return _buildSiteCard(site);
          },
        );
      },
    );
  }

  Widget _buildSiteCard(Site site) {
    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Retrieve colors dynamically from the ThemeExtension
    final baseColor = firmColors.getFirmColor(site.firmId);
    final cardBgColor =
        Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;
    final softSurfaceColor = firmColors.getFirmSurfaceColor(
      site.firmId,
      isDarkMode,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.push('/site/${site.id}', extra: site);
          },
          child: Container(
            decoration: BoxDecoration(
              // Draw a clean background blending with standard cards
              color: cardBgColor,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Sleek firm-colored indicator bar
                  Container(width: 5, color: baseColor),

                  // 2. Card Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name & Status Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  site.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(site.status),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Description text
                          Text(
                            site.description ??
                                'No description provided for this site.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: site.description == null
                                      ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withValues(alpha: 0.5)
                                      : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 16),

                          // Footer metadata
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Starting date info
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    site.startedOn != null
                                        ? site.startedOn!.toReadableString()
                                        : 'Not started',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),

                              // Firm colored tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 3.0,
                                ),
                                decoration: BoxDecoration(
                                  color: softSurfaceColor,
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(
                                    color: baseColor.withValues(alpha: 0.2),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'active':
        color = const Color(0xFF059669); // Emerald 600
        bgColor = const Color(0xFFD1FAE5); // Emerald 100
        break;
      case 'completed':
        color = const Color(0xFF2563EB); // Blue 600
        bgColor = const Color(0xFFDBEAFE); // Blue 100
        break;
      case 'deleted':
      default:
        color = const Color(0xFF475569); // Slate 600
        bgColor = const Color(0xFFF1F5F9); // Slate 100
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      bgColor = color.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.secondary,
              ),
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
