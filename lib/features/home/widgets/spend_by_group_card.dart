import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_metrics.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/color_utils.dart';
import '../../../core/formatters.dart';
import '../../../data/db/database.dart';
import '../../../domain/billing/billing_math.dart';
import '../../../domain/models/group_node.dart';

class SpendByGroupCard extends StatelessWidget {
  const SpendByGroupCard({
    required this.subscriptions,
    required this.groups,
    required this.totalMonthlyMinor,
    required this.currencyCode,
    super.key,
  });

  final List<Subscription> subscriptions;
  final List<GroupNode> groups;
  final double totalMonthlyMinor;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final slices = _buildSlices(context, l10n);
    final textTheme = Theme.of(context).textTheme;
    final metrics = context.metrics;
    final totalLabel = Money.format(
      totalMonthlyMinor.round(),
      currencyCode,
      locale: l10n.localeName,
    );

    return Semantics(
      container: true,
      label: l10n.spendByGroup,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: metrics.screenGutter),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(metrics.radiusContainer),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  l10n.toggleMonthly,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  totalLabel,
                  style: moneyStyle(
                    textTheme.titleMedium ?? const TextStyle(),
                  ).copyWith(color: colors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < slices.length; index++) ...[
              _SpendBar(
                slice: slices[index],
                total: totalMonthlyMinor,
                currencyCode: currencyCode,
              ),
              if (index != slices.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  List<_GroupSlice> _buildSlices(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final paths = buildGroupPathIndex(groups);
    final rootsById = {for (final node in groups) node.group.id: node};
    final totals = <String, double>{};
    final detailTotals = <String, Map<String, double>>{};

    for (final subscription in subscriptions) {
      final monthly = monthlyEquivalentMinor(
        subscription.priceMinor,
        subscription.cycleUnit,
        subscription.cycleCount,
      );
      final path = paths[subscription.groupId];
      final key = path?.root.id ?? _otherKey;
      totals[key] = (totals[key] ?? 0) + monthly;
      if (path != null) {
        final details = detailTotals.putIfAbsent(key, () => {});
        details[path.selected.id] = (details[path.selected.id] ?? 0) + monthly;
      }
    }

    if (totals.isEmpty) {
      return [
        _GroupSlice(
          label: l10n.groupOther,
          color: colors.textMuted,
          value: 1,
          children: const [],
        ),
      ];
    }

    final result = totals.entries.map((entry) {
      if (entry.key == _otherKey) {
        return _GroupSlice(
          label: l10n.groupOther,
          color: colors.textMuted,
          value: entry.value,
          children: const [],
        );
      }
      final root = rootsById[entry.key]!.group;
      final details = detailTotals[entry.key] ?? const {};
      final hasSubgroupSpend = details.keys.any((id) => id != root.id);
      final children = <_SubgroupSlice>[];
      if (hasSubgroupSpend) {
        final directSpend = details[root.id] ?? 0;
        if (directSpend > 0) {
          children.add(
            _SubgroupSlice(
              label: l10n.noSubgroup,
              color: colorFromHex(root.color) ?? colors.accent,
              value: directSpend,
            ),
          );
        }
        for (final detail in details.entries) {
          if (detail.key == root.id || detail.value <= 0) continue;
          final group = paths[detail.key]!.selected;
          children.add(
            _SubgroupSlice(
              label: group.name,
              color: colorFromHex(group.color) ?? colors.accent,
              value: detail.value,
            ),
          );
        }
        children.sort((a, b) => b.value.compareTo(a.value));
      }
      return _GroupSlice(
        label: root.name,
        color: colorFromHex(root.color) ?? colors.accent,
        value: entry.value,
        children: children,
      );
    }).toList();
    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }
}

class _SpendBar extends StatelessWidget {
  const _SpendBar({
    required this.slice,
    required this.total,
    required this.currencyCode,
  });

  final _GroupSlice slice;
  final double total;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final fraction = total <= 0 ? 0.0 : (slice.value / total).clamp(0.0, 1.0);
    final percent = (fraction * 100).round();
    final amount = Money.format(
      slice.value.round(),
      currencyCode,
      locale: l10n.localeName,
    );
    final childSemantics = slice.children
        .map((child) {
          final childAmount = Money.format(
            child.value.round(),
            currencyCode,
            locale: l10n.localeName,
          );
          return '${child.label}, $childAmount';
        })
        .join(', ');

    return Semantics(
      label: [
        '${slice.label}, $amount, $percent%',
        if (childSemantics.isNotEmpty) childSemantics,
      ].join('. '),
      child: ExcludeSemantics(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: slice.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slice.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$amount · $percent%',
                  style: moneyStyle(
                    Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
                  ).copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 7,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: colors.surfaceElevated),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fraction,
                      child: ColoredBox(color: slice.color),
                    ),
                  ],
                ),
              ),
            ),
            if (slice.children.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: colors.border)),
                ),
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < slice.children.length;
                      index++
                    ) ...[
                      _SubgroupBar(
                        slice: slice.children[index],
                        parentTotal: slice.value,
                        currencyCode: currencyCode,
                      ),
                      if (index != slice.children.length - 1)
                        const SizedBox(height: 11),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupSlice {
  const _GroupSlice({
    required this.label,
    required this.color,
    required this.value,
    required this.children,
  });

  final String label;
  final Color color;
  final double value;
  final List<_SubgroupSlice> children;
}

class _SubgroupBar extends StatelessWidget {
  const _SubgroupBar({
    required this.slice,
    required this.parentTotal,
    required this.currencyCode,
  });

  final _SubgroupSlice slice;
  final double parentTotal;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final fraction = parentTotal <= 0
        ? 0.0
        : (slice.value / parentTotal).clamp(0.0, 1.0);
    final amount = Money.format(
      slice.value.round(),
      currencyCode,
      locale: l10n.localeName,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                slice.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: moneyStyle(
                Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
              ).copyWith(color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: colors.surfaceElevated),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction,
                  child: ColoredBox(color: slice.color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SubgroupSlice {
  const _SubgroupSlice({
    required this.label,
    required this.color,
    required this.value,
  });

  final String label;
  final Color color;
  final double value;
}

const _otherKey = '__other__';
