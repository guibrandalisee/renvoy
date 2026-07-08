import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters.dart';
import '../../../core/haptics.dart';
import '../../../core/widgets/pressable.dart';

class HeroSpendCard extends StatelessWidget {
  const HeroSpendCard({
    required this.monthlyTotalMinor,
    required this.activeCount,
    required this.monthlyView,
    required this.currencyCode,
    required this.onToggle,
    super.key,
  });

  final double monthlyTotalMinor;
  final int activeCount;
  final bool monthlyView;
  final String currencyCode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final displayMinor = monthlyView
        ? monthlyTotalMinor
        : monthlyTotalMinor * 12;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.monthlySpend,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Pressable(
                onPressed: onToggle,
                haptic: HapticType.selection,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    monthlyView ? l10n.toggleMonthly : l10n.toggleYearly,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: displayMinor),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                Money.format(
                  value.round(),
                  currencyCode,
                  locale: l10n.localeName,
                ),
                style: moneyStyle(
                  textTheme.displayLarge ??
                      const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                ).copyWith(color: colors.textPrimary),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            l10n.activeCount(activeCount),
            style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
