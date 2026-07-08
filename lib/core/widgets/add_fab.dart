import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../haptics.dart';
import 'pressable.dart';

class AddFab extends StatelessWidget {
  const AddFab({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      haptic: HapticType.medium,
      pressedScale: 0.94,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
        child: Icon(Icons.add, color: colors.onAccent, size: 26),
      ),
    );
  }
}
