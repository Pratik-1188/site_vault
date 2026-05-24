import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/shared/theme/firm_colors.dart';
import 'package:site_vault/shared/theme/app_theme.dart';
import 'package:site_vault/feature/expense/provider/expense_provider.dart'; // Re-use profiles lookup
import 'package:site_vault/shared/utils/error_interceptor.dart';
import '../model/document.dart';
import '../provider/document_provider.dart';

/// A premium, M3-aligned modal bottom sheet that handles site document uploading.
///
/// Features:
/// - Any-Format File picking using [file_picker] (blueprints, spreadsheets, layout drawings).
/// - Dynamic profile selectors to capture the dynamic uploader user name.
/// - Uploads binaries directly to the shared `'site-documents'` bucket via [StorageRepository].
class DocumentUploadSheet extends ConsumerStatefulWidget {
  final String siteId;
  final String firmId;

  const DocumentUploadSheet({
    super.key,
    required this.siteId,
    required this.firmId,
  });

  @override
  ConsumerState<DocumentUploadSheet> createState() => _DocumentUploadSheetState();
}

class _DocumentUploadSheetState extends ConsumerState<DocumentUploadSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _descriptionController;
  String? _selectedCreatedBy;

  // File variables
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  String? _pickedMimeType;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
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
          _pickedMimeType = file.extension != null ? 'application/${file.extension}' : null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Submits the file upload and updates database
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFileBytes == null || _pickedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedCreatedBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select who is uploading this document.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Upload file binary to 'site-documents' bucket
      final fileUrl = await ref.read(storageRepositoryProvider).uploadFile(
            bucket: 'site-documents',
            path: 'site_${widget.siteId}',
            fileBytes: _pickedFileBytes!,
            fileName: _pickedFileName!,
            mimeType: _pickedMimeType,
          );
      
      if (!mounted) return;

      // 2. Build the SiteDocument Object
      final document = SiteDocument(
        id: '',
        firmId: widget.firmId,
        siteId: widget.siteId,
        createdBy: _selectedCreatedBy!,
        fileName: _pickedFileName!,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        fileUrl: fileUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Save DB entry using the SiteDocuments controller notifier
      await ref.read(siteDocumentsProvider(widget.siteId).notifier).addDocument(document);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanMessage), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profilesProvider);

    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final baseColor = firmColors.getFirmColor(widget.firmId);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          children: [
            // Handlebar indicator
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Site Document',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form Content
            Expanded(
              child: _isUploading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Uploading document to storage...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20.0),
                        children: [
                          // 1. File Picker Box
                          _pickedFileName != null
                              ? Card(
                                  color: baseColor.withValues(alpha: 0.05),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: baseColor.withValues(alpha: 0.2), width: 1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: baseColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(_getFileIcon(_pickedFileName!), color: baseColor),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _pickedFileName!,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              const Text('File picked & ready for upload', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                          onPressed: () {
                                            setState(() {
                                              _pickedFileName = null;
                                              _pickedFileBytes = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: _pickDocument,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  child: Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Theme.of(context).inputDecorationTheme.fillColor : const Color(0xFFF1F5F9),
                                      border: Border.all(
                                        color: Colors.grey.withValues(alpha: 0.3),
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cloud_upload_outlined, size: 40, color: baseColor),
                                        const SizedBox(height: 12),
                                        const Text('Select Site Blueprint, PDF, or Doc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        const Text('Tap here to browse file explorer', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 20),

                          // 2. Profile uploader dropdown
                          profilesAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error profiles: $e'),
                            data: (profiles) {
                              if (profiles.isNotEmpty) {
                                _selectedCreatedBy ??= profiles.first.id;
                              }
                              return DropdownButtonFormField<String>(
                                initialValue: _selectedCreatedBy,
                                decoration: const InputDecoration(
                                  labelText: 'Uploaded By (Staff Profile) *',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                items: profiles.map((p) {
                                  return DropdownMenuItem(value: p.id, child: Text(p.displayName));
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedCreatedBy = val),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // 3. Description field
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Document Description / Tag Details',
                              hintText: 'Enter helpful notes explaining what this drawing, bill, or invoice covers...',
                              prefixIcon: Icon(Icons.description_rounded),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Upload submit action
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: baseColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('UPLOAD SITE DOCUMENT'),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (lower.endsWith('.dwg') || lower.endsWith('.cad') || lower.endsWith('.dxf')) {
      return Icons.architecture_rounded;
    } else if (lower.endsWith('.xls') || lower.endsWith('.xlsx') || lower.endsWith('.csv')) {
      return Icons.table_chart_rounded;
    } else if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return Icons.image_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }
}
