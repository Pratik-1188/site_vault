import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A shared repository managing raw file uploads and assets management
/// inside Supabase Storage buckets, cross-platform friendly (Uint8List).
class StorageRepository {
  final SupabaseClient _client;

  StorageRepository(this._client);

  /// Uploads raw file bytes to a specific bucket and path, returning its public url
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      final cleanPath = path.endsWith('/') ? path : '$path/';
      final storagePath = '$cleanPath${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Perform binary upload to bucket
      await _client.storage.from(bucket).uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              cacheControl: '3600',
            ),
          );

      // Return public url
      return _client.storage.from(bucket).getPublicUrl(storagePath);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in StorageRepository.uploadFile: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Deletes a file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String fileUrl,
  }) async {
    try {
      // Extract the relative storage path from the public URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      // The path typically follows: /storage/v1/object/public/bucket-name/relative-path
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final relativePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(bucket).remove([relativePath]);
      }
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in StorageRepository.deleteFile: $e');
      // ignore: avoid_print
      print(stack);
    }
  }
}
