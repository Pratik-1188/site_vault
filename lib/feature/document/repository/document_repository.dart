import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/document.dart';

/// Database repository managing Supabase queries for the Document vault feature.
class DocumentRepository {
  final SupabaseClient _client;

  DocumentRepository(this._client);

  /// Fetches all active (non-soft-deleted) documents for a specific site.
  /// Joins the uploader's user profile dynamically.
  Future<List<SiteDocument>> fetchDocumentsForSite(String siteId) async {
    try {
      final response = await _client
          .from('documents')
          .select('*, profiles(*)')
          .eq('site_id', siteId)
          .isFilter('soft_deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List).map((e) => SiteDocument.fromJson(e)).toList();
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in fetchDocumentsForSite: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Inserts a new document row in the database.
  Future<SiteDocument> createDocument(SiteDocument document) async {
    try {
      final data = document.toJson();
      if (document.id.isEmpty) {
        data.remove('id');
      }

      final response = await _client
          .from('documents')
          .insert(data)
          .select('*, profiles(*)')
          .single();

      return SiteDocument.fromJson(response);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in createDocument: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  /// Soft deletes a document record by updating its [soft_deleted_at] timestamp to NOW.
  Future<void> softDeleteDocument(String documentId) async {
    try {
      await _client
          .from('documents')
          .update({
            'soft_deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', documentId);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error in softDeleteDocument: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }
}
