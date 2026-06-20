import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/theme/app_padding.dart';

/// A premium, reusable modal bottom sheet wrapper that provides a consistent layout,
/// image blur backdrop filter, keyboard padding, safe area, and optional Form wrapper.
class AppBottomSheet extends StatelessWidget {
  /// The title of the bottom sheet, displayed in the sticky header.
  final String title;

  /// The scrollable body content.
  final Widget child;

  /// Optional form key to wrap the bottom sheet content in a Form widget.
  final GlobalKey<FormState>? formKey;

  /// Callback when the close button is pressed. If null and [canClose] is true,
  /// it will pop the route.
  final VoidCallback? onClose;

  /// Whether the close button is enabled. If false, the close button is disabled (e.g. during saving/uploading).
  final bool canClose;

  /// Optional max height constraint as a fraction of screen height. Defaults to 0.85.
  final double maxHeightFraction;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.formKey,
    this.onClose,
    this.canClose = true,
    this.maxHeightFraction = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sticky Header
        Padding(
          padding: AppPadding.sheetHeader,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: canClose ? (onClose ?? () => Navigator.pop(context)) : null,
              ),
            ],
          ),
        ),
        const Divider(height: 24, indent: 24, endIndent: 24),
        // Scrollable body
        Flexible(
          child: SingleChildScrollView(
            padding: AppPadding.sheetBody,
            child: child,
          ),
        ),
      ],
    );

    if (formKey != null) {
      content = Form(
        key: formKey,
        child: content,
      );
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * maxHeightFraction,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.verticalMd,
          child: Padding(
            padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
            child: SafeArea(
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to display the standardized [AppBottomSheet].
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (_) => child,
  );
}
