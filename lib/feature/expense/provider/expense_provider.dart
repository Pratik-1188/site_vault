import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/feature/expense/repository/expense_repository.dart';
import 'package:site_vault/shared/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'expense_provider.g.dart';

/// Provides ExpenseRepository singleton
@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) {
  final client = Supabase.instance.client;
  return ExpenseRepository(client);
}

/// Dynamic categories list fetch from database
@riverpod
Future<List<ExpenseCategory>> expenseCategories(Ref ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.fetchCategories();
}

/// Dynamic vendors list fetch from database
@riverpod
Future<List<Vendor>> vendors(Ref ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.fetchVendors();
}

/// Dynamic user profiles list fetch from database (for created_by & paid_by linking)
@riverpod
Future<List<Profile>> profiles(Ref ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.fetchProfiles();
}

/// Selected category filter (null = All)
@riverpod
class ExpenseCategoryFilter extends _$ExpenseCategoryFilter {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected vendor filter (null = All)
@riverpod
class ExpenseVendorFilter extends _$ExpenseVendorFilter {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Active text search query filter
@riverpod
class ExpenseSearchQuery extends _$ExpenseSearchQuery {
  @override
  String build() => "";

  void update(String value) => state = value;
}

/// Async controller for managing all active site-specific expenses.
///
/// Implements database read, write, update, and soft-delete operations
/// while reactively notifying dependent widgets.
@riverpod
class SiteExpenses extends _$SiteExpenses {
  @override
  Future<List<Expense>> build(String siteId) async {
    final repo = ref.watch(expenseRepositoryProvider);
    return repo.fetchExpensesForSite(siteId);
  }

  /// Refreshes the site expenses list from database
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(expenseRepositoryProvider);
      return repo.fetchExpensesForSite(siteId);
    });
  }

  /// Adds a new expense row in Supabase and reactively invalidates cache
  Future<void> addExpense(Expense expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.createExpense(expense);
    ref.invalidateSelf(); // Reactively refetches updated entries
  }

  /// Updates an existing expense row in Supabase and reactively invalidates cache
  Future<void> editExpense(Expense expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.updateExpense(expense);
    ref.invalidateSelf(); // Reactively refetches updated entries
  }

  /// Soft deletes an expense by setting soft_deleted_at to NOW and reactively invalidates cache
  Future<void> deleteExpense(String expenseId) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.softDeleteExpense(expenseId);
    ref.invalidateSelf(); // Reactively refetches updated entries
  }
}

/// Filtered expenses selector combining data lists with active searches and tags
@riverpod
Future<List<Expense>> filteredSiteExpenses(Ref ref, String siteId) async {
  final expenses = await ref.watch(siteExpensesProvider(siteId).future);
  
  final searchQuery = ref.watch(expenseSearchQueryProvider);
  final categoryFilter = ref.watch(expenseCategoryFilterProvider);
  final vendorFilter = ref.watch(expenseVendorFilterProvider);

  // Auto-reset filters if main query parameters change (optional convention)
  ref.listen(expenseSearchQueryProvider, (previous, current) {});
  ref.listen(expenseCategoryFilterProvider, (previous, current) {});
  ref.listen(expenseVendorFilterProvider, (previous, current) {});

  final query = searchQuery.toLowerCase().trim();

  return expenses.where((expense) {
    if (categoryFilter != null && expense.categoryId != categoryFilter) {
      return false;
    }
    
    if (vendorFilter != null && expense.vendorId != vendorFilter) {
      return false;
    }

    if (query.isNotEmpty) {
      final matchesTitle = expense.title.toLowerCase().contains(query);
      final matchesDesc = expense.description?.toLowerCase().contains(query) ?? false;
      if (!matchesTitle && !matchesDesc) {
        return false;
      }
    }

    return true;
  }).toList();
}

/// Reactive aggregate summation calculator that watches the site's cached expenses list
/// and computes the total invoice sum in-memory for instant visual responsiveness.
@riverpod
Future<double> siteTotalExpenses(Ref ref, String siteId) async {
  final expenses = await ref.watch(siteExpensesProvider(siteId).future);
  return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
}
