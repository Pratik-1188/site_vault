import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:site_vault/shared/widget/confirmation_dialogs.dart';

import 'package:site_vault/feature/document/model/document.dart';
import 'package:site_vault/feature/document/provider/document_provider.dart';
import 'package:site_vault/feature/expense/model/expense.dart';
import 'package:site_vault/feature/expense/screen/expense_form_sheet.dart';
import 'package:site_vault/feature/document/screen/document_upload_sheet.dart';
import 'package:site_vault/shared/widget/app_bottom_sheet.dart';
import 'package:site_vault/feature/site/model/site.dart';
import 'package:site_vault/shared/provider/storage_provider.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';
import 'package:site_vault/shared/utils/error_interceptor.dart';
import 'package:site_vault/shared/utils/number_formatter.dart';

class SiteDetailDialogs {
  static Future<bool?> confirmSignOut(BuildContext context) async {
    return ConfirmationDialogs.confirm(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of KK Group Site Vault?',
      confirmLabel: 'SIGN OUT',
      isDestructive: true,
    );
  }

  static Future<bool?> confirmStatusChange(
    BuildContext context, {
    required String fromStatus,
    required String toStatus,
    required String siteName,
  }) async {
    if (fromStatus.toLowerCase() == toStatus.toLowerCase()) return true;

    final normalizedTo = toStatus.toLowerCase();
    final destructive = normalizedTo == 'deleted';

    final String title;
    final String message;

    if (destructive) {
      title = 'Delete Site?';
      message = 'This will mark the site as DELETED and soft-delete related expenses. Documents will remain attached.';
    } else {
      title = 'Complete Site?';
      message = 'This will mark the site as COMPLETED and lock the site in read-only mode.';
    }

    final confirmed = await ConfirmationDialogs.confirmStrong(
      context,
      title: title,
      message: message,
      expectedMatch: siteName,
      confirmLabel: destructive ? 'DELETE' : 'COMPLETE',
    );
    return confirmed;
  }

  static Future<bool?> confirmDeleteExpense(
    BuildContext context, {
    required Expense expense,
  }) async {
    return ConfirmationDialogs.confirm(
      context,
      title: 'Delete Expense?',
      message: 'Are you sure you want to delete "${expense.title}"? This will soft-delete the transaction record.',
      confirmLabel: 'DELETE',
      isDestructive: true,
    );
  }

  static Future<bool?> confirmDeleteDocument(
    BuildContext context, {
    required SiteDocument document,
  }) async {
    return ConfirmationDialogs.confirm(
      context,
      title: 'Delete Document?',
      message: 'Are you sure you want to delete "${document.fileName}"? This will soft-delete the document record from the vault.',
      confirmLabel: 'DELETE',
      isDestructive: true,
    );
  }

  static Future<void> showExpenseDetail(
    BuildContext context, {
    required WidgetRef ref,
    required String siteId,
    required Site? site,
    required Expense expense,
    required bool isEditable,
    required IconData Function(String? categoryName) getCategoryIcon,
  }) async {
    final firmId = site?.firmId ?? expense.firmId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  getCategoryIcon(expense.category?.name),
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expense.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      expense.category?.name ?? 'General',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 8),
                _splitRow(
                  'Amount Spent',
                  expense.amount.toCurrencySpan(
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isBold: true,
                ),
                const SizedBox(height: 8),
                _splitRow('Payment Mode', expense.paymentMode.toDisplayLabel()),
                const SizedBox(height: 8),
                _splitRow('Expense Date', expense.expenseDate.toReadableString()),
                const SizedBox(height: 8),
                _splitRow(
                  'Created By',
                  expense.createdByProfile?.displayName ?? 'Staff',
                ),
                const SizedBox(height: 8),
                _splitRow('Refundable', expense.isRefundable ? 'Yes' : 'No'),
                const SizedBox(height: 8),
                _splitRow('GST Bill', expense.isGst ? 'Yes' : 'No'),
                if (expense.vendor != null) ...[
                  const SizedBox(height: 8),
                  _splitRow('Vendor', expense.vendor!.name),
                ],
                const SizedBox(height: 12),
                if (expense.description != null &&
                    expense.description!.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: AppRadius.brSm,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      expense.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (expense.attachmentPath != null &&
                    expense.attachmentPath!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Attachment',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.brSm,
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => openDocument(
                        dialogContext,
                        ref: ref,
                        path: expense.attachmentPath!,
                        fileName: expense.title,
                      ),
                      borderRadius: AppRadius.brSm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'View Attachment / Receipt',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new_rounded,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CLOSE'),
            ),
            if (isEditable)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showExpenseSheet(
                    dialogContext,
                    siteId: siteId,
                    firmId: firmId,
                    expenseToEdit: expense,
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('EDIT'),
              ),
          ],
        );
      },
    );
  }

  static Future<void> showExpenseSheet(
    BuildContext context, {
    required String siteId,
    required String firmId,
    Expense? expenseToEdit,
  }) {
    return showAppBottomSheet(
      context: context,
      child: ExpenseFormSheet(
        siteId: siteId,
        firmId: firmId,
        expenseToEdit: expenseToEdit,
      ),
    );
  }

  static Future<void> showEditDocumentDialog(
    BuildContext context, {
    required WidgetRef ref,
    required String siteId,
    required SiteDocument document,
  }) async {
    final formKey = GlobalKey<FormState>();
    final fileNameController = TextEditingController(text: document.fileName);
    final descriptionController = TextEditingController(
      text: document.description ?? '',
    );

    final edited = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          title: Text(
            'Edit Document Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: fileNameController,
                    decoration: const InputDecoration(
                      labelText: 'File Name *',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'File Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Details',
                      prefixIcon: Icon(Icons.description_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    if (edited == true && context.mounted) {
      try {
        final updatedDoc = SiteDocument(
          id: document.id,
          siteId: document.siteId,
          createdBy: document.createdBy,
          fileName: fileNameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          fileUrl: document.fileUrl,
          createdAt: document.createdAt,
          updatedAt: DateTime.now(),
          softDeletedAt: document.softDeletedAt,
          createdByProfile: document.createdByProfile,
        );

        await ref.read(documentActionsProvider).editDocument(updatedDoc);
        ref.invalidate(siteDocumentsProvider(siteId));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document updated successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cleanMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  static Future<void> showDocumentSheet(
    BuildContext context, {
    required String siteId,
    required String firmId,
  }) {
    return showAppBottomSheet(
      context: context,
      child: DocumentUploadSheet(siteId: siteId, firmId: firmId),
    );
  }

  static Future<void> openDocument(
    BuildContext context, {
    required WidgetRef ref,
    required String path,
    required String fileName,
  }) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Generating secure preview link for $fileName...'),
              ),
            ],
          ),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final signedUrl =
          await ref.read(storageActionsProvider).getSignedUrl(absolutePath: path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      final uri = Uri.parse(signedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $signedUrl';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  static Widget _splitRow(
    String label,
    dynamic value, {
    bool isBold = false,
  }) {
    final valueStyle = TextStyle(
      fontSize: 14,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (value is InlineSpan)
          Text.rich(
            value,
            style: valueStyle,
          )
        else
          Text(
            value.toString(),
            style: valueStyle,
          ),
      ],
    );
  }
}
