import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../haptics.dart';
import 'pressable.dart';

/// The app's canonical primary action button.
///
/// Built on [Pressable] so it shares the same spring-scale press physics and
/// haptics as the rest of the UI (instead of falling back to Material's
/// `FilledButton`). Passing a `null` [onPressed] renders a dimmed, disabled
/// state; [isLoading] swaps the label for a neutral spinner.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    this.destructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// When true (default) the button stretches to fill its parent's width.
  final bool expand;
  final IconData? icon;

  /// Renders the button in the danger colour with white text.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null && !isLoading;
    final background = destructive ? colors.danger : colors.accent;
    final foreground = destructive ? const Color(0xFFFFFFFF) : colors.onAccent;

    final Widget content = isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foreground,
              strokeCap: StrokeCap.round,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Pressable(
        onPressed: enabled ? onPressed : null,
        haptic: destructive ? HapticType.warning : HapticType.selection,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          width: expand ? double.infinity : null,
          padding: expand
              ? null
              : const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: content,
        ),
      ),
    );
  }
}
