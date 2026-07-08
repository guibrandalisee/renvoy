import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class StatusBarFade extends StatelessWidget {
  const StatusBarFade({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.viewPaddingOf(context).top + 12;
    final colors = context.colors;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.background, colors.background.withAlpha(0)],
            ),
          ),
        ),
      ),
    );
  }
}
