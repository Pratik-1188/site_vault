import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';

import 'package:site_vault/shared/widget/app_bottom_sheet.dart';
import 'package:site_vault/shared/widget/sheet_action_row.dart';
import 'package:site_vault/shared/mixin/form_submit_mixin.dart';
import 'package:site_vault/feature/site/widgets/site_scope_selector_mixin.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';
import 'package:site_vault/shared/utils/form_utils.dart';
import '../provider/document_provider.dart';

/// A premium, M3-aligned modal bottom sheet that handles site document uploading.
///
/// Features:
/// - Sticky pinned header that stays in place while the rest of the form scrolls.
/// - Backdrop blurring and 85% screen height limit.
/// - Dynamic Firm & Site selectors in unlocked mode.
class DocumentUploadSheet extends ConsumerStatefulWidget {
  final String siteId;
  final String firmId;

  const DocumentUploadSheet({
    super.key,
    required this.siteId,
    required this.firmId,
  });

  @override
  ConsumerState<DocumentUploadSheet> createState() =>
      _DocumentUploadSheetState();
}

class _DocumentUploadSheetState extends ConsumerState<DocumentUploadSheet> with SiteScopeSelectorMixin, FormSubmitMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fileNameController;
  late TextEditingController _descriptionController;

  // File variables
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  String? _pickedMimeType;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();
    _descriptionController = TextEditingController();

    initSiteScope(
      initialFirmId: widget.firmId.isNotEmpty ? widget.firmId : null,
      initialSiteId: widget.siteId.isNotEmpty ? widget.siteId : null,
      isLocked: widget.firmId.isNotEmpty && widget.siteId.isNotEmpty,
    );
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Picks a document file via file_picker
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true, // Crucial to load file bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _pickedFileName = file.name;
          _pickedFileBytes = file.bytes;

          // Determine correct MIME type based on extension
          final ext = file.extension?.toLowerCase();
          if (ext == 'jpg' || ext == 'jpeg') {
            _pickedMimeType = 'image/jpeg';
          } else if (ext == 'png') {
            _pickedMimeType = 'image/png';
          } else if (ext == 'pdf') {
            _pickedMimeType = 'application/pdf';
          } else if (ext != null) {
            // Fallback for other files (e.g., zip, docx)
            _pickedMimeType = 'application/octet-stream';
          } else {
            _pickedMimeType = null;
          }

          // Pre-fill the custom file name controller with the picked file's name only if it's currently empty
          if (_fileNameController.text.trim().isEmpty) {
            _fileNameController.text = file.name;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Error picking file: $e');
    }
  }

  /// Submits the file upload and updates database
  Future<void> _submitForm() async {
    debugPrint('[DocumentUpload] _submitForm triggered');
    if (!FormUtils.validateAndScroll(context, _formKey)) {
      debugPrint('[DocumentUpload] Form validation failed');
      return;
    }

    if (selectedFirmId == null || selectedSiteId == null) {
      debugPrint('[DocumentUpload] Scope selection missing');
      if (mounted) {
        AppSnackBar.showError(context, 'Please select both Firm and Site.');
      }
      return;
    }

    if (_pickedFileBytes == null || _pickedFileName == null) {
      debugPrint('[DocumentUpload] No file picked');
      if (mounted) {
        AppSnackBar.showError(context, 'Please select a file to upload.');
      }
      return;
    }

    final user = ref.read(currentAuthUserProvider);
    if (user == null) {
      debugPrint('[DocumentUpload] No active user session');
      if (mounted) {
        AppSnackBar.showError(context, 'No active session found. Please sign in again.');
      }
      return;
    }
    final uploaderId = user.id;
    debugPrint('[DocumentUpload] Uploader: $uploaderId');

    await runFormSubmit(
      action: () async {
        // 1. Upload file binary to the site's auto-created bucket
        debugPrint('[DocumentUpload] Uploading file to storage...');
        final fileUrl = await ref
            .read(storageActionsProvider)
            .uploadFile(
              bucket: selectedSiteId!,
              path: 'documents',
              fileBytes: _pickedFileBytes!,
              fileName: _pickedFileName!,
              mimeType: _pickedMimeType,
            );
        debugPrint('[DocumentUpload] Storage upload OK: $fileUrl');

        if (!mounted) return;

        // 2. Save DB entry using the SiteDocuments controller notifier
        debugPrint('[DocumentUpload] Inserting document record...');
        await ref.read(documentActionsProvider).addDocument(
              siteId: selectedSiteId!,
              createdBy: uploaderId,
              fileName: _fileNameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              fileUrl: fileUrl,
            );
        debugPrint('[DocumentUpload] Insert OK');
      },
      successMessage: 'Document uploaded successfully!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Upload Document',
      formKey: _formKey,
      canClose: !isSubmitting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Context Scope
          buildScopeSelector(context),

                            // 2. Document Metadata
                            Text(
                              'Document Metadata',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fileNameController,
                              enabled: !isSubmitting,
                              decoration: const InputDecoration(
                                labelText: 'File Name *',
                                hintText: 'Enter a custom name for this document...',
                                prefixIcon: Icon(Icons.title_rounded),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter a file name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              enabled: !isSubmitting,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Document Description / Tag Details',
                                hintText: 'Enter helpful notes explaining what this drawing covers...',
                                prefixIcon: Icon(Icons.description_rounded),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 24),

                            // 3. File Attachment
                            Text(
                              'File Attachment',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _pickedFileName != null
                                ? Card(
                                    elevation: 0,
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getFileIcon(_pickedFileName!),
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _pickedFileName!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'File picked & ready for upload',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline_rounded,
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                            onPressed: isSubmitting
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _pickedFileName = null;
                                                      _pickedFileBytes = null;
                                                      _fileNameController.clear();
                                                    });
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: OutlinedButton.icon(
                                      onPressed: isSubmitting ? null : _pickDocument,
                                      icon: const Icon(Icons.cloud_upload_outlined),
                                      label: const Text('Select Site Blueprint, PDF, or Doc'),
                                    ),
                                  ),
                            const SizedBox(height: 32),

                            // Bottom Action Buttons
                            SheetActionRow(
                              isSubmitting: isSubmitting,
                              onSubmit: _submitForm,
                              submitLabel: 'Upload Document',
                            ),
                          ],
                        ),
                      );
  }

  IconData _getFileIcon(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (lower.endsWith('.dwg') ||
        lower.endsWith('.cad') ||
        lower.endsWith('.dxf')) {
      return Icons.architecture_rounded;
    } else if (lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.csv')) {
      return Icons.table_chart_rounded;
    } else if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg')) {
      return Icons.image_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }
}
