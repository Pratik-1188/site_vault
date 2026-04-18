import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_vault/shared/model/firm.dart';
import 'package:site_vault/shared/repository/firm_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides FirmRepository
final firmRepositoryProvider = Provider<FirmRepository>((ref) {
  final client = Supabase.instance.client;
  return FirmRepository(client);
});

/// Fetches all firms
final firmsProvider = FutureProvider<List<Firm>>((ref) async {
  final repo = ref.read(firmRepositoryProvider);
  return repo.fetchFirms();
});
