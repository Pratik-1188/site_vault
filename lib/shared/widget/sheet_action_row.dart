import 'package:flutter/material.dart';

/// A premium, reusable bottom action row for forms inside modal sheets.
///
/// Enforces consistent alignment, Cancel/Submit hierarchy, progress spinner,
/// and disabling interaction during submissions.
class SheetActionRow extends StatelessWidget {
  /// Whether the form is currently submitting, which shows the button spinner and disables controls.
  final bool isSubmitting;

  /// Callback when the submit button is pressed. If null, the button is disabled.
  final VoidCallback? onSubmit;

  /// The text label displayed on the submit button.
  final String submitLabel;

  /// The text label displayed on the cancel button. Defaults to 'Cancel'.
  final String cancelLabel;

  /// Optional callback when the cancel button is pressed.
  /// If null, defaults to `Navigator.pop(context)`.
  final VoidCallback? onCancel;

  const SheetActionRow({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
    required this.submitLabel,
    this.cancelLabel = 'Cancel',
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isSubmitting ? null : (onCancel ?? () => Navigator.pop(context)),
          child: Text(cancelLabel),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: isSubmitting ? null : onSubmit,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(submitLabel),
        ),
      ],
    );
  }
}
