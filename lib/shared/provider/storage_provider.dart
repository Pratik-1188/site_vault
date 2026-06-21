import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/storage_repository.dart';
import 'dart:typed_data';

part 'storage_provider.g.dart';

/// Provides StorageRepository singleton
@Riverpod(keepAlive: true)
StorageRepository _storageRepository(Ref ref) {
  final client = Supabase.instance.client;
  return StorageRepository(client);
}

/// Storage actions exposed to the UI through Riverpod.
class StorageActions {
  StorageActions(this.ref);
  final Ref ref;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
  }) {
    final repo = ref.read(_storageRepositoryProvider);
    return repo.uploadFile(
      bucket: bucket,
      path: path,
      fileBytes: fileBytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  Future<String> getSignedUrl({
    required String absolutePath,
    int expiresIn = 3600,
  }) {
    final repo = ref.read(_storageRepositoryProvider);
    return repo.getSignedUrl(
      absolutePath: absolutePath,
      expiresIn: expiresIn,
    );
  }

  Future<void> deleteFile({
    required String bucket,
    required String fileUrl,
  }) {
    final repo = ref.read(_storageRepositoryProvider);
    return repo.deleteFile(bucket: bucket, fileUrl: fileUrl);
  }
}

final storageActionsProvider = Provider<StorageActions>((ref) => StorageActions(ref));
