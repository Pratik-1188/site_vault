import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/repository/site_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'site_provider.g.dart';

/// Date range model
class DateRange {
  final DateTime? from;
  final DateTime? to;

  DateRange({this.from, this.to});
}

/// Provides SiteRepository
@Riverpod(keepAlive: true)
SiteRepository siteRepository(Ref ref) {
  final client = Supabase.instance.client;
  return SiteRepository(client);
}

/// Fetches all sites from DB
@riverpod
Future<List<Site>> sites(Ref ref) async {
  final repo = ref.watch(siteRepositoryProvider);
  return repo.fetchSites();
}

/// Selected firm filter (null = All)
@riverpod
class SelectedFirm extends _$SelectedFirm {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Selected status filter (null = All)
@riverpod
class SelectedStatus extends _$SelectedStatus {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

/// Started date range filter
@riverpod
class StartedDateRange extends _$StartedDateRange {
  @override
  DateRange build() => DateRange();

  void update(DateRange value) => state = value;
}

/// Search query for filtering sites by name (case-insensitive)
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => "";

  void update(String value) => state = value;
}

/// Visible count for pagination (infinite scroll)
@riverpod
class VisibleCount extends _$VisibleCount {
  @override
  int build() => 10;

  void update(int value) => state = value;

  void increment(int count) => state = state + count;
}

/// Combines data + filters + search and returns final list
@riverpod
Future<List<Site>> filteredSites(Ref ref) async {
  final sites = await ref.watch(sitesProvider.future);

  final selectedFirm = ref.watch(selectedFirmProvider);
  final selectedStatus = ref.watch(selectedStatusProvider);
  final dateRange = ref.watch(startedDateRangeProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  // Auto-reset pagination when filters change
  ref.listen(searchQueryProvider, (_, _) {
    ref.read(visibleCountProvider.notifier).update(10);
  });
  ref.listen(selectedFirmProvider, (_, _) {
    ref.read(visibleCountProvider.notifier).update(10);
  });
  ref.listen(selectedStatusProvider, (_, _) {
    ref.read(visibleCountProvider.notifier).update(10);
  });
  ref.listen(startedDateRangeProvider, (_, _) {
    ref.read(visibleCountProvider.notifier).update(10);
  });

  // Hoist search query transformation for efficiency
  final query = searchQuery.toLowerCase().trim();

  return sites.where((site) {
    if (selectedFirm != null && site.firmId != selectedFirm) return false;

    if (selectedStatus != null && site.status != selectedStatus) {
      return false;
    }

    // Date normalization: Strip time components for accurate day-level comparison
    if (dateRange.from != null || dateRange.to != null) {
      if (site.startedOn == null) return false;

      final siteDate = DateTime(
        site.startedOn!.year,
        site.startedOn!.month,
        site.startedOn!.day,
      );

      if (dateRange.from != null) {
        final fromDate = DateTime(
          dateRange.from!.year,
          dateRange.from!.month,
          dateRange.from!.day,
        );
        if (siteDate.isBefore(fromDate)) return false;
      }

      if (dateRange.to != null) {
        final toDate = DateTime(
          dateRange.to!.year,
          dateRange.to!.month,
          dateRange.to!.day,
        );
        if (siteDate.isAfter(toDate)) return false;
      }
    }

    // Apply case-insensitive hoisted search
    if (query.isNotEmpty) {
      if (!site.name.toLowerCase().contains(query)) {
        return false;
      }
    }

    return true;
  }).toList();
}

/// Slices the filtered sites for UI pagination
@riverpod
Future<List<Site>> paginatedSites(Ref ref) async {
  final filteredSites = await ref.watch(filteredSitesProvider.future);
  final visibleCount = ref.watch(visibleCountProvider);

  return filteredSites.take(visibleCount).toList();
}
