import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';

import 'package:site_vault/shared/model/firm.dart';
import 'package:site_vault/shared/provider/firm_provider.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/utils/financial_year.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/widget/button_group.dart';
import 'package:site_vault/shared/widget/custom_search_bar.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import '../provider/site_provider.dart';
import '../model/site.dart';

/// A premium, high-contrast Material 3 screen that displays the site directory under KK Group
/// utilizing the custom visual bento structure and technical layout designed on Stitch.
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
    final currentStatus = ref.read(selectedStatusProvider);
    if (currentStatus == status) {
      ref
          .read(selectedStatusProvider.notifier)
          .update(null); // Clear filter on re-tap
    } else {
      ref.read(selectedStatusProvider.notifier).update(status);
    }
  }

  void _resetAllFilters() {
    _clearSearch();
    ref.read(selectedStatusProvider.notifier).update('active');
    final fy = FinancialYear.current();
    ref
        .read(startedDateRangeProvider.notifier)
        .update(DateRange(from: fy.startDate, to: fy.endDate));
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.verticalMd,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
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
                      final isSelected =
                          currentRange.from?.year == fy.startDate.year &&
                          currentRange.from?.month == fy.startDate.month &&
                          currentRange.from?.day == fy.startDate.day &&
                          currentRange.to?.year == fy.endDate.year &&
                          currentRange.to?.month == fy.endDate.month &&
                          currentRange.to?.day == fy.endDate.day;

                      return ListTile(
                        leading: Icon(
                          Icons.calendar_today_rounded,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          fy.label,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${fy.startDate.toReadableString()} - ${fy.endDate.toReadableString()}',
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          ref
                              .read(startedDateRangeProvider.notifier)
                              .update(
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final currentRange = ref.read(startedDateRangeProvider);
    final initialDateRange =
        (currentRange.from != null && currentRange.to != null)
        ? DateTimeRange(start: currentRange.from!, end: currentRange.to!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      ref
          .read(startedDateRangeProvider.notifier)
          .update(DateRange(from: picked.start, to: picked.end));
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

  /// Opens the modal bottom sheet to create a new project site
  void _openSiteForm(BuildContext context, String firmId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SiteFormSheet(firmId: firmId),
    );
  }

  /// Confirms and handles user sign out
  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
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
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(authActionsProvider).signOut();
      } catch (e) {
        if (mounted) {
          AppSnackBar.showError(context, 'Error signing out: $e');
        }
      }
    }
  }

  String _cleanFirmName(String name) {
    if (name.toLowerCase().startsWith('kk ')) {
      return name.substring(3).trim();
    }
    return name;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final firmsAsync = ref.watch(firmsProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar.medium(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              scrolledUnderElevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => context.go('/'),
                tooltip: 'Back to Dashboard',
              ),
              title: Text(
                'Site Directory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.account_circle_rounded,
                    size: 28,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'User Profile Options',
                  onSelected: (val) {
                    if (val == 'signout') {
                      _handleSignOut();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'signout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text('Sign Out'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // 1. Segmented Business Division Selector
          firmsAsync.when(
            data: (firmsList) => _buildSegmentedButton(context, selectedFirm, firmsList),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (err, _) => const SizedBox.shrink(),
          ),

          // 2. Floating Search Bar with Filter Reset Option
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hintText: 'Search sites, codes, or managers...',
              showClearButton: searchQuery.isNotEmpty,
              onClear: _clearSearch,
              onFilterPressed: _resetAllFilters,
              filterTooltip: 'Reset All Filters',
            ),
          ),

          // 3. Filter Chips Row
          _buildFilterChipsRow(context, selectedStatus),

          // 4. Scrollable Ledger Content (Active Sites list)
          Expanded(
            child: sitesAsync.when(
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

                final firmsList = firmsAsync.value ?? const [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    return _buildSiteCard(site, firmsList);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
      floatingActionButton: selectedFirm != null
          ? FloatingActionButton.extended(
              onPressed: () => _openSiteForm(context, selectedFirm),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('ADD SITE'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 2) {
            context.go('/analytics');
          } else if (index == 3) {
            context.go('/admin');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: 'Sites',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedButton(BuildContext context, String? selectedFirm, List<Firm> firms) {
    if (firms.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ButtonGroup<String>(
        options: firms.map((firm) {
          return ButtonGroupOption<String>(
            label: _cleanFirmName(firm.name),
            value: firm.id,
          );
        }).toList(),
        selectedValue: selectedFirm ?? firms.first.id,
        onSelected: _onFirmChanged,
      ),
    );
  }

  Widget _buildFilterChipsRow(BuildContext context, String? selectedStatus) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildDateFilterChip(context),
          const SizedBox(width: 12),
          SizedBox(
            height: 24,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(width: 12),
          _buildStatusChip(
            context,
            label: 'Active',
            icon: Icons.check_circle_outline_rounded,
            value: 'active',
            selectedValue: selectedStatus,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            context,
            label: 'Completed',
            icon: Icons.history_rounded,
            value: 'completed',
            selectedValue: selectedStatus,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            context,
            label: 'Deleted',
            icon: Icons.delete_outline_rounded,
            value: 'deleted',
            selectedValue: selectedStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String value,
    required String? selectedValue,
  }) {
    final isSelected = selectedValue == value;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => _onStatusChanged(value),
      borderRadius: AppRadius.brSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: AppRadius.brSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterChip(BuildContext context) {
    final dateRange = ref.watch(startedDateRangeProvider);
    return InkWell(
      onTap: () => _showDateFilterBottomSheet(context),
      borderRadius: AppRadius.brSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: AppRadius.brSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _getDateRangeLabel(dateRange),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteCard(Site site, List<Firm> firms) {
    final firm = firms.firstWhere(
      (f) => f.id.toLowerCase() == site.firmId.toLowerCase(),
      orElse: () => Firm(
        id: site.firmId,
        name: 'Group',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final cleanFirmName = _cleanFirmName(firm.name);
    final startedDate = site.startedOn != null
        ? site.startedOn!.toReadableString().toUpperCase()
        : 'NOT STARTED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: AppRadius.brSm,
      ),
      child: InkWell(
        borderRadius: AppRadius.brSm,
        onTap: () {
          context.push('/site/${site.id}', extra: site);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upper Block: Title and status chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          site.description ??
                              'No description provided for this site.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSiteStatusBadge(context, site.status),
                ],
              ),

              // Card Inner Divider (dotted/subtle border separating upper and lower blocks)
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),

              // Lower Block: Details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PARENT DIVISION',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cleanFirmName.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'START DATE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        startedDate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteStatusBadge(BuildContext context, String status) {
    final statusLower = status.toLowerCase();
    final isActive = statusLower == 'active';
    final isCompleted = statusLower == 'completed';

    final Color bgColor;
    final Color textColor;
    final IconData icon;

    if (isActive) {
      bgColor = Theme.of(context).colorScheme.secondaryContainer;
      textColor = Theme.of(context).colorScheme.onSecondaryContainer;
      icon = Icons.flash_on_rounded;
    } else if (isCompleted) {
      bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
      icon = Icons.done_all_rounded;
    } else {
      bgColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
      icon = Icons.archive_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Sites Found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any sites matching your selected search criteria or filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}

// ============================================================================
// SITE BOTTOM SHEET FORM EDITOR
// ============================================================================
class _SiteFormSheet extends ConsumerStatefulWidget {
  final String firmId;

  const _SiteFormSheet({required this.firmId});

  @override
  ConsumerState<_SiteFormSheet> createState() => _SiteFormSheetState();
}

class _SiteFormSheetState extends ConsumerState<_SiteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _startedOn;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartedOnDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startedOn ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startedOn = picked;
        _dateController.text = picked.toReadableString();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _startedOn == null) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      await ref.read(siteActionsProvider).createSite(
        firmId: widget.firmId,
        name: name,
        description: description.isEmpty ? null : description,
        startedOn: _startedOn!,
        status: 'active',
      );

      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.showSuccess(context, 'Site created successfully!');
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        AppSnackBar.showError(context, cleanMessage);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.verticalMd,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sticky Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add New Project Site',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24, indent: 24, endIndent: 24),

                    // Scrollable form content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                borderRadius: AppRadius.brXs,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Site Specification',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _nameController,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        labelText: 'Site Name *',
                                        prefixIcon: Icon(Icons.location_on_rounded),
                                        hintText: 'e.g. Solar Power Grid A',
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter a site name';
                                        }
                                        if (val.trim().length < 3) {
                                          return 'Site name must be at least 3 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _descriptionController,
                                      maxLines: 2,
                                      textCapitalization: TextCapitalization.sentences,
                                      decoration: const InputDecoration(
                                        labelText: 'Description / Scope',
                                        prefixIcon: Icon(Icons.description_rounded),
                                        hintText: 'Describe the scope of work (optional)',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _dateController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Start Date *',
                                        prefixIcon: Icon(Icons.calendar_today_rounded),
                                        hintText: 'Select project start date',
                                      ),
                                      onTap: () => _selectStartedOnDate(context),
                                      validator: (val) {
                                        if (_startedOn == null) {
                                          return 'Please select a start date';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: _isSaving ? null : _submit,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: const Text('CREATE SITE'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.brSm,
                                ),
                              ),
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
      ),
    );
  }
}
