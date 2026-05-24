import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:site_vault/feature/analytics/model/analytics_models.dart';
import 'package:site_vault/feature/analytics/provider/analytics_provider.dart';
import 'package:site_vault/shared/theme/firm_colors.dart';

/// Central analytics hub screen showing Group (All Firms) and Firm comparative cost statistics.
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  int _selectedScopeIndex = 0; // 0: All Firms, 1: KK Electricals, 2: KK Solar, 3: KK Associates

  // Master Firm UUID constants matching migrations exactly
  static const String _firmElectricals = '0f140f6f-d994-4695-a838-bee13b3802f1';
  static const String _firmSolar = '4e01a36a-87c0-4cca-9428-a2747a130c96';
  static const String _firmAssociates = '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3';

  String? _getFirmIdForIndex(int index) {
    switch (index) {
      case 1:
        return _firmElectricals;
      case 2:
        return _firmSolar;
      case 3:
        return _firmAssociates;
      case 0:
      default:
        return null; // All Firms
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFirmId = _getFirmIdForIndex(_selectedScopeIndex);

    // Watch pre-aggregated queries
    final summariesAsync = ref.watch(groupFirmSummariesProvider);
    final categorySpendAsync = ref.watch(categorySpendProvider(firmId: selectedFirmId));
    final monthlySpendAsync = ref.watch(monthlySpendProvider(firmId: selectedFirmId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Executive Analytics'),
      ),
      body: Column(
        children: [
          // Scope Toggle Selector
          _buildScopeSelector(),

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
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    // 1. KPI Cards Grid
                    _buildKPIGrid(totalSpend, totalGst, totalBase, totalCount),
                    const SizedBox(height: 24),

                    // 2. Proportional Brand Splits (Only visible in All-Firms mode)
                    if (selectedFirmId == null) ...[
                      _buildFirmSplitsChart(firmSummaries),
                      const SizedBox(height: 24),
                    ],

                    // 3. Category Spending progress meters
                    _buildCategoryDistribution(categorySpendAsync),
                    const SizedBox(height: 24),

                    // 4. Monthly Trend Chronological Timeline
                    _buildMonthlyTrendsTimeline(monthlySpendAsync),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Segmented Sliding Scope controller
  Widget _buildScopeSelector() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scopes = ['All Firms', 'Electricals', 'Solar', 'Associates'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(scopes.length, (index) {
          final isSelected = _selectedScopeIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedScopeIndex = index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode ? const Color(0xFF334155) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected && !isDarkMode
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  scopes[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDarkMode ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Grid displaying computed aggregated totals
  Widget _buildKPIGrid(double total, double gst, double base, int count) {
    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final accentColor = _selectedScopeIndex == 0
        ? Theme.of(context).colorScheme.primary
        : firmColors.getFirmColor(_getFirmIdForIndex(_selectedScopeIndex)!);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                Icon(icon, size: 16, color: accentColor),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: value.length > 12 ? 14 : 16,
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
  Widget _buildFirmSplitsChart(List<FirmAnalyticsSummary> summaries) {
    final firmColors = Theme.of(context).extension<FirmColors>()!;

    double totalElectricals = 0.0;
    double totalSolar = 0.0;
    double totalAssociates = 0.0;

    for (final s in summaries) {
      switch (s.firmId.toLowerCase()) {
        case _firmElectricals:
          totalElectricals = s.totalSpend;
          break;
        case _firmSolar:
          totalSolar = s.totalSpend;
          break;
        case _firmAssociates:
          totalAssociates = s.totalSpend;
          break;
      }
    }

    final overall = totalElectricals + totalSolar + totalAssociates;
    if (overall <= 0) return const SizedBox.shrink();

    final pctElec = totalElectricals / overall;
    final pctSolar = totalSolar / overall;
    final pctAssoc = totalAssociates / overall;

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

            // Segmented proportional M3 progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (pctElec > 0)
                      Expanded(flex: (pctElec * 100).toInt(), child: Container(color: firmColors.electricals)),
                    if (pctSolar > 0)
                      Expanded(flex: (pctSolar * 100).toInt(), child: Container(color: firmColors.solar)),
                    if (pctAssoc > 0)
                      Expanded(flex: (pctAssoc * 100).toInt(), child: Container(color: firmColors.associates)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Legend indicators
            _legendRow('KK Electricals', '₹${totalElectricals.toStringAsFixed(2)}', '${(pctElec * 100).toInt()}%', firmColors.electricals),
            const Divider(height: 16, thickness: 0.5),
            _legendRow('KK Solar', '₹${totalSolar.toStringAsFixed(2)}', '${(pctSolar * 100).toInt()}%', firmColors.solar),
            const Divider(height: 16, thickness: 0.5),
            _legendRow('KK Associates', '₹${totalAssociates.toStringAsFixed(2)}', '${(pctAssoc * 100).toInt()}%', firmColors.associates),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(String label, String value, String percent, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  /// Categories Spend progress indicators
  Widget _buildCategoryDistribution(AsyncValue<List<CategorySpendSummary>> categorySpendAsync) {
    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final accentColor = _selectedScopeIndex == 0
        ? Theme.of(context).colorScheme.primary
        : firmColors.getFirmColor(_getFirmIdForIndex(_selectedScopeIndex)!);

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
                              Text('₹${entry.value.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 6,
                              backgroundColor: accentColor.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation(accentColor),
                            ),
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
    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final accentColor = _selectedScopeIndex == 0
        ? Theme.of(context).colorScheme.primary
        : firmColors.getFirmColor(_getFirmIdForIndex(_selectedScopeIndex)!);

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
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Container(
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: ratio.clamp(0.02, 1.0),
                                  child: Container(
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border(left: BorderSide(color: accentColor, width: 3)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    '₹${item.value.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
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
}
