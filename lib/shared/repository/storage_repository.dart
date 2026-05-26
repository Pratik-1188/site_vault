import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:site_vault/shared/repository/base_repository.dart';

/// A shared repository managing raw file uploads and asset management
/// inside Supabase Storage buckets, cross-platform friendly (Uint8List).
class StorageRepository extends BaseRepository {
  StorageRepository(super.client);

  /// Uploads raw file bytes to a specific bucket and path, returning its public url
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
  }) {
    return safeCall('StorageRepository.uploadFile', () async {
      final cleanPath = path.endsWith('/') ? path : '$path/';
      final storagePath = '$cleanPath${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await client.storage.from(bucket).uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              cacheControl: '3600',
            ),
          );

      return '$bucket/$storagePath';
    });
  }

  /// Generates a signed URL for a given absolute storage path (bucket/path)
  /// that is valid for the specified duration (default: 1 hour).
  Future<String> getSignedUrl({
    required String absolutePath,
    int expiresIn = 3600,
  }) {
    return safeCall('StorageRepository.getSignedUrl', () async {
      final parts = absolutePath.split('/');
      if (parts.length < 2) {
        throw ArgumentError('Invalid absolute storage path: $absolutePath');
      }
      final bucket = parts[0];
      final path = parts.sublist(1).join('/');
      return await client.storage.from(bucket).createSignedUrl(path, expiresIn);
    });
  }

  /// Deletes a file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String fileUrl,
  }) {
    return safeCall('StorageRepository.deleteFile', () async {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      // The path typically follows: /storage/v1/object/public/bucket-name/relative-path
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final relativePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await client.storage.from(bucket).remove([relativePath]);
      }
    });
  }
}
