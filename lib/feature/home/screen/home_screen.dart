import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:site_vault/feature/home/provider/home_provider.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import 'package:site_vault/feature/expense/screen/expense_form_sheet.dart';
import 'package:site_vault/feature/document/screen/document_upload_sheet.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/widget/vault_card.dart';

/// A premium, M3-styled Operations Dashboard representing the master corporate ledger overview.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Confirms and handles user sign out
  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of KK Group Site Vault?'),
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

  /// Opens the dynamic expense form bottom sheet in unlocked mode
  void _openExpenseFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExpenseFormSheet(
        siteId: '',
        firmId: '',
      ),
    );
  }

  /// Opens the dynamic document upload bottom sheet in unlocked mode
  void _openDocumentUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DocumentUploadSheet(
        siteId: '',
        firmId: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenseAsync = ref.watch(currentFinancialYearExpenseTotalProvider);
    final activeSitesAsync = ref.watch(activeSitesForCurrentFinancialYearProvider);
    final missingBillsAsync = ref.watch(missingBillExpenseTotalForCurrentFinancialYearProvider);
    final recentLogsAsync = ref.watch(recentAuditLogsProvider);

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
                  Icons.factory_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  // Placeholder brand feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('KK Group Operations Hub v1.0'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              title: Text(
                'KK Group Ledger',
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
                          Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
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
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentFinancialYearExpenseTotalProvider);
            ref.invalidate(activeSitesForCurrentFinancialYearProvider);
            ref.invalidate(missingBillExpenseTotalForCurrentFinancialYearProvider);
            ref.invalidate(recentAuditLogsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 1. Bento Metric Grid Header
              Text(
                'Current Year Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Bento Metric Grid Layout
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              top: -10,
                              child: Opacity(
                                opacity: 0.1,
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 80,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL EXPENSE',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                totalExpenseAsync.when(
                                  loading: () => const SizedBox(
                                    height: 38,
                                    width: 100,
                                    child: Center(
                                      child: LinearProgressIndicator(),
                                    ),
                                  ),
                                  error: (err, _) => Text(
                                    '₹--',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  data: (sum) => Text(
                                    '₹${sum.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                ],
              ),
              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Sites Card
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Active Sites',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            activeSitesAsync.when(
                              loading: () => const SizedBox(
                                height: 28,
                                width: 50,
                                child: Center(
                                  child: LinearProgressIndicator(),
                                ),
                              ),
                              error: (e, _) => const Text('--'),
                              data: (count) => Text(
                                '$count',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Missing Bills Sum Card (Amber alerts container scheme)
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: const Color(0xFFFFF8E1), // Light amber fill for warning indicator
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color(0xFFFFE082),
                        ),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.description_rounded,
                                  size: 20,
                                  color: Color(0xFFE65100),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Missing Bills',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            missingBillsAsync.when(
                              loading: () => const SizedBox(
                                height: 28,
                                width: 50,
                                child: Center(
                                  child: LinearProgressIndicator(),
                                ),
                              ),
                              error: (e, _) => const Text('--'),
                              data: (sum) => Text(
                                '₹${sum.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Log New Expense
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: InkWell(
                        borderRadius: AppRadius.brSm,
                        onTap: () => _openExpenseFormSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                child: Icon(
                                  Icons.payments_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Log New\nExpense',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Add Document Placeholder Card
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: InkWell(
                        borderRadius: AppRadius.brSm,
                        onTap: () => _openDocumentUploadSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                child: Icon(
                                  Icons.cloud_upload_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Document',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Recent Logs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Logs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Auditing ledger view is already complete in logs.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('VIEW ALL'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              recentLogsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading logs: $err'),
                ),
                data: (logs) {
                  if (logs.isEmpty) {
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: AppRadius.brXs,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No recent log transactions recorded.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: logs.map((log) {
                      final tableName = log['table_name'] as String? ?? '';
                      final operation = log['operation'] as String? ?? '';
                      final createdAt = log['created_at'] != null
                          ? DateTime.parse(log['created_at'])
                          : DateTime.now();

                      // Map operations & tables to distinct, relevant M3 icons & styling
                      IconData logIcon;
                      Color logIconColor;
                      Color logBgColor;
                      String logTitle;
                      String? logSubtitle;

                      if (tableName == 'expenses') {
                        logIcon = Icons.currency_rupee_rounded;
                        logIconColor = const Color(0xFF1565C0);
                        logBgColor = const Color(0xFFE3F2FD);
                        
                        final newData = log['new_data'] as Map<String, dynamic>?;
                        final expenseTitle = newData?['title'] as String? ?? 'Expense Logged';
                        final amount = newData?['amount'] as num? ?? 0.0;
                        
                        logTitle = 'Expense: $expenseTitle';
                        logSubtitle = 'Amount: ₹${amount.toStringAsFixed(2)}';
                      } else if (tableName == 'sites') {
                        logIcon = Icons.location_on_rounded;
                        logIconColor = const Color(0xFF2E7D32);
                        logBgColor = const Color(0xFFE8F5E9);

                        final newData = log['new_data'] as Map<String, dynamic>?;
                        final siteName = newData?['name'] as String? ?? 'Site Created';
                        final status = newData?['status'] as String? ?? 'active';

                        logTitle = 'Site: $siteName';
                        logSubtitle = 'Status: ${status.toUpperCase()}';
                      } else {
                        logIcon = Icons.info_outline_rounded;
                        logIconColor = Theme.of(context).colorScheme.primary;
                        logBgColor = Theme.of(context).colorScheme.surfaceContainer;
                        
                        logTitle = '${operation.toUpperCase()} on ${tableName.toUpperCase()}';
                        logSubtitle = null;
                      }

                      final changedByProfile = log['changed_by_profile'] as Map<String, dynamic>?;
                      final creatorName = changedByProfile?['display_name'] as String?;

                      return VaultCard(
                        creatorName: creatorName,
                        createdAt: createdAt,
                        onTap: null, // Logs can not be edited and they should not be clickable
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: logBgColor,
                            borderRadius: AppRadius.brXs,
                          ),
                          child: Icon(
                            logIcon,
                            color: logIconColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          logTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: logSubtitle != null
                            ? Text(
                                logSubtitle,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              )
                            : null,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 80), // Offset scroll container to prevent bottom bar overlap
            ],
          ),
        ),
      ),
    ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.go('/sites');
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
}
