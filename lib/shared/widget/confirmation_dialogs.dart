import 'package:flutter/material.dart';
import 'package:site_vault/shared/theme/app_radius.dart';

/// Centralized confirmation dialogs manager.
/// Enforces a unified confirmation UX policy across the application.
class ConfirmationDialogs {
  /// A standard confirmation dialog (Normal confirmation).
  ///
  /// Returns [true] if confirmed, [false] otherwise.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'CONFIRM',
    String cancelLabel = 'CANCEL',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel.toUpperCase()),
          ),
          if (isDestructive)
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(confirmLabel.toUpperCase()),
            )
          else
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel.toUpperCase()),
            ),
        ],
      ),
    );
    return result ?? false;
  }

  /// A pre-commit review dialog displaying key-value fields.
  ///
  /// Returns [true] if confirmed, [false] otherwise.
  static Future<bool> confirmReview(
    BuildContext context, {
    required String title,
    required String message,
    required Map<String, String> fields,
    String confirmLabel = 'CONFIRM',
    String cancelLabel = 'CANCEL',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.brSm,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: fields.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(entry.value),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel.toUpperCase()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel.toUpperCase()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// A strong confirmation dialog requiring the user to type the expected match.
  ///
  /// Returns [true] if typed correctly and confirmed, [false] otherwise.
  static Future<bool> confirmStrong(
    BuildContext context, {
    required String title,
    required String message,
    required String expectedMatch,
    String promptText = 'To confirm, type the name of the item below:',
    String confirmLabel = 'CONFIRM',
    String cancelLabel = 'CANCEL',
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isMatch = controller.text.trim().toLowerCase() == expectedMatch.trim().toLowerCase();
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    Text(
                      promptText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      expectedMatch,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Type exactly to confirm',
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(cancelLabel.toUpperCase()),
                ),
                TextButton(
                  onPressed: isMatch ? () => Navigator.pop(context, true) : null,
                  style: TextButton.styleFrom(
                    foregroundColor: isMatch ? Theme.of(context).colorScheme.error : Colors.grey,
                  ),
                  child: Text(confirmLabel.toUpperCase()),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    return result ?? false;
  }
}
