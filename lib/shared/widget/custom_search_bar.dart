import 'package:flutter/material.dart';
import 'package:site_vault/shared/theme/app_radius.dart';

/// A premium, custom unified Search Bar designed for visual consistency across
/// the KK Group Site Vault application.
///
/// Features:
/// - Smooth borders conforming strictly to the [AppRadius] centralization standards.
/// - Adaptive search icon and action states (clear search, custom filter action triggers).
/// - Modern typography and field aesthetics blending cleanly with bento grids.
class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final VoidCallback? onClear;
  final bool showClearButton;
  final VoidCallback? onFilterPressed;
  final String? filterTooltip;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search...',
    this.onClear,
    this.showClearButton = false,
    this.onFilterPressed,
    this.filterTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: AppRadius.brSm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          if (showClearButton)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (onFilterPressed != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: onFilterPressed,
              tooltip: filterTooltip ?? 'Reset Filters',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
