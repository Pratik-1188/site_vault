import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/shared/model/firm.dart';
import 'package:site_vault/shared/repository/firm_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'firm_provider.g.dart';

/// Provides FirmRepository
@Riverpod(keepAlive: true)
FirmRepository firmRepository(Ref ref) {
  final client = Supabase.instance.client;
  return FirmRepository(client);
}

/// Fetches all firms
@riverpod
Future<List<Firm>> firms(Ref ref) async {
  final repo = ref.watch(firmRepositoryProvider);
  return repo.fetchFirms();
}

