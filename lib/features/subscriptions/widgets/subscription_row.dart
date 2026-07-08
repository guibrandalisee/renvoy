import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/color_utils.dart';
import '../../../core/formatters.dart';
import '../../../core/haptics.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/db/database.dart';
import '../../../domain/billing/billing_math.dart';
import '../../../domain/models/enums.dart';

class SubscriptionRow extends StatelessWidget {
  const SubscriptionRow({
    required this.subscription,
    required this.onTap,
    this.subtitle,
    this.showMonthlyEquivalent = false,
    this.margin = const EdgeInsets.fromLTRB(20, 0, 20, 8),
    super.key,
  });

  final Subscription subscription;
  final VoidCallback onTap;
  final String? subtitle;
  final bool showMonthlyEquivalent;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final subscriptionColor =
        colorFromHex(subscription.colorHex) ?? colors.accent;
    final nextBillDate = parseDate(subscription.nextBillDate);
    final relative = subtitle ?? Dates.relative(nextBillDate, l10n);
    final isSoon =
        relative == l10n.relativeToday || relative == l10n.relativeTomorrow;
    final trialEnd = subscription.trialEndDate == null
        ? null
        : parseDate(subscription.trialEndDate!);
    final inTrial = isInTrial(trialEnd, DateTime.now().toUtc());
    final isPaused = subscription.status == SubscriptionStatus.paused;
    final isCanceled = subscription.status == SubscriptionStatus.canceled;
    final isDimmed = isPaused || isCanceled;

    return Opacity(
      opacity: isDimmed ? 0.55 : 1,
      child: Padding(
        padding: margin,
        child: Pressable(
          onPressed: onTap,
          haptic: HapticType.light,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: subscriptionColor.withValues(alpha: 0.18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    subscription.name.characters.first.toUpperCase(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: subscriptionColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              subscription.name,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                color: colors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: isCanceled
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          if (inTrial) ...[
                            const SizedBox(width: 8),
                            _StatusChip(
                              label: l10n.trialChip,
                              background: colors.warningSoft,
                              foreground: colors.warning,
                            ),
                          ],
                          if (isPaused) ...[
                            const SizedBox(width: 8),
                            _StatusChip(
                              label: l10n.paused,
                              background: colors.warningSoft,
                              foreground: colors.warning,
                            ),
                          ],
                          if (isCanceled) ...[
                            const SizedBox(width: 8),
                            _StatusChip(
                              label: l10n.canceled,
                              background: colors.dangerSoft,
                              foreground: colors.danger,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relative,
                        style: textTheme.bodySmall?.copyWith(
                          color: isSoon ? colors.warning : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Money.format(
                        subscription.priceMinor,
                        subscription.currency,
                        locale: l10n.localeName,
                      ),
                      style:
                          moneyStyle(
                            textTheme.titleMedium ??
                                const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                          ).copyWith(
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _caption(subscription, l10n, showMonthlyEquivalent),
                      textAlign: TextAlign.right,
                      style: moneyStyle(
                        textTheme.bodySmall ?? const TextStyle(),
                      ).copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _caption(
  Subscription subscription,
  AppLocalizations l10n,
  bool showMonthlyEquivalent,
) {
  if (showMonthlyEquivalent &&
      !(subscription.cycleUnit == CycleUnit.month &&
          subscription.cycleCount == 1)) {
    final amount = Money.format(
      monthlyEquivalentMinor(
        subscription.priceMinor,
        subscription.cycleUnit,
        subscription.cycleCount,
      ).round(),
      subscription.currency,
      locale: l10n.localeName,
    );
    return l10n.approxPerMonth(amount);
  }
  return cycleLabel(subscription.cycleUnit, l10n);
}

String cycleLabel(CycleUnit unit, AppLocalizations l10n) {
  return switch (unit) {
    CycleUnit.day => l10n.cycleDay,
    CycleUnit.week => l10n.cycleWeek,
    CycleUnit.month => l10n.cycleMonth,
    CycleUnit.year => l10n.cycleYear,
  };
}

DateTime parseDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}

String dateToText(DateTime value) {
  final utc = dateOnlyUtc(value);
  return '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';
}
