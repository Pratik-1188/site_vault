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

  /// Fetches a single site by its unique ID directly from Supabase.
  Future<Site> fetchSiteById(String siteId) {
    return safeCall('SiteRepository.fetchSiteById', () async {
      final response =
          await client.from('sites').select().eq('id', siteId).single();
      return Site.fromJson(response);
    });
  }

  /// Updates a site's details in Supabase.
  Future<Site> updateSite({
    required String siteId,
    required String name,
    String? description,
    required DateTime startedOn,
    required String status,
    DateTime? completedOn,
  }) {
    return safeCall('SiteRepository.updateSite', () async {
      final response = await client
          .from('sites')
          .update({
            'name': name,
            'description': description,
            'started_on': '${startedOn.year}-${startedOn.month.toString().padLeft(2, '0')}-${startedOn.day.toString().padLeft(2, '0')}',
            'status': status,
            'completed_on': completedOn != null
                ? '${completedOn.year}-${completedOn.month.toString().padLeft(2, '0')}-${completedOn.day.toString().padLeft(2, '0')}'
                : null,
          })
          .eq('id', siteId)
          .select()
          .single();
      return Site.fromJson(response);
    });
  }
}
