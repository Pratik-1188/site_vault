import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/shared/theme/firm_colors.dart';
import 'package:site_vault/shared/theme/app_theme.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
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
  String? _selectedCreatedBy;
  String? _selectedPaidBy;

  double _selectedGstPercentage = 0.0;
  double _calculatedBaseAmount = 0.0;
  double _calculatedGstAmount = 0.0;

  // File Attachment variables
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  String? _pickedMimeType;
  bool _isUploading = false;

  final List<double> _gstRates = [0.0, 5.0, 12.0, 18.0, 28.0];

  @override
  void initState() {
    super.initState();
    final expense = widget.expenseToEdit;

    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(text: expense?.amount != null ? expense!.amount.toString() : '');
    _descriptionController = TextEditingController(text: expense?.description ?? '');

    _selectedDate = expense?.expenseDate ?? DateTime.now();
    _selectedPaymentMode = expense?.paymentMode ?? PaymentMode.cash;
    _isRefundable = expense?.isRefundable ?? false;

    _selectedCategoryId = expense?.categoryId;
    _selectedVendorId = expense?.vendorId;
    _selectedCreatedBy = expense?.createdBy;
    _selectedPaidBy = expense?.paidBy;

    _selectedGstPercentage = expense?.gstPercentage ?? 0.0;
    
    // Trigger initial calculation
    _calculateGst();
    
    _amountController.addListener(_calculateGst);
  }

  @override
  void dispose() {
    _amountController.removeListener(_calculateGst);
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Extracts the Base Amount and GST Amount dynamically from the Total Amount
  void _calculateGst() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _calculatedBaseAmount = 0.0;
        _calculatedGstAmount = 0.0;
      });
      return;
    }

    final total = double.tryParse(amountText) ?? 0.0;
    if (total <= 0.0) {
      setState(() {
        _calculatedBaseAmount = 0.0;
        _calculatedGstAmount = 0.0;
      });
      return;
    }

    final percentage = _selectedGstPercentage;
    if (percentage == 0.0) {
      setState(() {
        _calculatedBaseAmount = total;
        _calculatedGstAmount = 0.0;
      });
    } else {
      // GST Amount = Total * (Percentage / (100 + Percentage))
      final gst = total * (percentage / (100.0 + percentage));
      final base = total - gst;
      setState(() {
        _calculatedBaseAmount = base;
        _calculatedGstAmount = gst;
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

  /// Picks a receipt attachment using file_picker
  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true, // Crucial to load file bytes cross-platform
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

  /// Handles file upload and database mutations
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCreatedBy == null || _selectedPaidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select who Created and Paid for the expense.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? fileUrl;

      // 1. Upload receipt to storage if picked
      if (_pickedFileBytes != null && _pickedFileName != null) {
        fileUrl = await ref.read(storageRepositoryProvider).uploadFile(
              bucket: 'expense-attachments',
              path: 'expense_${widget.siteId}',
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
        firmId: widget.firmId,
        siteId: widget.siteId,
        createdBy: _selectedCreatedBy!,
        paidBy: _selectedPaidBy!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        expenseDate: _selectedDate,
        categoryId: _selectedCategoryId,
        vendorId: _selectedVendorId,
        amount: total,
        gstPercentage: _selectedGstPercentage == 0.0 ? null : _selectedGstPercentage,
        gstAmount: _calculatedGstAmount == 0.0 ? null : _calculatedGstAmount,
        paymentMode: _selectedPaymentMode,
        isRefundable: _isRefundable,
        createdAt: widget.expenseToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Database Write operations
      final siteExpensesNotifier = ref.read(siteExpensesProvider(widget.siteId).notifier);
      
      if (widget.expenseToEdit == null) {
        // Create Mode
        final newExpense = await ref.read(expenseRepositoryProvider).createExpense(expense);
        
        // Write attachments link if uploaded
        if (fileUrl != null) {
          await ref.read(expenseRepositoryProvider).addAttachment(newExpense.id, fileUrl);
        }
      } else {
        // Edit Mode
        await siteExpensesNotifier.editExpense(expense);
        
        // Write attachments link if uploaded
        if (fileUrl != null) {
          await ref.read(expenseRepositoryProvider).addAttachment(expense.id, fileUrl);
        }
      }

      // 4. Invalidate providers to force live updates
      ref.invalidate(siteExpensesProvider(widget.siteId));
      ref.invalidate(siteTotalExpensesProvider(widget.siteId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expenseToEdit == null ? 'Expense created successfully!' : 'Expense updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF059669),
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
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final vendorsAsync = ref.watch(vendorsProvider);
    final profilesAsync = ref.watch(profilesProvider);

    final firmColors = Theme.of(context).extension<FirmColors>()!;
    final baseColor = firmColors.getFirmColor(widget.firmId);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                    widget.expenseToEdit == null ? 'Add Expense' : 'Edit Expense',
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

            // Scrollable Form content
            Expanded(
              child: _isUploading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Uploading receipt & saving record...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20.0),
                        children: [
                          // 1. Title Input
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Expense Title *',
                              hintText: 'e.g. Purchase of Fuses & Wires',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Title is required';
                              if (val.trim().length <= 2) return 'Title must be longer than 2 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 2. Amount & GST Selector row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Total Amount (INR) *',
                                    hintText: '0.00',
                                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Amount required';
                                    final numVal = double.tryParse(val);
                                    if (numVal == null || numVal < 0) return 'Invalid amount';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<double>(
                                  initialValue: _selectedGstPercentage,
                                  decoration: const InputDecoration(
                                    labelText: 'GST %',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                  ),
                                  items: _gstRates.map((double rate) {
                                    return DropdownMenuItem<double>(
                                      value: rate,
                                      child: Text(rate == 0.0 ? 'None' : '${rate.toInt()}%'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedGstPercentage = val;
                                      });
                                      _calculateGst();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          // GST Split breakdown Summary Card
                          if (_amountController.text.isNotEmpty && double.tryParse(_amountController.text) != null && _selectedGstPercentage > 0) ...[
                            const SizedBox(height: 12),
                            Card(
                              color: baseColor.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: baseColor.withValues(alpha: 0.15), width: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                child: Column(
                                  children: [
                                    _summaryLine('Base Amount (Untaxed)', '₹${_calculatedBaseAmount.toStringAsFixed(2)}'),
                                    const SizedBox(height: 4),
                                    _summaryLine('GST Amount Extractions (${_selectedGstPercentage.toInt()}%)', '₹${_calculatedGstAmount.toStringAsFixed(2)}'),
                                    const Divider(height: 16, thickness: 0.5),
                                    _summaryLine('Total Inclusive Sum', '₹${double.parse(_amountController.text.trim()).toStringAsFixed(2)}', isBold: true, valueColor: baseColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // 3. User Selectors: Paid By & Created By
                          profilesAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error loading profiles: $e'),
                            data: (profiles) {
                              // Auto-fill creators if empty and profiles exist
                              if (profiles.isNotEmpty) {
                                _selectedCreatedBy ??= profiles.first.id;
                                _selectedPaidBy ??= profiles.first.id;
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedPaidBy,
                                      decoration: const InputDecoration(
                                        labelText: 'Paid By *',
                                        prefixIcon: Icon(Icons.person_rounded),
                                      ),
                                      items: profiles.map((p) {
                                        return DropdownMenuItem(value: p.id, child: Text(p.displayName));
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedPaidBy = val),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedCreatedBy,
                                      decoration: const InputDecoration(
                                        labelText: 'Created By *',
                                        prefixIcon: Icon(Icons.edit_note_rounded),
                                      ),
                                      items: profiles.map((p) {
                                        return DropdownMenuItem(value: p.id, child: Text(p.displayName));
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedCreatedBy = val),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. Selectors Category & Vendor
                          Row(
                            children: [
                              // Categories
                              Expanded(
                                child: categoriesAsync.when(
                                  loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                  error: (e, _) => Text('Err: $e'),
                                  data: (categories) {
                                    return DropdownButtonFormField<String>(
                                      initialValue: _selectedCategoryId,
                                      decoration: const InputDecoration(
                                        labelText: 'Category',
                                        prefixIcon: Icon(Icons.category_rounded),
                                      ),
                                      items: categories.map((c) {
                                        return DropdownMenuItem(value: c.id, child: Text(c.name));
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Vendors
                              Expanded(
                                child: vendorsAsync.when(
                                  loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                  error: (e, _) => Text('Err: $e'),
                                  data: (vendors) {
                                    return DropdownButtonFormField<String>(
                                      initialValue: _selectedVendorId,
                                      decoration: const InputDecoration(
                                        labelText: 'Vendor',
                                        prefixIcon: Icon(Icons.store_rounded),
                                      ),
                                      items: vendors.map((v) {
                                        return DropdownMenuItem(value: v.id, child: Text(v.name));
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedVendorId = val),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 5. Selectors: Payment Mode & Date Picker
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<PaymentMode>(
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
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedPaymentMode = val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Theme.of(context).inputDecorationTheme.fillColor : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _selectedDate.toReadableString(),
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 6. Description
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Additional Description',
                              hintText: 'Describe details of this transaction...',
                              prefixIcon: Icon(Icons.description_rounded),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 7. Refundable Toggle Switch
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Theme.of(context).inputDecorationTheme.fillColor : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment_return_rounded,
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Refundable Expense', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Switch(
                                  value: _isRefundable,
                                  activeThumbColor: baseColor,
                                  onChanged: (val) => setState(() => _isRefundable = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 8. Attachments Manager Section
                          Text('Receipt / Attachment', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          _pickedFileName != null
                              ? Card(
                                  color: baseColor.withValues(alpha: 0.05),
                                  child: ListTile(
                                    leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
                                    title: Text(_pickedFileName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    subtitle: const Text('Ready to upload on save', style: TextStyle(fontSize: 11)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() {
                                          _pickedFileName = null;
                                          _pickedFileBytes = null;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              : OutlinedButton.icon(
                                  onPressed: _pickAttachment,
                                  icon: const Icon(Icons.cloud_upload_rounded),
                                  label: const Text('Pick Invoice / PDF receipt'),
                                ),
                          
                          const SizedBox(height: 32),

                          // Submit Action Button
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: baseColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              widget.expenseToEdit == null ? 'CREATE RECORD' : 'SAVE CHANGES',
                            ),
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

  Widget _summaryLine(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isBold ? Colors.black : Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
