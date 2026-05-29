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
