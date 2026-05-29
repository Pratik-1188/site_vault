import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:site_vault/feature/analytics/model/analytics_models.dart';
import 'package:site_vault/feature/analytics/provider/analytics_provider.dart';
import 'package:site_vault/shared/widget/button_group.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import 'package:site_vault/shared/model/firm.dart';
import 'package:site_vault/shared/provider/firm_provider.dart';

/// Central analytics hub screen showing Group (All Firms) and Firm comparative cost statistics.
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  String? _selectedFirmId; // null = All Firms

  String _cleanFirmName(String name) {
    if (name.toLowerCase().startsWith('kk ')) {
      return name.substring(3).trim();
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final selectedFirmId = _selectedFirmId;

    // Watch pre-aggregated queries
    final summariesAsync = ref.watch(groupFirmSummariesProvider);
    final categorySpendAsync = ref.watch(categorySpendProvider(firmId: selectedFirmId));
    final monthlySpendAsync = ref.watch(monthlySpendProvider(firmId: selectedFirmId));
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
                'Executive Analytics',
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
        body: Column(
          children: [
          // Scope Toggle Selector
          firmsAsync.when(
            data: (firmsList) => _buildScopeSelector(firmsList),
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

          Expanded(
            child: summariesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading dashboard: $e')),
              data: (firmSummaries) {
                // If All Firms, compute combined summary; otherwise select matching firm
                final activeSummaries = selectedFirmId == null
                     ? firmSummaries
                     : firmSummaries.where((s) => s.firmId.toLowerCase() == selectedFirmId.toLowerCase()).toList();

                if (firmSummaries.isEmpty) {
                  return const Center(child: Text('No transaction logs recorded.'));
                }

                double totalSpend = 0.0;
                double totalGst = 0.0;
                double totalBase = 0.0;
                int totalCount = 0;

                for (final sum in activeSummaries) {
                  totalSpend += sum.totalSpend;
                  totalGst += sum.totalGst;
                  totalBase += sum.totalBase;
                  totalCount += sum.expenseCount;
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  children: [
                    // 1. KPI Cards Grid
                    _buildKPIGrid(totalSpend, totalGst, totalBase, totalCount),
                    const SizedBox(height: 24),

                    // 2. Proportional Brand Splits (Only visible in All-Firms mode)
                    if (selectedFirmId == null) ...[
                      _buildFirmSplitsChart(firmSummaries, firmsAsync.value ?? const []),
                      const SizedBox(height: 24),
                    ],

                    // 3. Category Spending progress meters
                    _buildCategoryDistribution(categorySpendAsync),
                    const SizedBox(height: 24),

                    // 4. Monthly Trend Chronological Timeline
                    _buildMonthlyTrendsTimeline(monthlySpendAsync),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.go('/sites');
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

  /// Premium sliding ButtonGroup Scope selector
  Widget _buildScopeSelector(List<Firm> firms) {
    final options = [
      const ButtonGroupOption<String?>(value: null, label: 'All Firms'),
      ...firms.map((firm) => ButtonGroupOption<String?>(
            value: firm.id,
            label: _cleanFirmName(firm.name),
          )),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ButtonGroup<String?>(
        options: options,
        selectedValue: _selectedFirmId,
        onSelected: (String? newValue) {
          setState(() {
            _selectedFirmId = newValue;
          });
        },
      ),
    );
  }

  /// Grid displaying computed aggregated totals
  Widget _buildKPIGrid(double total, double gst, double base, int count) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _kpiCard('Total Spend', '₹${total.toStringAsFixed(2)}', Icons.payments_rounded, accentColor),
        _kpiCard('Tax Paid (GST)', '₹${gst.toStringAsFixed(2)}', Icons.receipt_long_rounded, Colors.blue),
        _kpiCard('Base Cost', '₹${base.toStringAsFixed(2)}', Icons.analytics_rounded, Colors.teal),
        _kpiCard('Transactions', '$count logs', Icons.inventory_2_outlined, Colors.purple),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color accentColor) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(icon, size: 18, color: accentColor),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Proportional Spend Brand Bar Chart
  Widget _buildFirmSplitsChart(List<FirmAnalyticsSummary> summaries, List<Firm> firms) {
    final overall = summaries.fold<double>(0.0, (sum, s) => sum + s.totalSpend);
    if (overall <= 0) return const SizedBox.shrink();

    final splits = firms.map((firm) {
      final summary = summaries.firstWhere(
        (s) => s.firmId.toLowerCase() == firm.id.toLowerCase(),
        orElse: () => FirmAnalyticsSummary(
          firmId: firm.id,
          totalSpend: 0.0,
          totalGst: 0.0,
          totalBase: 0.0,
          expenseCount: 0,
        ),
      );
      final percentage = overall > 0 ? summary.totalSpend / overall : 0.0;
      return _FirmSplitItem(
        name: firm.name,
        spend: summary.totalSpend,
        percentage: percentage,
      );
    }).toList();

    // Sort splits by spend descending
    splits.sort((a, b) => b.spend.compareTo(a.spend));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Firm Spend Split', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Spend proportional distribution across the divisions.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 20),
            ...splits.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (idx > 0) const Divider(height: 16, thickness: 0.5),
                  _legendRow(item.name, '₹${item.spend.toStringAsFixed(2)}', '${(item.percentage * 100).toInt()}%', item.percentage),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(String label, String value, String percent, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 12),
            Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: ratio),
      ],
    );
  }

  /// Categories Spend progress indicators
  Widget _buildCategoryDistribution(AsyncValue<List<CategorySpendSummary>> categorySpendAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operational Categories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Spend breakdown by expense category types.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 20),

            categorySpendAsync.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, _) => Text('Error category splits: $e'),
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('No category splits recorded.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  );
                }

                // Sum combined totals if multiple rows exist
                final consolidated = <String, double>{};
                double grandTotal = 0.0;
                for (final c in categories) {
                  consolidated[c.categoryName] = (consolidated[c.categoryName] ?? 0.0) + c.totalSpend;
                  grandTotal += c.totalSpend;
                }

                final sorted = consolidated.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: sorted.map((entry) {
                    final percentage = grandTotal > 0 ? entry.value / grandTotal : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('₹${entry.value.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: percentage,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Month-over-month Cashflow Timeline
  Widget _buildMonthlyTrendsTimeline(AsyncValue<List<MonthlySpendTrend>> monthlySpendAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cashflow Velocity', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Month-over-month aggregated spending trends.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 20),

            monthlySpendAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error timelines: $e'),
              data: (trends) {
                if (trends.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('No historical timelines found.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  );
                }

                // Consolidate identical months (if multiple firms returned)
                final consolidated = <DateTime, double>{};
                double maxVal = 0.0;
                for (final t in trends) {
                  consolidated[t.monthDate] = (consolidated[t.monthDate] ?? 0.0) + t.totalSpend;
                  if (consolidated[t.monthDate]! > maxVal) {
                    maxVal = consolidated[t.monthDate]!;
                  }
                }

                final sortedMonths = consolidated.entries.toList()
                  ..sort((a, b) => b.key.compareTo(a.key)); // Newest first

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedMonths.length,
                  itemBuilder: (context, index) {
                    final item = sortedMonths[index];
                    final dateStr = _formatMonthDate(item.key);
                    final ratio = maxVal > 0 ? item.value / maxVal : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          // 1. Date label
                          SizedBox(
                            width: 80,
                            child: Text(
                              dateStr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          
                          // 2. Velocity bar
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox.shrink(),
                                    Text(
                                      '₹${item.value.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
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
          ],
        ),
      ),
    );
  }

  String _formatMonthDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
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
}

class _FirmSplitItem {
  final String name;
  final double spend;
  final double percentage;

  _FirmSplitItem({
    required this.name,
    required this.spend,
    required this.percentage,
  });
}
