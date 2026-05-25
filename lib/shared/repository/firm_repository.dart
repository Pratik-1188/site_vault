import 'package:site_vault/shared/repository/base_repository.dart';
import '../model/firm.dart';

class FirmRepository extends BaseRepository {
  FirmRepository(super.client);

  /// Fetch all firms ordered by name
  Future<List<Firm>> fetchFirms() {
    return safeCall('FirmRepository.fetchFirms', () async {
      final response = await client
          .from('firms')
          .select()
          .order('name', ascending: true);

      return (response as List).map((e) => Firm.fromJson(e)).toList();
    });
  }
}
