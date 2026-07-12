import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../haptics.dart';
import 'pressable.dart';

/// Shows a branded confirmation dialog that matches the rest of the app's
/// visual language (rounded elevated card, `Pressable` buttons, subtle
/// scale + fade transition) instead of falling back to a raw Material or
/// Cupertino alert. Returns `true` when the confirm action is tapped.
///
/// For destructive actions (delete/discard) the confirm button is rendered in
/// the danger colour and the cancel button becomes the calmer, default choice.
Future<bool> showConfirmDialog({
  required BuildContext context,
  String? title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
}) async {
  // Drop the keyboard first so focus doesn't jump back when the dialog closes.
  FocusManager.instance.primaryFocus?.unfocus();

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: Transform.scale(
          scale: 0.96 + (0.04 * curved.value),
          child: child,
        ),
      );
    },
  );

  return result ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
  });

  final String? title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final confirmColor = isDestructive ? colors.danger : colors.accent;
    final onConfirm = isDestructive
        ? const Color(0xFFFFFFFF)
        : colors.onAccent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DialogButton(
                    label: confirmLabel,
                    background: confirmColor,
                    foreground: onConfirm,
                    haptic: isDestructive
                        ? HapticType.warning
                        : HapticType.selection,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  const SizedBox(height: 10),
                  _DialogButton(
                    label: cancelLabel,
                    background: colors.surface,
                    foreground: colors.textPrimary,
                    border: colors.border,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.border,
    this.haptic = HapticType.selection,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback onPressed;
  final HapticType haptic;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      haptic: haptic,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: foreground,
          ),
        ),
      ),
    );
  }
}
