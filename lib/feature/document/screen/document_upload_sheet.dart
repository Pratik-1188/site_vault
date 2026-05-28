import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/provider/firm_provider.dart';
import 'package:site_vault/feature/site/provider/site_provider.dart';
import 'package:site_vault/feature/site/model/site.dart';
import '../model/document.dart';
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

class _DocumentUploadSheetState extends ConsumerState<DocumentUploadSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fileNameController;
  late TextEditingController _descriptionController;

  // Firm & Site dynamic selection state
  String? _selectedFirmId;
  String? _selectedSiteId;
  List<Site>? _activeSites;
  bool _isLoadingSites = false;
  late bool _isContextLocked; // Locked if started from specific site details screen

  // File variables
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  String? _pickedMimeType;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();
    _descriptionController = TextEditingController();

    // Firm & Site context selection (locked if both firmId and siteId are provided)
    _selectedFirmId = widget.firmId.isNotEmpty ? widget.firmId : null;
    _selectedSiteId = widget.siteId.isNotEmpty ? widget.siteId : null;
    _isContextLocked = widget.firmId.isNotEmpty && widget.siteId.isNotEmpty;

    // Fetch initial active sites if firm is selected
    if (_selectedFirmId != null) {
      _loadSitesForFirm(_selectedFirmId!);
    }
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Fetches active sites dynamically under the selected firm
  Future<void> _loadSitesForFirm(String firmId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingSites = true;
      _activeSites = null;
    });

    try {
      final response = await ref.read(siteRepositoryProvider).client
          .from('sites')
          .select()
          .eq('firm_id', firmId)
          .eq('status', 'active');

      if (!mounted) return;

      final sitesList = (response as List).map((e) => Site.fromJson(e)).toList();

      setState(() {
        _activeSites = sitesList;
        _isLoadingSites = false;

        // Reset selected site if it is not in the newly loaded active sites list
        if (_selectedSiteId != null && !_activeSites!.any((s) => s.id == _selectedSiteId)) {
          _selectedSiteId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _activeSites = [];
        _isLoadingSites = false;
        _selectedSiteId = null;
      });
    }
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

          // Pre-fill the custom file name controller with the picked file's name
          _fileNameController.text = file.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Submits the file upload and updates database
  Future<void> _submitForm() async {
    debugPrint('[DocumentUpload] _submitForm triggered');
    if (!_formKey.currentState!.validate()) {
      debugPrint('[DocumentUpload] Form validation failed');
      return;
    }

    if (_selectedFirmId == null || _selectedSiteId == null) {
      debugPrint('[DocumentUpload] Scope selection missing');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both Firm and Site.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (_pickedFileBytes == null || _pickedFileName == null) {
      debugPrint('[DocumentUpload] No file picked');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a file to upload.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      debugPrint('[DocumentUpload] No active user session');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active session found. Please sign in again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }
    final uploaderId = user.id;
    debugPrint('[DocumentUpload] Uploader: $uploaderId');

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Upload file binary to the site's auto-created bucket
      debugPrint('[DocumentUpload] Uploading file to storage...');
      final fileUrl = await ref
          .read(storageRepositoryProvider)
          .uploadFile(
            bucket: _selectedSiteId!,
            path: 'documents',
            fileBytes: _pickedFileBytes!,
            fileName: _pickedFileName!,
            mimeType: _pickedMimeType,
          );
      debugPrint('[DocumentUpload] Storage upload OK: $fileUrl');

      if (!mounted) return;

      // 2. Build the SiteDocument Object
      final document = SiteDocument(
        id: '',
        siteId: _selectedSiteId!,
        createdBy: uploaderId,
        fileName: _fileNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        fileUrl: fileUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Save DB entry using the SiteDocuments controller notifier
      debugPrint('[DocumentUpload] Inserting document record...');
      await ref
          .read(siteDocumentsProvider(_selectedSiteId!).notifier)
          .addDocument(document);
      debugPrint('[DocumentUpload] Insert OK');

      // 4. Invalidate provider to force a refresh on the site's document page
      ref.invalidate(siteDocumentsProvider(_selectedSiteId!));

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
    } catch (e, stack) {
      debugPrint('[DocumentUpload] ERROR: $e');
      debugPrint('[DocumentUpload] STACK: $stack');
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.redAccent,
          ),
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
    final firmsAsync = ref.watch(firmsProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. PINNED STICKY HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upload Site Document',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24, indent: 24, endIndent: 24),

                    // 2. SCROLLABLE CONTENT BODY
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isUploading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text(
                                        'Uploading document to storage...',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              // Context Scope Card
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Scope',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      firmsAsync.when(
                                        loading: () => const LinearProgressIndicator(),
                                        error: (err, _) => Text('Error loading firms: $err'),
                                        data: (firms) {
                                          return DropdownButtonFormField<String>(
                                            initialValue: _selectedFirmId,
                                            decoration: InputDecoration(
                                              labelText: 'Firm',
                                              prefixIcon: const Icon(Icons.business_rounded),
                                              suffixIcon: _isContextLocked
                                                  ? const Icon(Icons.lock_outline_rounded)
                                                  : null,
                                            ),
                                            icon: _isContextLocked ? const SizedBox.shrink() : null,
                                            items: firms.map((firm) {
                                              return DropdownMenuItem<String>(
                                                value: firm.id,
                                                child: Text(firm.name),
                                              );
                                            }).toList(),
                                            onChanged: _isContextLocked
                                                ? null
                                                : (val) {
                                                    if (val != null) {
                                                      setState(() {
                                                        _selectedFirmId = val;
                                                        _selectedSiteId = null;
                                                      });
                                                      _loadSitesForFirm(val);
                                                    }
                                                  },
                                            validator: (val) => val == null ? 'Firm is required' : null,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedSiteId,
                                        decoration: InputDecoration(
                                          labelText: 'Site',
                                          prefixIcon: const Icon(Icons.location_on_rounded),
                                          suffixIcon: _isContextLocked
                                              ? const Icon(Icons.lock_outline_rounded)
                                              : _isLoadingSites
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(12.0),
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                    )
                                                  : null,
                                        ),
                                        icon: (_isContextLocked || _isLoadingSites)
                                            ? const SizedBox.shrink()
                                            : null,
                                        items: _activeSites?.map((site) {
                                              return DropdownMenuItem<String>(
                                                value: site.id,
                                                child: Text(site.name),
                                              );
                                            }).toList() ??
                                            [],
                                        onChanged: (_isContextLocked || _selectedFirmId == null)
                                            ? null
                                            : (val) {
                                                setState(() {
                                                  _selectedSiteId = val;
                                                });
                                              },
                                        validator: (val) => val == null ? 'Site is required' : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Document Metadata Card
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
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
                                        maxLines: 3,
                                        decoration: const InputDecoration(
                                          labelText: 'Document Description / Tag Details',
                                          hintText: 'Enter helpful notes explaining what this drawing covers...',
                                          prefixIcon: Icon(Icons.description_rounded),
                                        ),
                                        textCapitalization: TextCapitalization.sentences,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // File Attachment Card
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
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
                                                      icon: const Icon(
                                                        Icons.delete_outline_rounded,
                                                        color: Colors.redAccent,
                                                      ),
                                                      onPressed: () {
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
                                                onPressed: _pickDocument,
                                                icon: const Icon(Icons.cloud_upload_outlined),
                                                label: const Text('Select Site Blueprint, PDF, or Doc'),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Upload submit action
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  child: const Text('UPLOAD SITE DOCUMENT'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
