import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_metrics.dart';
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
    final formattedAmount = Money.format(
      displayMinor.round(),
      currencyCode,
      locale: l10n.localeName,
    );
    final metrics = context.metrics;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          metrics.screenGutter,
          metrics.spaceGroup,
          metrics.screenGutter,
          0,
        ),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        decoration: BoxDecoration(
          color: colors.heroSurface,
          borderRadius: BorderRadius.circular(metrics.radiusHero),
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
                      color: colors.onHeroMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: monthlyView ? l10n.toggleMonthly : l10n.toggleYearly,
                  excludeSemantics: true,
                  child: Pressable(
                    onPressed: onToggle,
                    haptic: HapticType.selection,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.brandWarmSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.brandWarm.withValues(alpha: 0.35),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        monthlyView ? l10n.toggleMonthly : l10n.toggleYearly,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onHero,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Semantics(
              label: formattedAmount,
              excludeSemantics: true,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: displayMinor),
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Money.format(
                        value.round(),
                        currencyCode,
                        locale: l10n.localeName,
                      ),
                      maxLines: 1,
                      style: moneyStyle(
                        textTheme.displayLarge ??
                            const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                            ),
                      ).copyWith(color: colors.onHero),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 18,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colors.brandWarm,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.activeCount(activeCount),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onHeroMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
