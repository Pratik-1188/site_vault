import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:site_vault/feature/analytics/model/analytics_models.dart';
import 'package:site_vault/feature/analytics/provider/analytics_provider.dart';

import '../model/site.dart';
import 'package:site_vault/shared/widget/async_value_widget.dart';
import 'package:site_vault/shared/utils/number_formatter.dart';

class AnalyticsTab extends ConsumerWidget {
  final Site site;
  final Color baseColor;

  const AnalyticsTab({super.key, required this.site, required this.baseColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Cost breakdown by business expense categories for this site.',
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          AsyncValueWidget(
            value: categorySpendAsync,
            errorMessage: 'Error loading category splits',
            data: (categories) {
              if (categories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No category splits recorded.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
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
                        context,
                        c.categoryName,
                        c.totalSpend.toCurrencySpan(
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        percentage,
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
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
          Text(
            'Monthly Spending Trends',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Timeline history of site spending aggregates.',
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          AsyncValueWidget(
            value: monthlySpendAsync,
            useLinearProgress: true,
            errorMessage: 'Error loading monthly trend',
            data: (trends) {
              if (trends.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No historical timelines found.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
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
                ..sort((a, b) => b.monthDate.compareTo(a.monthDate));

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
                                  Text.rich(
                                    item.totalSpend.toCurrencySpan(
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
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
          Text(
            'Top Suppliers Tally',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Ranked vendor splits representing top funding receivers on this site.',
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          AsyncValueWidget(
            value: vendorSpendAsync,
            useLinearProgress: true,
            errorMessage: 'Error loading vendor spend',
            data: (vendors) {
              if (vendors.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No suppliers recorded for this site.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                );
              }

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
                        trailing: Text.rich(
                          v.totalSpend.toCurrencySpan(
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
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

  Widget _analyticsProgressBar(BuildContext context, String label, dynamic value, double percentage) {
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
            if (value is InlineSpan)
              Text.rich(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              )
            else
              Text(
                value.toString(),
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
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}
