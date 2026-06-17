import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/repository/site_repository.dart';
import 'package:site_vault/shared/utils/financial_year.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'site_provider.g.dart';

/// Date range model with value equality implemented to prevent
/// unnecessary provider recalculations.
@immutable
class DateRange {
  final DateTime? from;
  final DateTime? to;

  const DateRange({this.from, this.to});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

/// Provides SiteRepository
@Riverpod(keepAlive: true)
SiteRepository siteRepository(Ref ref) {
  final client = Supabase.instance.client;
  return SiteRepository(client);
}

/// Selected firm filter (null = none selected on startup)
@riverpod
class SelectedFirm extends _$SelectedFirm {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected status filter (defaults to 'active')
@riverpod
class SelectedStatus extends _$SelectedStatus {
  @override
  String? build() => 'active';

  void update(String? value) => state = value;
}

/// Started date range filter (defaults to current financial year)
@riverpod
class StartedDateRange extends _$StartedDateRange {
  @override
  DateRange build() {
    final fy = FinancialYear.current();
    return DateRange(from: fy.startDate, to: fy.endDate);
  }

  void update(DateRange value) => state = value;
}

/// Search query for filtering sites by name (case-insensitive)
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => "";

  void update(String value) => state = value;
}

/// Fetches sites matching the current filters directly from Supabase (Server-side)
@riverpod
Future<List<Site>> sites(Ref ref) async {
  final repo = ref.watch(siteRepositoryProvider);
  final selectedFirm = ref.watch(selectedFirmProvider);
  final selectedStatus = ref.watch(selectedStatusProvider);
  final dateRange = ref.watch(startedDateRangeProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  // Return empty list if no firm is selected yet
  if (selectedFirm == null) {
    return const [];
  }

  // Ensure that start/end dates are present (fallback to current financial year limits)
  final fy = FinancialYear.current();
  final fromDate = dateRange.from ?? fy.startDate;
  final toDate = dateRange.to ?? fy.endDate;

  return repo.fetchSites(
    firmId: selectedFirm,
    fromDate: fromDate,
    toDate: toDate,
    status: selectedStatus,
    searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
  );
}

/// Fetches details for a single site by its unique ID
@riverpod
Future<Site> siteDetails(Ref ref, String siteId) async {
  final repo = ref.watch(siteRepositoryProvider);
  return repo.fetchSiteById(siteId);
}

/// Site write actions exposed through Riverpod so UI never touches the repository directly.
class SiteActions {
  SiteActions(this.ref);
  final Ref ref;

  Future<Site> updateSite({
    required String siteId,
    required String name,
    String? description,
    required DateTime startedOn,
    required String status,
    DateTime? completedOn,
  }) async {
    final repo = ref.read(siteRepositoryProvider);
    final updated = await repo.updateSite(
      siteId: siteId,
      name: name,
      description: description,
      startedOn: startedOn,
      status: status,
      completedOn: completedOn,
    );

    ref.invalidate(siteDetailsProvider(siteId));
    ref.invalidate(sitesProvider);

    return updated;
  }

  Future<Site> createSite({
    required String firmId,
    required String name,
    String? description,
    required DateTime startedOn,
    String status = 'active',
    DateTime? completedOn,
  }) async {
    final repo = ref.read(siteRepositoryProvider);
    final created = await repo.createSite(
      firmId: firmId,
      name: name,
      description: description,
      startedOn: startedOn,
      status: status,
      completedOn: completedOn,
    );

    // Invalidate sites list provider and specific active sites dropdown provider
    ref.invalidate(sitesProvider);
    ref.invalidate(activeSitesByFirmProvider(firmId));

    return created;
  }
}

final siteActionsProvider = Provider<SiteActions>((ref) => SiteActions(ref));

/// Fetches active sites for a specific firm to populate scoped dropdowns.
final activeSitesByFirmProvider = FutureProvider.family<List<Site>, String>(
  (ref, firmId) async {
    final repo = ref.watch(siteRepositoryProvider);
    return repo.fetchActiveSitesByFirm(firmId);
  },
);
