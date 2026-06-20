import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';

import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/widget/app_bottom_sheet.dart';
import 'package:site_vault/shared/utils/snackbar_message.dart';
import 'package:site_vault/shared/mixin/form_submit_mixin.dart';

import 'package:site_vault/feature/site/widgets/site_scope_selector_mixin.dart';
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

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> with SiteScopeSelectorMixin, FormSubmitMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late PaymentMode _selectedPaymentMode;
  late bool _isRefundable;

  String? _selectedCategoryId;
  String? _selectedVendorId;

  bool _isGst = false;

  // File Attachment variables
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  String? _pickedMimeType;

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

    initSiteScope(
      initialFirmId: expense?.firmId ?? (widget.firmId.isNotEmpty ? widget.firmId : null),
      initialSiteId: expense?.siteId ?? (widget.siteId.isNotEmpty ? widget.siteId : null),
      isLocked: widget.firmId.isNotEmpty && widget.siteId.isNotEmpty,
    );

    _isGst = expense?.isGst ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      AppSnackBar.showError(
        context,
        'User session expired. Please log in again.',
      );
      return;
    }

    if (selectedFirmId == null || selectedSiteId == null) {
      AppSnackBar.showError(context, 'Please select both Firm and Site.');
      return;
    }

    await runFormSubmit(
      action: () async {
        String? fileUrl;

        // 1. Upload receipt to storage if picked or captured
        if (_pickedFileBytes != null && _pickedFileName != null) {
          fileUrl = await ref
              .read(storageActionsProvider)
              .uploadFile(
                bucket: selectedSiteId!, // Site's unique UUID bucket
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
          firmId: selectedFirmId!,
          siteId: selectedSiteId!,
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
          await ref
              .read(expenseActionsProvider)
              .updateExpense(expense, previousSiteId: widget.siteId);
        }
      },
      successMessage: widget.expenseToEdit == null
          ? 'Expense created successfully!'
          : 'Expense updated successfully!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final vendorsAsync = ref.watch(vendorsProvider);

    return AppBottomSheet(
      title: widget.expenseToEdit == null
          ? 'Add Expense'
          : 'Edit Expense Details',
      formKey: _formKey,
      canClose: !isSubmitting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Context Scope
          buildScopeSelector(context),

                            // 2. Core Details Section
                            Text(
                              'Core Details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              enabled: !isSubmitting,
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
                              enabled: !isSubmitting,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                              subtitle: const Text(
                                'Include GST tax invoice details',
                              ),
                              secondary: const Icon(Icons.receipt_long_rounded),
                              value: _isGst,
                              onChanged: isSubmitting
                                  ? null
                                  : (val) => setState(() => _isGst = val),
                            ),
                            const SizedBox(height: 24),

                            // 3. Attributes Section
                            Text(
                              'Attributes',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            categoriesAsync.when(
                              loading: () => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                                  onChanged: isSubmitting
                                      ? null
                                      : (val) => setState(
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
                              onChanged: isSubmitting
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(
                                          () => _selectedPaymentMode = val,
                                        );
                                      }
                                    },
                            ),
                            const SizedBox(height: 16),
                            vendorsAsync.when(
                              loading: () => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                                  onChanged: isSubmitting
                                      ? null
                                      : (val) => setState(
                                          () => _selectedVendorId = val,
                                        ),
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
                              onTap: isSubmitting
                                  ? null
                                  : () => _selectDate(context),
                            ),
                            const SizedBox(height: 24),

                            // 4. Documentation & Options Section
                            Text(
                              'Documentation & Options',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Refundable'),
                              subtitle: const Text(
                                'Mark this expense for reimbursement',
                              ),
                              secondary: const Icon(
                                Icons.assignment_return_rounded,
                              ),
                              value: _isRefundable,
                              onChanged: isSubmitting
                                  ? null
                                  : (val) =>
                                        setState(() => _isRefundable = val),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Attachment',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            _pickedFileName != null
                                ? Card(
                                    elevation: 0,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                    child: ListTile(
                                      leading: Icon(
                                        _pickedFileName!.toLowerCase().endsWith(
                                              '.pdf',
                                            )
                                            ? Icons.picture_as_pdf_rounded
                                            : Icons.image_rounded,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
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
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: isSubmitting
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: AppRadius.brXs,
                                    ),
                                    child: InkWell(
                                      borderRadius: AppRadius.brXs,
                                      onTap: isSubmitting
                                          ? null
                                          : () =>
                                                _showAttachmentPicker(context),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.add_a_photo_rounded,
                                              size: 32,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
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
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: isSubmitting ? null : _submitForm,
                                  child: isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
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
                      );
  }
}
