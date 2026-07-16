import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.cta,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(icon, color: colors.accent, size: 34)),
            const SizedBox(height: 12),
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: colors.brandWarm,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (cta != null) ...[
              const SizedBox(height: 20),
              IntrinsicWidth(child: cta!),
            ],
          ],
        ),
      ),
    );
  }
}
