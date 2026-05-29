import 'package:site_vault/shared/repository/base_repository.dart';
import '../model/document.dart';

/// Database repository managing Supabase queries for the Document vault feature.
class DocumentRepository extends BaseRepository {
  DocumentRepository(super.client);

  /// Fetches all active (non-soft-deleted) documents for a specific site.
  /// Joins the uploader's user profile dynamically.
  Future<List<SiteDocument>> fetchDocumentsForSite(String siteId) {
    return safeCall('DocumentRepository.fetchDocumentsForSite', () async {
      final response = await client
          .from('documents')
          .select('*, profiles(*)')
          .eq('site_id', siteId)
          .isFilter('soft_deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List).map((e) => SiteDocument.fromJson(e)).toList();
    });
  }

  /// Inserts a new document row in the database.
  Future<SiteDocument> createDocument(SiteDocument document) {
    return safeCall('DocumentRepository.createDocument', () async {
      final data = document.toInsertJson();

      final response = await client
          .from('documents')
          .insert(data)
          .select('*, profiles(*)')
          .single();

      return SiteDocument.fromJson(response);
    });
  }

  /// Soft deletes a document record by updating its [soft_deleted_at] timestamp to NOW.
  Future<void> softDeleteDocument(String documentId) {
    return safeCall('DocumentRepository.softDeleteDocument', () async {
      await client
          .from('documents')
          .update({
            'soft_deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', documentId);
    });
  }

  /// Updates the metadata (file_name, description) of a document record.
  Future<SiteDocument> updateDocument(SiteDocument document) {
    return safeCall('DocumentRepository.updateDocument', () async {
      final response = await client
          .from('documents')
          .update({
            'file_name': document.fileName,
            'description': document.description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', document.id)
          .select('*, profiles(*)')
          .single();

      return SiteDocument.fromJson(response);
    });
  }
}
