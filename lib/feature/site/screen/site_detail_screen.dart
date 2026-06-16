import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';

import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
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
import '../widgets/expense_tab.dart';
import '../widgets/documents_tab.dart';
import '../model/site.dart';
import '../provider/site_provider.dart';

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
  String? _statusOverride;
  TextEditingController? _nameEditController;
  TextEditingController? _descEditController;
  DateTime? _selectedStartDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentStatus = widget.site?.status ?? 'active';
    _statusOverride = widget.site?.status;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameEditController?.dispose();
    _descEditController?.dispose();
    super.dispose();
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
        await ref.read(authRepositoryProvider).signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<bool> _confirmStatusChange({
    required String fromStatus,
    required String toStatus,
  }) async {
    if (fromStatus == toStatus) return true;

    final normalizedFrom = fromStatus.toLowerCase();
    final normalizedTo = toStatus.toLowerCase();
    final destructive = normalizedTo == 'deleted';
    final title = destructive ? 'Delete Site?' : 'Change Site Status?';
    final message = destructive
        ? 'This will mark the site as DELETED and soft-delete related expenses. Documents will remain attached.'
        : 'This will mark the site as COMPLETED and lock the site in read-only mode.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          '$message\n\nCurrent status: ${normalizedFrom.toUpperCase()}\nNew status: ${normalizedTo.toUpperCase()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  bool _isSaving = false;

  Future<void> _saveSiteSettings(String siteId, {String? status}) async {
    final name = _nameEditController?.text.trim();
    if (name == null || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a site name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final description = _descEditController?.text.trim();
      final targetStatus = status ?? _currentStatus;
      final previousStatus = _currentStatus;

      if (targetStatus != previousStatus) {
        final confirmed = await _confirmStatusChange(
          fromStatus: previousStatus,
          toStatus: targetStatus,
        );
        if (!confirmed) {
          return;
        }
      }

      final startedOn = _selectedStartDate ?? DateTime.now();

      DateTime? completedOn;
      if (targetStatus == 'completed') {
        completedOn = DateTime.now();
      }

      await ref
          .read(siteRepositoryProvider)
          .updateSite(
            siteId: siteId,
            name: name,
            description: description,
            startedOn: startedOn,
            status: targetStatus,
            completedOn: completedOn,
          );

      _currentStatus = targetStatus;
      _statusOverride = targetStatus;

      ref.invalidate(siteDetailsProvider(siteId));
      ref.invalidate(sitesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site settings updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Clear lazy controllers to force re-initialization on next build
      setState(() {
        _nameEditController = null;
        _descEditController = null;
        _selectedStartDate = null;
      });
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _applyStatusAction(String siteId, String nextStatus) async {
    await _saveSiteSettings(siteId, status: nextStatus);
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

  /// Displays a stunning, premium detail popup dialog for a selected expense
  void _showExpenseDetailDialog(BuildContext context, Expense expense) {
    final siteAsync = ref.read(siteDetailsProvider(widget.siteId));
    final site = siteAsync.value ?? widget.site;
    final isEditable = _currentStatus == 'active';
    final firmId = site?.firmId ?? expense.firmId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  _getCategoryIcon(expense.category?.name),
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expense.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      expense.category?.name ?? 'General',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 8),
                _dialogSplitRow(
                  'Amount Spent',
                  '₹${expense.amount.toStringAsFixed(2)}',
                  isBold: true,
                ),
                const SizedBox(height: 8),
                _dialogSplitRow(
                  'Payment Mode',
                  expense.paymentMode.toDisplayLabel(),
                ),
                const SizedBox(height: 8),
                _dialogSplitRow(
                  'Expense Date',
                  expense.expenseDate.toReadableString(),
                ),
                const SizedBox(height: 8),
                _dialogSplitRow(
                  'Created By',
                  expense.createdByProfile?.displayName ?? 'Staff',
                ),
                const SizedBox(height: 8),
                _dialogSplitRow(
                  'Refundable',
                  expense.isRefundable ? 'Yes' : 'No',
                ),
                if (expense.vendor != null) ...[
                  const SizedBox(height: 8),
                  _dialogSplitRow('Vendor', expense.vendor!.name),
                ],
                const SizedBox(height: 12),
                if (expense.description != null &&
                    expense.description!.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: AppRadius.brSm,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      expense.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (expense.gstPercentage != null) ...[
                  Text(
                    'GST Tax Split',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: AppRadius.brSm,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
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
                ],
                if (expense.attachmentPath != null &&
                    expense.attachmentPath!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Attachment',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.brSm,
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        _downloadOrOpenDocument(
                          context,
                          expense.attachmentPath!,
                          expense.title,
                        );
                      },
                      borderRadius: AppRadius.brSm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'View Attachment / Receipt',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new_rounded,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
            if (isEditable)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openExpenseFormSheet(
                    context,
                    widget.siteId,
                    firmId,
                    expense,
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('EDIT'),
              ),
          ],
        );
      },
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
    final siteAsync = ref.watch(siteDetailsProvider(widget.siteId));
    final site = siteAsync.value ?? widget.site;

    if (site != null) {
      if (_statusOverride != null) {
        if (_statusOverride == site.status) {
          _currentStatus = site.status;
          _statusOverride = null;
        } else {
          _currentStatus = _statusOverride!;
        }
      } else if (_currentStatus != site.status) {
        _currentStatus = site.status;
      }
    }

    if (site == null) {
      return siteAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
              tooltip: 'Back to Dashboard',
            ),
            title: const Text('Loading Details...'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
              tooltip: 'Back to Dashboard',
            ),
            title: const Text('Error'),
          ),
          body: Center(child: Text('Error loading site details: $err')),
        ),
        data: (fetchedSite) {
          return _buildMainContent(context, fetchedSite);
        },
      );
    }

    return _buildMainContent(context, site);
  }

  Widget _buildMainContent(BuildContext context, Site site) {
    final baseColor = Theme.of(context).colorScheme.primary;

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
                onPressed: () => context.pop(),
                tooltip: 'Back to Dashboard',
              ),
              title: Text(
                site.name,
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
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Expenses'),
                    Tab(text: 'Documents'),
                    Tab(text: 'Analytics'),
                    Tab(text: 'Settings'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            ExpenseTab(
              site: site,
              currentStatus: _currentStatus,
              onOpenExpenseFormSheet: _openExpenseFormSheet,
              onShowExpenseDetail: _showExpenseDetailDialog,
              onDownloadOrOpenDocument: _downloadOrOpenDocument,
              getCategoryIcon: _getCategoryIcon,
              onConfirmDeleteExpense: _confirmDeleteExpense,
            ),
            DocumentsTab(
              site: site,
              currentStatus: _currentStatus,
              onOpenDocument: _downloadOrOpenDocument,
              onEditDocument: _showEditDocumentDialog,
              onDeleteDocument: _confirmDeleteDocument,
            ),
            _buildAnalyticsTab(site, baseColor),
            _buildSettingsTab(site, baseColor),
          ],
        ),
      ),
      floatingActionButton:
          (_currentStatus != 'active' ||
              _tabController.index == 2 ||
              _tabController.index == 3)
          ? null
          : FloatingActionButton(
              onPressed: () {
                final tabIndex = _tabController.index;
                if (tabIndex == 0) {
                  // Live Expense Creation Form sheet!
                  _openExpenseFormSheet(context, site.id, site.firmId);
                } else if (tabIndex == 1) {
                  // Live Document Upload Form sheet!
                  _openDocumentUploadSheet(context, site.id, site.firmId);
                }
              },
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildStatusActionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color accent,
    required VoidCallback? onPressed,
    bool destructive = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: destructive
              ? theme.colorScheme.error.withValues(alpha: 0.28)
              : accent.withValues(alpha: 0.24),
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: destructive
                    ? theme.colorScheme.errorContainer
                    : accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.brSm,
              ),
              child: Icon(
                icon,
                color: destructive
                    ? theme.colorScheme.onErrorContainer
                    : accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: destructive ? theme.colorScheme.error : accent,
                foregroundColor: destructive
                    ? theme.colorScheme.onError
                    : theme.colorScheme.onPrimary,
              ),
              child: Text(
                destructive ? 'DELETE' : 'COMPLETE',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(Site site, Color baseColor) {
    final theme = Theme.of(context);

    // Initialize editing controllers lazily
    _nameEditController ??= TextEditingController(text: site.name);
    _descEditController ??= TextEditingController(text: site.description ?? '');
    _selectedStartDate ??= site.startedOn ?? DateTime.now();

    final isEditable = _currentStatus == 'active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Locked Banner Alert
          if (!isEditable) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: AppRadius.brSm,
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentStatus == 'completed'
                        ? Icons.lock_rounded
                        : Icons.delete_forever_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _currentStatus == 'completed'
                          ? 'This project is marked as COMPLETED. Its settings and status are locked and cannot be modified.'
                          : 'This project is marked as DELETED. All settings are locked in read-only archive mode.',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 2. Main Form Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              borderRadius: AppRadius.brMd,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Site/Project Configuration',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: baseColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Site Name Input
                  TextFormField(
                    controller: _nameEditController,
                    enabled: isEditable,
                    decoration: const InputDecoration(
                      labelText: 'Site/Project Name *',
                      prefixIcon: Icon(Icons.domain_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Site Description Input
                  TextFormField(
                    controller: _descEditController,
                    enabled: isEditable,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Site/Project Description',
                      prefixIcon: Icon(Icons.description_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Site Start Date Input
                  Container(
                    decoration: BoxDecoration(
                      color: isEditable
                          ? Colors.transparent
                          : theme.colorScheme.surfaceContainerLow.withValues(
                              alpha: 0.5,
                            ),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: AppRadius.brXs,
                    ),
                    child: ListTile(
                      enabled: isEditable,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        'Project Start Date',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _selectedStartDate!.toReadableString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        color: isEditable
                            ? baseColor
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      trailing: isEditable
                          ? const Icon(Icons.edit_calendar_rounded)
                          : null,
                      onTap: isEditable
                          ? () => _selectStartDate(context)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (isEditable) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Status Actions',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusActionCard(
                      context: context,
                      title: 'Mark Site as Completed',
                      description:
                          'Lock the site, keep the record, and stop further edits.',
                      icon: Icons.lock_rounded,
                      accent: baseColor,
                      onPressed: _isSaving
                          ? null
                          : () => _applyStatusAction(site.id, 'completed'),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusActionCard(
                      context: context,
                      title: 'Delete This Item',
                      description:
                          'Archive the site and soft-delete related expenses.',
                      icon: Icons.delete_forever_rounded,
                      accent: theme.colorScheme.error,
                      destructive: true,
                      onPressed: _isSaving
                          ? null
                          : () => _applyStatusAction(site.id, 'deleted'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Save Button
          if (isEditable)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _saveSiteSettings(site.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: baseColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brSm),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                iconAlignment: IconAlignment.start,
                label: const Text(
                  'SAVE SITE CONFIGURATION',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
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

  /// Displays a premium dialog allowing users to edit a document's filename and description.
  Future<void> _showEditDocumentDialog(
    BuildContext context,
    SiteDocument doc,
  ) async {
    final formKey = GlobalKey<FormState>();
    final fileNameController = TextEditingController(text: doc.fileName);
    final descriptionController = TextEditingController(
      text: doc.description ?? '',
    );

    final edited = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          title: Text(
            'Edit Document Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: fileNameController,
                    decoration: const InputDecoration(
                      labelText: 'File Name *',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'File Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Details',
                      prefixIcon: Icon(Icons.description_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    if (edited == true && context.mounted) {
      try {
        final updatedDoc = SiteDocument(
          id: doc.id,
          siteId: doc.siteId,
          createdBy: doc.createdBy,
          fileName: fileNameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          fileUrl: doc.fileUrl,
          createdAt: doc.createdAt,
          updatedAt: DateTime.now(),
        );

        await ref
            .read(siteDocumentsProvider(widget.siteId).notifier)
            .editDocument(updatedDoc);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document updated successfully'),
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
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

  Widget _analyticsProgressBar(String label, String value, double percentage) {
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
