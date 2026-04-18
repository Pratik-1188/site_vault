import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/firm.dart';

class FirmRepository {
  final SupabaseClient _client;

  FirmRepository(this._client);

  /// Fetch all firms ordered by name
  Future<List<Firm>> fetchFirms() async {
    final response = await _client
        .from('firms')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => Firm.fromJson(e)).toList();
  }
}
