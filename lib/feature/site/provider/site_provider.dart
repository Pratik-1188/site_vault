import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/site/repository/site_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides SiteRepository
final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  final client = Supabase.instance.client;
  return SiteRepository(client);
});

/// Fetches all sites from DB
final sitesProvider = FutureProvider<List<Site>>((ref) async {
  final repo = ref.read(siteRepositoryProvider);
  return repo.fetchSites();
});

/// Selected firm filter (null = All)
final selectedFirmProvider = StateProvider<String?>((ref) => null);

/// Selected status filter (null = All)
final selectedStatusProvider = StateProvider<String?>((ref) => null);

/// Date range model
class DateRange {
  final DateTime? from;
  final DateTime? to;

  DateRange({this.from, this.to});
}

/// Started date range filter
final startedDateRangeProvider = StateProvider<DateRange>((ref) => DateRange());

/// Search query for filtering sites by name (case-insensitive)
final searchQueryProvider = StateProvider<String>((ref) => "");

/// Combines data + filters + search and returns final list
final filteredSitesProvider = Provider<AsyncValue<List<Site>>>((ref) {
  final sitesAsync = ref.watch(sitesProvider);

  final selectedFirm = ref.watch(selectedFirmProvider);
  final selectedStatus = ref.watch(selectedStatusProvider);
  final dateRange = ref.watch(startedDateRangeProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return sitesAsync.whenData((sites) {
    return sites.where((site) {
      if (selectedFirm != null && site.firmId != selectedFirm) return false;

      if (selectedStatus != null && site.status != selectedStatus) {
        return false;
      }

      if (dateRange.from != null) {
        if (site.startedOn == null ||
            site.startedOn!.isBefore(dateRange.from!)) {
          return false;
        }
      }

      if (dateRange.to != null) {
        if (site.startedOn == null || site.startedOn!.isAfter(dateRange.to!)) {
          return false;
        }
      }

      // Apply case-insensitive search
      if (searchQuery.isNotEmpty) {
        if (!site.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});

/// Visible count for pagination (infinite scroll)
final visibleCountProvider = StateProvider<int>((ref) => 10);

/// Slices the filtered sites for UI pagination
final paginatedSitesProvider = Provider<AsyncValue<List<Site>>>((ref) {
  final filteredSitesAsync = ref.watch(filteredSitesProvider);
  final visibleCount = ref.watch(visibleCountProvider);

  return filteredSitesAsync.whenData((sites) {
    return sites.take(visibleCount).toList();
  });
});
