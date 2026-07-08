import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppProgress extends StatelessWidget {
  const AppProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: context.colors.textMuted,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
