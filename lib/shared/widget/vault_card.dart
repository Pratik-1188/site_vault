import 'package:flutter/material.dart';
import 'package:site_vault/shared/theme/app_radius.dart';
import 'package:site_vault/shared/utils/date_formatter.dart';

/// A premium, reusable Material 3 card widget used to display Audit Logs,
/// Expenses, and Documents inside KK Group Site Vault.
///
/// Features:
/// - Top Left: Display of the creator/updater name (or null).
/// - Top Right: Display of the formatted creation date-time using [toReadableDateTimeString].
/// - Click Behavior: InkWell interactive ripple triggering [onTap] (if provided).
/// - Non-clickable logs: Automatically disables ripple if [onTap] is omitted.
class VaultCard extends StatelessWidget {
  /// The creator name (e.g. changed_by, created_by). Can be null.
  final String? creatorName;

  /// The timestamp (created_at).
  final DateTime? createdAt;

  /// The leading widget (e.g., category icon or document avatar).
  final Widget? leading;

  /// The primary title text or widget.
  final Widget title;

  /// The secondary description or subtitle widget.
  final Widget? subtitle;

  /// The trailing action or metadata widget (e.g. expense amount, popup menu).
  final Widget? trailing;

  /// Optional additional content displayed when the card is expanded (for expenses details).
  final Widget? expandedContent;

  /// Click interaction handler. If null, the card remains static and non-clickable (standard for logs).
  final VoidCallback? onTap;

  const VaultCard({
    super.key,
    this.creatorName,
    this.createdAt,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.expandedContent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClickable = onTap != null;

    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Metadata Header (Name & Created At date-time)
          if ((creatorName != null && creatorName!.trim().isNotEmpty) || createdAt != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Left: Creator / Changer Name
                if (creatorName != null && creatorName!.trim().isNotEmpty)
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            creatorName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Top Right: Date Time Timestamp
                if (createdAt != null)
                  Text(
                    createdAt!.toReadableDateTimeString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
          ],

          // 2. Main Row Content (Leading widget, titles, and trailing widget)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),

          // 3. Optional Expanded Body Content (Used for popups / detail cards)
          if (expandedContent != null) ...[
            const SizedBox(height: 12),
            expandedContent!,
          ],
        ],
      ),
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.brMd,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: isClickable
          ? InkWell(
              onTap: onTap,
              borderRadius: AppRadius.brMd,
              child: content,
            )
          : content,
    );
  }
}
