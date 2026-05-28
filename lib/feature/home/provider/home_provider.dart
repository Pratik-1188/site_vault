import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/home/repository/home_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'home_provider.g.dart';

/// Provides the HomeRepository instance.
@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) {
  final client = Supabase.instance.client;
  return HomeRepository(client);
}

/// Provides total expenses for the current financial year.
@riverpod
Future<double> currentFinancialYearExpenseTotal(Ref ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchCurrentMonthExpenseTotal();
}

/// Provides count of active sites in the current financial year.
@riverpod
Future<int> activeSitesForCurrentFinancialYear(Ref ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchActiveSitesForCurrentFinancialYear();
}

/// Provides sum of expenses with missing bill attachments in the current financial year.
@riverpod
Future<double> missingBillExpenseTotalForCurrentFinancialYear(Ref ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchMissingBillExpensesForCurrentFinancialYear();
}

/// Provides latest 4 audit log entries.
@riverpod
Future<List<Map<String, dynamic>>> recentAuditLogs(Ref ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchRecentAuditLogs();
}
