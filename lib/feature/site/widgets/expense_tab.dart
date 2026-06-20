import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/feature/expense/provider/expense_provider.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/widget/custom_search_bar.dart';
import 'package:site_vault/shared/utils/number_formatter.dart';
import 'package:site_vault/shared/widget/vault_card.dart';
import 'package:site_vault/shared/widget/async_value_widget.dart';

import '../model/site.dart';

class ExpenseTab extends ConsumerStatefulWidget {
  final Site site;
  final void Function(
    BuildContext context,
    String siteId,
    String firmId,
    Expense? expense,
  )
  onOpenExpenseFormSheet;
  final void Function(BuildContext context, Expense expense)
  onShowExpenseDetail;
  final void Function(BuildContext context, String path, String title)
  onDownloadOrOpenDocument;
  final IconData Function(String? categoryName) getCategoryIcon;
  final void Function(BuildContext context, Expense expense)
  onConfirmDeleteExpense;

  const ExpenseTab({
    super.key,
    required this.site,
    required this.onOpenExpenseFormSheet,
    required this.onShowExpenseDetail,
    required this.onDownloadOrOpenDocument,
    required this.getCategoryIcon,
    required this.onConfirmDeleteExpense,
  });

  @override
  ConsumerState<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends ConsumerState<ExpenseTab> {
  final TextEditingController _expenseSearchController =
      TextEditingController();

  @override
  void dispose() {
    _expenseSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(
      filteredSiteExpensesProvider(widget.site.id),
    );
    final totalAsync = ref.watch(siteTotalExpensesProvider(widget.site.id));
    final selectedCategory = ref.watch(expenseCategoryFilterProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AsyncValueWidget(
            value: totalAsync,
            loading: () => Container(
              height: 80,
              color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.1),
            ),
            errorMessage: 'Error loading total',
            data: (total) {
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 36,
                  ),
                  title: const Text(
                    'Total Expenses Spent',
                    style: TextStyle(fontSize: 12),
                  ),
                  subtitle: Text.rich(
                    total.toCurrencySpan(
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          CustomSearchBar(
            controller: _expenseSearchController,
            onChanged: (val) {
              ref.read(expenseSearchQueryProvider.notifier).update(val);
              setState(() {});
            },
            hintText: 'Search expenses by title...',
            showClearButton: _expenseSearchController.text.isNotEmpty,
            onClear: () {
              _expenseSearchController.clear();
              ref.read(expenseSearchQueryProvider.notifier).update('');
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          AsyncValueWidget(
            value: categoriesAsync,
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
          Expanded(
            child: AsyncValueWidget(
              value: expensesAsync,
              errorMessage: 'Error loading expenses',
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
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Expenses Recorded',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add transaction records for this site by clicking the "+" button below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
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
                    return VaultCard(
                      creatorName: expense.createdByProfile?.displayName,
                      createdAt: expense.createdAt,
                      onTap: () => widget.onShowExpenseDetail(context, expense),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          widget.getCategoryIcon(expense.category?.name),
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
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
                          if (expense.isGst) ...[
                            const SizedBox(height: 4),
                            const Chip(
                              avatar: Icon(
                                Icons.receipt_rounded,
                                size: 12,
                              ),
                              label: Text(
                                'GST Bill',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (expense.attachmentPath != null &&
                              expense.attachmentPath!.isNotEmpty) ...[
                            IconButton(
                              icon: Icon(
                                Icons.description_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              tooltip: 'View Attachment',
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                widget.onDownloadOrOpenDocument(
                                  context,
                                  expense.attachmentPath!,
                                  expense.title,
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text.rich(
                            expense.amount.toCurrencySpan(
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.site.status == 'active')
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                              ),
                              splashRadius: 20,
                              onSelected: (action) {
                                if (action == 'edit') {
                                  widget.onOpenExpenseFormSheet(
                                    context,
                                    widget.site.id,
                                    widget.site.firmId,
                                    expense,
                                  );
                                } else if (action == 'delete') {
                                  widget.onConfirmDeleteExpense(
                                    context,
                                    expense,
                                  );
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
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
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


}
