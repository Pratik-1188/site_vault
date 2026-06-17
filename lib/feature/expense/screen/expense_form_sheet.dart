import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/provider/firm_provider.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';

import 'package:site_vault/feature/site/provider/site_provider.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/feature/auth/provider/auth_provider.dart';
import '../model/expense.dart';
import '../provider/expense_provider.dart';

/// A premium, highly consistent M3 Bottom Sheet form for creating or editing expenses.
///
/// Features:
/// - Inverted GST Calculations: Extracts tax split dynamically from the **Total Amount**.
/// - Dynamic DB Selectors: Loads active categories, vendors, and user profiles dynamically.
/// - Attachment Manager: Picks files using [file_picker] and uploads binary files
///   directly to Supabase Storage, linking the resulting URL into the database.
class ExpenseFormSheet extends ConsumerStatefulWidget {
  final String siteId;
  final String firmId;
  final Expense? expenseToEdit;

  const ExpenseFormSheet({
    super.key,
    required this.siteId,
    required this.firmId,
    this.expenseToEdit,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late PaymentMode _selectedPaymentMode;
  late bool _isRefundable;

  String? _selectedCategoryId;
  String? _selectedVendorId;

  // Firm & Site dynamic selection state
  String? _selectedFirmId;
  String? _selectedSiteId;
  List<Site>? _activeSites;
  bool _isLoadingSites = false;
  late bool
  _isContextLocked; // Locked if started from specific site details screen

  bool _isGst = false;

  // File Attachment variables
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  String? _pickedMimeType;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.expenseToEdit;

    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense?.amount != null ? expense!.amount.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );

    _selectedDate = expense?.expenseDate ?? DateTime.now();
    _selectedPaymentMode = expense?.paymentMode ?? PaymentMode.cash;
    _isRefundable = expense?.isRefundable ?? false;

    _selectedCategoryId = expense?.categoryId;
    _selectedVendorId = expense?.vendorId;

    // Firm & Site context selection (locked if both firmId and siteId are provided)
    _selectedFirmId =
        expense?.firmId ?? (widget.firmId.isNotEmpty ? widget.firmId : null);
    _selectedSiteId =
        expense?.siteId ?? (widget.siteId.isNotEmpty ? widget.siteId : null);
    _isContextLocked = widget.firmId.isNotEmpty && widget.siteId.isNotEmpty;

    _isGst = expense?.isGst ?? false;

    // Fetch initial active sites if firm is selected
    if (_selectedFirmId != null) {
      _loadSitesForFirm(_selectedFirmId!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
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
      final sitesList =
          await ref.read(activeSitesByFirmProvider(firmId).future);

      if (!mounted) return;
      setState(() {
        _activeSites = sitesList;
        _isLoadingSites = false;

        // Reset selected site if it is not in the newly loaded active sites list
        if (_selectedSiteId != null &&
            !_activeSites!.any((s) => s.id == _selectedSiteId)) {
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



  /// Select Date calendar picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Maps file extensions to their standard, robust MIME types
  String? _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'csv':
        return 'text/csv';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/$ext';
    }
  }

  /// Takes a photo from the device camera
  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _pickedFileName = photo.name;
          _pickedFileBytes = bytes;
          _pickedMimeType = _getMimeType(photo.name);
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Error capturing photo: $e');
    }
  }

  /// Picks a receipt attachment using file_picker
  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _pickedFileName = file.name;
          _pickedFileBytes = file.bytes;
          _pickedMimeType = _getMimeType(file.name);
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Error picking file: $e');
    }
  }

  /// Shows options to upload file or capture photo
  void _showAttachmentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take Photo (Camera)'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload_rounded),
                title: const Text('Upload File (PDF, Images)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAttachment();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handles file upload and database mutations
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = ref.read(currentAuthUserProvider)?.id;
    if (currentUserId == null) {
      AppSnackBar.showError(context, 'User session expired. Please log in again.');
      return;
    }

    if (_selectedFirmId == null || _selectedSiteId == null) {
      AppSnackBar.showError(context, 'Please select both Firm and Site.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? fileUrl;

      // 1. Upload receipt to storage if picked or captured
      if (_pickedFileBytes != null && _pickedFileName != null) {
        fileUrl = await ref
            .read(storageActionsProvider)
            .uploadFile(
              bucket: _selectedSiteId!, // Site's unique UUID bucket
              path: 'expenses',
              fileBytes: _pickedFileBytes!,
              fileName: _pickedFileName!,
              mimeType: _pickedMimeType,
            );
        if (!mounted) return;
      }

      // 2. Build the Expense Object
      final total = double.parse(_amountController.text.trim());
      final expense = Expense(
        id: widget.expenseToEdit?.id ?? '',
        firmId: _selectedFirmId!,
        siteId: _selectedSiteId!,
        createdBy: currentUserId, // Bind creator user ID behind the scenes
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        attachmentPath: fileUrl ?? widget.expenseToEdit?.attachmentPath,
        expenseDate: _selectedDate,
        categoryId: _selectedCategoryId,
        vendorId: _selectedVendorId,
        amount: total,
        isGst: _isGst,
        paymentMode: _selectedPaymentMode,
        isRefundable: _isRefundable,
        createdAt: widget.expenseToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Database Write operations
      if (widget.expenseToEdit == null) {
        // Create Mode
        await ref.read(expenseActionsProvider).createExpense(expense);
      } else {
        // Edit Mode
        if (_selectedSiteId == widget.siteId) {
          await ref.read(expenseActionsProvider).updateExpense(
                expense,
                previousSiteId: widget.siteId,
              );
        } else {
          await ref.read(expenseActionsProvider).updateExpense(
                expense,
                previousSiteId: widget.siteId,
              );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.showSuccess(
          context,
          widget.expenseToEdit == null
              ? 'Expense created successfully!'
              : 'Expense updated successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
        AppSnackBar.showError(context, cleanMessage);
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
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final vendorsAsync = ref.watch(vendorsProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.verticalMd,
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
                    // Pinned Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.expenseToEdit == null ? 'Add Expense' : 'Edit Expense Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: _isUploading ? null : () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24, indent: 24, endIndent: 24),

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Context Scope
                            if (!_isContextLocked) ...[
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
                                    decoration: const InputDecoration(
                                      labelText: 'Firm',
                                      prefixIcon: Icon(Icons.business_rounded),
                                    ),
                                    items: firms.map((firm) {
                                      return DropdownMenuItem<String>(
                                        value: firm.id,
                                        child: Text(firm.name),
                                      );
                                    }).toList(),
                                    onChanged: _isUploading ? null : (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedFirmId = val;
                                          _selectedSiteId = null;
                                        });
                                        _loadSitesForFirm(val);
                                      }
                                    },
                                    validator: (val) =>
                                        val == null ? 'Firm is required' : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedSiteId,
                                decoration: InputDecoration(
                                  labelText: 'Site',
                                  prefixIcon: const Icon(Icons.location_on_rounded),
                                  suffixIcon: _isLoadingSites
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                items: _activeSites?.map((site) {
                                      return DropdownMenuItem<String>(
                                        value: site.id,
                                        child: Text(site.name),
                                      );
                                    }).toList() ??
                                    [],
                                onChanged: (_selectedFirmId == null || _isUploading)
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _selectedSiteId = val;
                                        });
                                      },
                                validator: (val) =>
                                    val == null ? 'Site is required' : null,
                              ),
                              const SizedBox(height: 24),
                            ],

                            // 2. Core Details Section
                            Text(
                              'Core Details',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              enabled: !_isUploading,
                              decoration: const InputDecoration(
                                labelText: 'Expense Title',
                                hintText: 'e.g. Purchase of Fuses & Wires',
                                prefixIcon: Icon(Icons.title_rounded),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Title is required';
                                }
                                if (val.trim().length <= 2) {
                                  return 'Title must be longer than 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _amountController,
                              enabled: !_isUploading,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Total Amount',
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Amount required';
                                }
                                final numVal = double.tryParse(val);
                                if (numVal == null || numVal <= 0) {
                                  return 'Enter a valid positive amount';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('GST Bill'),
                              subtitle: const Text('Include GST tax invoice details'),
                              secondary: const Icon(Icons.receipt_long_rounded),
                              value: _isGst,
                              onChanged: _isUploading ? null : (val) => setState(() => _isGst = val),
                            ),
                            const SizedBox(height: 24),

                            // 3. Attributes Section
                            Text(
                              'Attributes',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            categoriesAsync.when(
                              loading: () => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              error: (e, _) => Text('Err: $e'),
                              data: (categories) {
                                return DropdownButtonFormField<String>(
                                  initialValue: _selectedCategoryId,
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    prefixIcon: Icon(Icons.category_rounded),
                                  ),
                                  items: categories.map((c) {
                                    return DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    );
                                  }).toList(),
                                  onChanged: _isUploading ? null : (val) => setState(
                                    () => _selectedCategoryId = val,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<PaymentMode>(
                              initialValue: _selectedPaymentMode,
                              decoration: const InputDecoration(
                                labelText: 'Payment Mode',
                                prefixIcon: Icon(Icons.payment_rounded),
                              ),
                              items: PaymentMode.values.map((mode) {
                                return DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode.toDisplayLabel()),
                                );
                              }).toList(),
                              onChanged: _isUploading ? null : (val) {
                                if (val != null) {
                                  setState(() => _selectedPaymentMode = val);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            vendorsAsync.when(
                              loading: () => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              error: (e, _) => Text('Err: $e'),
                              data: (vendors) {
                                return DropdownButtonFormField<String>(
                                  initialValue: _selectedVendorId,
                                  decoration: const InputDecoration(
                                    labelText: 'Vendor',
                                    prefixIcon: Icon(Icons.store_rounded),
                                  ),
                                  items: vendors.map((v) {
                                    return DropdownMenuItem(
                                      value: v.id,
                                      child: Text(v.name),
                                    );
                                  }).toList(),
                                  onChanged: _isUploading ? null : (val) =>
                                      setState(() => _selectedVendorId = val),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: _selectedDate.toReadableString(),
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Expense Date',
                                prefixIcon: Icon(Icons.calendar_today_rounded),
                              ),
                              onTap: _isUploading ? null : () => _selectDate(context),
                            ),
                            const SizedBox(height: 24),

                            // 4. Documentation & Options Section
                            Text(
                              'Documentation & Options',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                             SwitchListTile(
                               contentPadding: EdgeInsets.zero,
                               title: const Text('Refundable'),
                               subtitle: const Text('Mark this expense for reimbursement'),
                               secondary: const Icon(Icons.assignment_return_rounded),
                               value: _isRefundable,
                               onChanged: _isUploading ? null : (val) => setState(() => _isRefundable = val),
                             ),
                            const SizedBox(height: 16),
                            Text(
                              'Attachment',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            _pickedFileName != null
                                ? Card(
                                    elevation: 0,
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    child: ListTile(
                                      leading: Icon(
                                        _pickedFileName!.toLowerCase().endsWith('.pdf')
                                            ? Icons.picture_as_pdf_rounded
                                            : Icons.image_rounded,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      title: Text(
                                        _pickedFileName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      ),
                                      subtitle: Text(
                                        'Ready to upload on save',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: _isUploading
                                            ? null
                                            : () {
                                                setState(() {
                                                  _pickedFileName = null;
                                                  _pickedFileBytes = null;
                                                });
                                              },
                                      ),
                                    ),
                                  )
                                : Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.outlineVariant,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: AppRadius.brXs,
                                    ),
                                    child: InkWell(
                                      borderRadius: AppRadius.brXs,
                                      onTap: _isUploading ? null : () => _showAttachmentPicker(context),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.add_a_photo_rounded,
                                              size: 32,
                                              color:
                                                  Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Upload Receipt',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tap to capture or select',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 32),

                            // Bottom Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: _isUploading ? null : _submitForm,
                                  child: _isUploading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          widget.expenseToEdit == null
                                              ? 'Create Expense'
                                              : 'Save Changes',
                                        ),
                                ),
                              ],
                            ),
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
}
