import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/shared/repository/base_repository.dart';

class SiteRepository extends BaseRepository {
  SiteRepository(super.client);

  /// Fetches all sites from database ordered by latest created
  Future<List<Site>> fetchSites() {
    return safeCall('SiteRepository.fetchSites', () async {
      final response = await client
          .from('sites')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((e) => Site.fromJson(e)).toList();
    });
  }
}
