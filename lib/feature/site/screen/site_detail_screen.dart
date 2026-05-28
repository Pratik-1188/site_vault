import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/feature/expense/provider/expense_provider.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/feature/expense/screen/expense_form_sheet.dart';
import 'package:site_vault/feature/document/provider/document_provider.dart';
import 'package:site_vault/feature/document/model/document.dart';
import 'package:site_vault/feature/document/screen/document_upload_sheet.dart';
import 'package:site_vault/feature/analytics/provider/analytics_provider.dart';
import 'package:site_vault/feature/analytics/model/analytics_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
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
class SiteDetailScreen extends ConsumerStatefulWidget {
  final String siteId;
  final Site? site;

  const SiteDetailScreen({super.key, required this.siteId, this.site});

  @override
  ConsumerState<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends ConsumerState<SiteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentStatus;
  final TextEditingController _expenseSearchController =
      TextEditingController();
  final TextEditingController _documentSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentStatus = widget.site?.status ?? 'active';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenseSearchController.dispose();
    _documentSearchController.dispose();
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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
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
                RadioListTile<String>(
                  title: const Text('Active'),
                  subtitle: const Text('Site is actively running with ongoing expenses.'),
                  secondary: const Icon(Icons.play_arrow_rounded),
                  value: 'active',
                  groupValue: _currentStatus,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _currentStatus = val);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site status set to ACTIVE'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Completed'),
                  subtitle: const Text('Project is finished. Records are sealed.'),
                  secondary: const Icon(Icons.check_circle_outline_rounded),
                  value: 'completed',
                  groupValue: _currentStatus,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _currentStatus = val);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site status set to COMPLETED'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Deleted'),
                  subtitle: const Text('Site is deleted. Read-only review mode.'),
                  secondary: const Icon(Icons.archive_outlined),
                  value: 'deleted',
                  groupValue: _currentStatus,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _currentStatus = val);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site status set to DELETED'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Opens the add/edit expense form sheet
  void _openExpenseFormSheet(
    BuildContext context,
    String siteId,
    String firmId, [
    Expense? expenseToEdit,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFormSheet(
        siteId: siteId,
        firmId: firmId,
        expenseToEdit: expenseToEdit,
      ),
    );
  }

  /// Opens the upload document form sheet
  void _openDocumentUploadSheet(
    BuildContext context,
    String siteId,
    String firmId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocumentUploadSheet(siteId: siteId, firmId: firmId),
    );
  }

  /// Confirms and deletes an expense
  Future<void> _confirmDeleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text(
          'Are you sure you want to delete "${expense.title}"? This will soft-delete the transaction record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(siteExpensesProvider(widget.siteId).notifier)
            .deleteExpense(expense.id);
        ref.invalidate(siteTotalExpensesProvider(widget.siteId));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cleanMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
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

    final baseColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
              title: Text(
                site.name,
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 56,
                    16,
                    16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              _getFirmName(site.firmId).toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                site.startedOn != null
                                    ? site.startedOn!.toReadableString()
                                    : 'Not started',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.circle, size: 8),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentStatus.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 12),
                          ],
                        ),
                        onPressed: () => _showStatusUpdateDialog(context, site.firmId),
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
          final tabIndex = _tabController.index;
          if (tabIndex == 1) {
            // Live Expense Creation Form sheet!
            _openExpenseFormSheet(context, site.id, site.firmId);
          } else if (tabIndex == 2) {
            // Live Document Upload Form sheet!
            _openDocumentUploadSheet(context, site.id, site.firmId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Double click on Expenses/Documents tab to add items!',
                ),
              ),
            );
          }
        },
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
                    site.description ??
                        'No description provided for this site.',
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
                  _infoRow(
                    Icons.play_arrow_rounded,
                    'Started On',
                    site.startedOn != null
                        ? site.startedOn!.toReadableString()
                        : 'Not started yet',
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _infoRow(
                    Icons.check_circle_outline_rounded,
                    'Completed On',
                    site.completedOn != null
                        ? site.completedOn!.toReadableString()
                        : 'Active (In progress)',
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  _infoRow(
                    Icons.domain_rounded,
                    'Parent Firm',
                    _getFirmName(site.firmId),
                  ),
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
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesTab(Site site, Color baseColor) {
    final expensesAsync = ref.watch(filteredSiteExpensesProvider(site.id));
    final totalAsync = ref.watch(siteTotalExpensesProvider(site.id));
    final selectedCategory = ref.watch(expenseCategoryFilterProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Aggregate total spent sum
          totalAsync.when(
            loading: () => Container(
              height: 80,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            error: (e, _) => Text('Error loading total: $e'),
            data: (total) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded, size: 36),
                  title: const Text('Total Expenses Spent', style: TextStyle(fontSize: 12)),
                  subtitle: Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // 2. Search Field inside expenses tab
          SearchBar(
            controller: _expenseSearchController,
            onChanged: (val) {
              ref.read(expenseSearchQueryProvider.notifier).update(val);
              setState(() {});
            },
            hintText: 'Search expenses by title...',
            leading: const Icon(Icons.search_rounded),
            trailing: [
              if (_expenseSearchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _expenseSearchController.clear();
                    ref.read(expenseSearchQueryProvider.notifier).update("");
                    setState(() {});
                  },
                ),
            ],
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHigh),
          ),
          const SizedBox(height: 12),

          // 3. Choice chips row for categories
          categoriesAsync.when(
            loading: () => const SizedBox(height: 38),
            error: (e, _) => const SizedBox.shrink(),
            data: (categories) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Categories'),
                      selected: selectedCategory == null,
                      onSelected: (_) => ref
                          .read(expenseCategoryFilterProvider.notifier)
                          .update(null),
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((c) {
                      final isSelected = selectedCategory == c.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(c.name),
                          selected: isSelected,
                          onSelected: (_) => ref
                              .read(expenseCategoryFilterProvider.notifier)
                              .update(isSelected ? null : c.id),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // 4. Reactive Expenses List
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading expenses: $e')),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Expenses Recorded',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add transaction records for this site by clicking the "+" button below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              _getCategoryIcon(expense.category?.name),
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            expense.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${expense.expenseDate.toReadableString()} • ${expense.paymentMode.toDisplayLabel()}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (expense.gstPercentage != null) ...[
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('GST Split Details'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _dialogSplitRow(
                                              'Base Amount',
                                              '₹${(expense.amount - (expense.gstAmount ?? 0.0)).toStringAsFixed(2)}',
                                            ),
                                            const SizedBox(height: 4),
                                            _dialogSplitRow(
                                              'GST Paid (${expense.gstPercentage!.toInt()}%)',
                                              '₹${(expense.gstAmount ?? 0.0).toStringAsFixed(2)}',
                                            ),
                                            const Divider(height: 16),
                                            _dialogSplitRow(
                                              'Total Sum',
                                              '₹${expense.amount.toStringAsFixed(2)}',
                                              isBold: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Chip(
                                    avatar: const Icon(Icons.receipt_rounded, size: 12),
                                    label: Text(
                                      'Incl. ${expense.gstPercentage!.toInt()}% GST (₹${expense.gstAmount?.toStringAsFixed(2) ?? '0.00'})',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                ),
                                splashRadius: 20,
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    _openExpenseFormSheet(
                                      context,
                                      site.id,
                                      site.firmId,
                                      expense,
                                    );
                                  } else if (action == 'delete') {
                                    _confirmDeleteExpense(context, expense);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_rounded, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogSplitRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.bolt_rounded;
    final lower = categoryName.toLowerCase();
    if (lower.contains('labor') ||
        lower.contains('wage') ||
        lower.contains('salary')) {
      return Icons.engineering_rounded;
    } else if (lower.contains('cable') ||
        lower.contains('wire') ||
        lower.contains('transformer')) {
      return Icons.power_rounded;
    } else if (lower.contains('hardware') ||
        lower.contains('switch') ||
        lower.contains('fuse')) {
      return Icons.hardware_rounded;
    } else if (lower.contains('civil') ||
        lower.contains('concrete') ||
        lower.contains('foundation')) {
      return Icons.foundation_rounded;
    } else if (lower.contains('travel') ||
        lower.contains('fuel') ||
        lower.contains('transport')) {
      return Icons.local_shipping_rounded;
    }
    return Icons.bolt_rounded; // Default
  }

  /// Opens the document URL in a web browser using url_launcher,
  /// or copies the link to clipboard as a fallback.
  Future<void> _downloadOrOpenDocument(
    BuildContext context,
    String path,
    String fileName,
  ) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Generating secure preview link for $fileName...'),
              ),
            ],
          ),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final signedUrl = await ref
          .read(storageRepositoryProvider)
          .getSignedUrl(absolutePath: path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      final uri = Uri.parse(signedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $signedUrl';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Confirms and deletes a document (soft-deletes)
  Future<void> _confirmDeleteDocument(
    BuildContext context,
    SiteDocument doc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text(
          'Are you sure you want to delete "${doc.fileName}"? This will soft-delete the document record from the vault.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(siteDocumentsProvider(widget.siteId).notifier)
            .deleteDocument(doc.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cleanMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Widget _buildDocumentsTab(Site site, Color baseColor) {
    final documentsAsync = ref.watch(filteredSiteDocumentsProvider(site.id));

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar for Documents
          SearchBar(
            controller: _documentSearchController,
            onChanged: (val) {
              ref.read(documentSearchQueryProvider.notifier).update(val);
              setState(() {});
            },
            hintText: 'Search documents by filename...',
            leading: const Icon(Icons.search_rounded),
            trailing: [
              if (_documentSearchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _documentSearchController.clear();
                    ref.read(documentSearchQueryProvider.notifier).update("");
                    setState(() {});
                  },
                ),
            ],
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHigh),
          ),
          const SizedBox(height: 16),

          // 2. Count of Documents
          documentsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (documents) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Uploaded Documents',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${documents.length} ${documents.length == 1 ? "File" : "Files"}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // 3. Document List
          Expanded(
            child: documentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading documents: $e')),
              data: (documents) {
                if (documents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Documents Found',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Upload blueprints, layouts, safety manuals, or other project files.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: documents.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    final isPdf = doc.fileName.toLowerCase().endsWith('.pdf');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: ListTile(
                          onTap: () => _downloadOrOpenDocument(
                            context,
                            doc.fileUrl,
                            doc.fileName,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              isPdf
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.description_rounded,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            doc.fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Uploaded by ${doc.createdByProfile?.displayName ?? "Staff"} • ${doc.createdAt.toReadableString()}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.file_download_rounded,
                                  size: 20,
                                ),
                                onPressed: () => _downloadOrOpenDocument(
                                  context,
                                  doc.fileUrl,
                                  doc.fileName,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                ),
                                splashRadius: 20,
                                onSelected: (action) {
                                  if (action == 'delete') {
                                    _confirmDeleteDocument(context, doc);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(Site site, Color baseColor) {
    // Watch lightweight pre-aggregated server-side views
    final categorySpendAsync = ref.watch(
      categorySpendProvider(siteId: site.id),
    );
    final monthlySpendAsync = ref.watch(monthlySpendProvider(siteId: site.id));
    final vendorSpendAsync = ref.watch(siteVendorSpendProvider(site.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Expense Categories Splits Section
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Cost breakdown by business expense categories for this site.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          categorySpendAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading category splits: $e'),
            data: (categories) {
              if (categories.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No category splits recorded.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              }

              double total = 0.0;
              for (final c in categories) {
                total += c.totalSpend;
              }

              final sorted = List<CategorySpendSummary>.from(categories)
                ..sort((a, b) => b.totalSpend.compareTo(a.totalSpend));

              return Column(
                children: [
                  ...sorted.map((c) {
                    final percentage = total > 0 ? c.totalSpend / total : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _analyticsProgressBar(
                        c.categoryName,
                        '₹${c.totalSpend.toStringAsFixed(2)}',
                        percentage,
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  // Spending Insight Card
                  if (sorted.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              color: baseColor,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Spending Insight',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${sorted.first.categoryName}" represents the largest cost factor at ${((sorted.first.totalSpend / total) * 100).toInt()}% of total expenses on this site.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 12),
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
            },
          ),

          const Divider(height: 40, thickness: 0.5),

          // 2. Month-over-Month Cashflow Timelines Section
          Text(
            'Monthly Spending Trends',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Timeline history of site spending aggregates.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          monthlySpendAsync.when(
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (e, _) => Text('Error loading monthly trend: $e'),
            data: (trends) {
              if (trends.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No historical timelines found.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              }

              double maxVal = 0.0;
              for (final t in trends) {
                if (t.totalSpend > maxVal) {
                  maxVal = t.totalSpend;
                }
              }

              final sortedMonths = List<MonthlySpendTrend>.from(trends)
                ..sort(
                  (a, b) => b.monthDate.compareTo(a.monthDate),
                ); // Newest first

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedMonths.length,
                itemBuilder: (context, index) {
                  final item = sortedMonths[index];
                  final dateStr = _formatAnalyticsMonth(item.monthDate);
                  final ratio = maxVal > 0 ? item.totalSpend / maxVal : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox.shrink(),
                                  Text(
                                    '₹${item.totalSpend.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: ratio),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const Divider(height: 40, thickness: 0.5),

          // 3. Top Suppliers Section
          Text(
            'Top Suppliers Tally',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Ranked vendor splits representing top funding receivers on this site.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          vendorSpendAsync.when(
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (e, _) => Text('Error loading vendor spend: $e'),
            data: (vendors) {
              if (vendors.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No suppliers recorded for this site.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              }

              // Show top 3 vendors
              final topVendors = vendors.take(3).toList();

              return Column(
                children: topVendors.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final v = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '#$rank',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          v.vendorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Text(
                          '₹${v.totalSpend.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _analyticsProgressBar(
    String label,
    String value,
    double percentage,
  ) {
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: percentage),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatAnalyticsMonth(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Status colors removed
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
