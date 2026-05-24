import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/analytics/model/analytics_models.dart';
import 'package:site_vault/feature/analytics/repository/analytics_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'analytics_provider.g.dart';

/// Provides the AnalyticsRepository instance.
@Riverpod(keepAlive: true)
AnalyticsRepository analyticsRepository(Ref ref) {
  final client = Supabase.instance.client;
  return AnalyticsRepository(client);
}

/// Provides a list of pre-aggregated firm summaries (Group-wide comparative totals).
@riverpod
Future<List<FirmAnalyticsSummary>> groupFirmSummaries(Ref ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.fetchFirmSummaries();
}

/// Provides a single pre-aggregated site summary (total spent, GST split, etc.).
@riverpod
Future<SiteAnalyticsSummary?> siteSummary(Ref ref, String siteId) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.fetchSiteSummary(siteId);
}

/// Provides pre-aggregated category spending splits (supports optional filters by site or firm).
@riverpod
Future<List<CategorySpendSummary>> categorySpend(
  Ref ref, {
  String? siteId,
  String? firmId,
}) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.fetchCategorySpend(siteId: siteId, firmId: firmId);
}

/// Provides pre-aggregated chronological monthly cashflow trends.
@riverpod
Future<List<MonthlySpendTrend>> monthlySpend(
  Ref ref, {
  String? siteId,
  String? firmId,
}) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.fetchMonthlySpend(siteId: siteId, firmId: firmId);
}

/// Provides site-specific pre-aggregated vendor spending splits.
@riverpod
Future<List<VendorSpendSummary>> siteVendorSpend(Ref ref, String siteId) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.fetchVendorSpend(siteId);
}
