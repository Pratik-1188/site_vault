import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:site_vault/feature/document/model/document.dart';
import 'package:site_vault/feature/document/repository/document_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'document_provider.g.dart';

/// Provides DocumentRepository singleton
@Riverpod(keepAlive: true)
DocumentRepository documentRepository(Ref ref) {
  final client = Supabase.instance.client;
  return DocumentRepository(client);
}

/// Active text search query for filtering documents
@riverpod
class DocumentSearchQuery extends _$DocumentSearchQuery {
  @override
  String build() => "";

  void update(String value) => state = value;
}

/// Async controller for managing all active site-specific document records.
///
/// Implements database read, write, and soft-delete operations
/// while reactively notifying dependent widgets.
@riverpod
class SiteDocuments extends _$SiteDocuments {
  @override
  Future<List<SiteDocument>> build(String siteId) async {
    final repo = ref.watch(documentRepositoryProvider);
    return repo.fetchDocumentsForSite(siteId);
  }

  /// Refreshes the site documents list from database
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(documentRepositoryProvider);
      return repo.fetchDocumentsForSite(siteId);
    });
  }

  /// Adds a new site document and reactively invalidates cache
  Future<void> addDocument(SiteDocument document) async {
    final repo = ref.read(documentRepositoryProvider);
    await repo.createDocument(document);
    ref.invalidateSelf(); // Reactively refetches updated files
  }

  /// Soft deletes a document and reactively invalidates cache
  Future<void> deleteDocument(String documentId) async {
    final repo = ref.read(documentRepositoryProvider);
    await repo.softDeleteDocument(documentId);
    ref.invalidateSelf(); // Reactively refetches updated files
  }

  /// Edits an existing document and reactively invalidates cache
  Future<void> editDocument(SiteDocument document) async {
    final repo = ref.read(documentRepositoryProvider);
    await repo.updateDocument(document);
    ref.invalidateSelf(); // Reactively refetches updated files
  }
}

/// Filtered site documents selector combining raw list with active filename searches
@riverpod
Future<List<SiteDocument>> filteredSiteDocuments(Ref ref, String siteId) async {
  final documents = await ref.watch(siteDocumentsProvider(siteId).future);
  final searchQuery = ref.watch(documentSearchQueryProvider);

  // Unused parameters listener (compliant with unnecessary_underscores)
  ref.listen(documentSearchQueryProvider, (previous, current) {});

  final query = searchQuery.toLowerCase().trim();
  if (query.isEmpty) return documents;

  return documents.where((doc) {
    final matchesName = doc.fileName.toLowerCase().contains(query);
    final matchesDesc = doc.description?.toLowerCase().contains(query) ?? false;
    return matchesName || matchesDesc;
  }).toList();
}
