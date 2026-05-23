import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/storage_repository.dart';

part 'storage_provider.g.dart';

/// Provides StorageRepository singleton
@Riverpod(keepAlive: true)
StorageRepository storageRepository(Ref ref) {
  final client = Supabase.instance.client;
  return StorageRepository(client);
}
