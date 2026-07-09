import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Shows a confirmation dialog that looks native on each platform:
/// a [CupertinoAlertDialog] on iOS/macOS and a Material [AlertDialog]
/// elsewhere. Returns `true` when the confirm action is tapped.
///
/// For destructive actions (delete/discard) the confirm button is rendered in
/// red and the cancel button becomes the bold default, matching the platform
/// conventions.
Future<bool> showConfirmDialog({
  required BuildContext context,
  String? title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
}) async {
  final platform = Theme.of(context).platform;
  final useCupertino =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (dialogContext) {
      if (useCupertino) {
        return CupertinoAlertDialog(
          title: title == null ? null : Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: isDestructive,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              isDefaultAction: !isDestructive,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      }

      final colors = dialogContext.colors;
      return AlertDialog(
        title: title == null ? null : Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: colors.danger,
                    foregroundColor: colors.onAccent,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
