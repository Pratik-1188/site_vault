import 'package:flutter/material.dart';
import 'package:site_vault/shared/theme/app_radius.dart';

/// A premium, reusable badge widget used to display the status of various entities
/// (Sites, Vendors, Categories, Users) in a clean and consistent Material 3 container.
class StatusBadge extends StatelessWidget {
  /// The status string (e.g. 'active', 'inactive', 'completed', 'deleted').
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLower = status.toLowerCase().trim();

    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (statusLower) {
      case 'active':
        bgColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'completed':
        bgColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        icon = Icons.done_all_rounded;
        break;
      case 'inactive':
        bgColor = theme.colorScheme.errorContainer.withValues(alpha: 0.4);
        textColor = theme.colorScheme.onErrorContainer;
        icon = Icons.remove_circle_outline_rounded;
        break;
      case 'deleted':
        bgColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        icon = Icons.delete_outline_rounded;
        break;
      default:
        bgColor = theme.colorScheme.surfaceContainer;
        textColor = theme.colorScheme.onSurfaceVariant;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.brXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
