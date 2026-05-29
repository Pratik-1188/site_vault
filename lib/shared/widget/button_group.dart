import 'package:flutter/material.dart';
import 'package:site_vault/shared/theme/app_radius.dart';

/// A single option configuration for the [ButtonGroup].
class ButtonGroupOption<T> {
  final T value;
  final String label;

  const ButtonGroupOption({
    required this.value,
    required this.label,
  });
}

/// A highly polished, custom animated sliding button group widget.
///
/// This widget provides a premium selection mechanism, replacing standard
/// segmented buttons with a modern, smooth sliding selection transition.
class ButtonGroup<T> extends StatelessWidget {
  final List<ButtonGroupOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double height;

  const ButtonGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = options.indexWhere((option) => option.value == selectedValue);

    // Calculate active alignment for the sliding indicator
    // alignmentX goes from -1.0 (far left) to 1.0 (far right)
    double alignmentX = 0.0;
    if (options.length > 1 && selectedIndex != -1) {
      alignmentX = -1.0 + (selectedIndex / (options.length - 1)) * 2.0;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.brSm,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          // Premium sliding indicator
          if (selectedIndex != -1)
            AnimatedAlign(
              alignment: Alignment(alignmentX, 0),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              child: FractionallySizedBox(
                widthFactor: 1 / options.length,
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: AppRadius.brXs,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Interactive option items
          Row(
            children: List.generate(options.length, (index) {
              final option = options[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isSelected) {
                      onSelected(option.value);
                    }
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                      child: Text(
                        option.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
