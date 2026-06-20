import 'package:flutter/material.dart';

class FormUtils {
  FormUtils._();

  /// Validates the form. If invalid, schedules a post-frame callback to scroll to the first invalid field.
  static bool validateAndScroll(BuildContext context, GlobalKey<FormState> formKey) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToFirstError(context);
      });
    }
    return isValid;
  }

  /// Traverses the element tree to find the first FormFieldState with an error and scrolls it into view.
  static void scrollToFirstError(BuildContext context) {
    bool scrolled = false;
    void visitor(Element element) {
      if (scrolled) return;
      if (element is StatefulElement && element.state is FormFieldState) {
        final fieldState = element.state as FormFieldState;
        if (fieldState.hasError) {
          Scrollable.ensureVisible(
            fieldState.context,
            duration: const Duration(milliseconds: 300),
            alignment: 0.2, // Scroll so the field is slightly below the top of the viewport
            curve: Curves.easeInOut,
          );
          scrolled = true;
          return;
        }
      }
      element.visitChildren(visitor);
    }

    if (context is Element) {
      context.visitChildren(visitor);
    }
  }
}
