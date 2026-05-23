import 'package:site_vault/feature/site/model/site.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SiteRepository {
  final SupabaseClient _client;

  SiteRepository(this._client);

  /// Fetches all sites from database ordered by latest created
  Future<List<Site>> fetchSites() async {
    try {
      // ignore: avoid_print
      print('Fetching sites from Supabase...');
      
      final response = await _client
          .from('sites')
          .select()
          .order('created_at', ascending: false);

      // ignore: avoid_print
      print('Supabase select response: $response (type: ${response.runtimeType})');

      return (response as List).map((e) => Site.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchSites: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }
}
