import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/shared/repository/base_repository.dart';

class SiteRepository extends BaseRepository {
  SiteRepository(super.client);

  /// Fetches sites for a specific firm within a date range with optional status and search filters.
  Future<List<Site>> fetchSites({
    required String firmId,
    required DateTime fromDate,
    required DateTime toDate,
    String? status,
    String? searchQuery,
  }) {
    return safeCall('SiteRepository.fetchSites', () async {
      var query = client.from('sites').select().eq('firm_id', firmId);

      // Format dates to YYYY-MM-DD to perform clean date-level comparisons
      final fromStr =
          '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';
      final toStr =
          '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}';

      query = query
          .gte('started_on', fromStr)
          .lte('started_on', toStr);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('name', '%${searchQuery.trim()}%');
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((e) => Site.fromJson(e)).toList();
    });
  }
}
