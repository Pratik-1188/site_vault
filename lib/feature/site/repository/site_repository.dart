import 'package:site_vault/feature/site/model/site.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SiteRepository {
  final SupabaseClient _client;

  SiteRepository(this._client);

  /// Fetches all sites from database ordered by latest created
  Future<List<Site>> fetchSites() async {
    final response = await _client
        .from('sites')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => Site.fromJson(e)).toList();
  }
}
