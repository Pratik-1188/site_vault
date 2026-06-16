import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:site_vault/feature/document/model/document.dart';
import 'package:site_vault/feature/document/provider/document_provider.dart';
import 'package:site_vault/shared/widget/custom_search_bar.dart';
import 'package:site_vault/shared/widget/vault_card.dart';

import '../model/site.dart';

class DocumentsTab extends ConsumerStatefulWidget {
  final Site site;
  final void Function(BuildContext context, String path, String title)
  onOpenDocument;
  final void Function(BuildContext context, SiteDocument doc) onEditDocument;
  final void Function(BuildContext context, SiteDocument doc) onDeleteDocument;

  const DocumentsTab({
    super.key,
    required this.site,
    required this.onOpenDocument,
    required this.onEditDocument,
    required this.onDeleteDocument,
  });

  @override
  ConsumerState<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends ConsumerState<DocumentsTab> {
  final TextEditingController _documentSearchController =
      TextEditingController();

  @override
  void dispose() {
    _documentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(
      filteredSiteDocumentsProvider(widget.site.id),
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSearchBar(
            controller: _documentSearchController,
            onChanged: (val) {
              ref.read(documentSearchQueryProvider.notifier).update(val);
              setState(() {});
            },
            hintText: 'Search documents by filename...',
            showClearButton: _documentSearchController.text.isNotEmpty,
            onClear: () {
              _documentSearchController.clear();
              ref.read(documentSearchQueryProvider.notifier).update('');
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          documentsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (documents) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Uploaded Documents',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${documents.length} ${documents.length == 1 ? "File" : "Files"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: documentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading documents: $e')),
              data: (documents) {
                if (documents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Documents Found',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Upload blueprints, layouts, safety manuals, or other project files.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: documents.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    final isPdf = doc.fileName.toLowerCase().endsWith('.pdf');

                    return VaultCard(
                      creatorName: doc.createdByProfile?.displayName,
                      createdAt: doc.createdAt,
                      onTap: () => widget.onOpenDocument(
                        context,
                        doc.fileUrl,
                        doc.fileName,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.description_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        doc.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          doc.description != null && doc.description!.isNotEmpty
                          ? Text(
                              doc.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.site.status == 'active')
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                              ),
                              splashRadius: 20,
                              onSelected: (action) {
                                if (action == 'edit') {
                                  widget.onEditDocument(context, doc);
                                } else if (action == 'delete') {
                                  widget.onDeleteDocument(context, doc);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
