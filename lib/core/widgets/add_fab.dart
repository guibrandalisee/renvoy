import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../haptics.dart';
import 'pressable.dart';

class AddFab extends StatelessWidget {
  const AddFab({required this.label, required this.onPressed, super.key});

  static const double extent = 54;

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onPressed: onPressed,
        haptic: HapticType.medium,
        pressedScale: 0.96,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: extent,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: colors.onAccent, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colors.onAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
