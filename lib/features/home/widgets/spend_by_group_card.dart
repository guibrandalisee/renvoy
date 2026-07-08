import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 56,
                    sections: slices.map((slice) {
                      return PieChartSectionData(
                        value: slice.value,
                        color: slice.color,
                        radius: 22,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Text(
                  Money.format(
                    totalMonthlyMinor.round(),
                    currencyCode,
                    locale: l10n.localeName,
                  ),
                  style:
                      moneyStyle(
                        textTheme.titleMedium ??
                            const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                      ).copyWith(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 14,
              runSpacing: 10,
              children: slices.map((slice) {
                final percent = totalMonthlyMinor <= 0
                    ? 0
                    : (slice.value / totalMonthlyMinor * 100).round();
                return _LegendItem(slice: slice, percent: percent);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<_GroupSlice> _buildSlices(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final topLevelById = <String, Group>{};
    final parentByChildId = <String, Group>{};

    void visit(GroupNode node, Group topLevel) {
      topLevelById[node.group.id] = topLevel;
      for (final child in node.children) {
        parentByChildId[child.group.id] = topLevel;
        visit(child, topLevel);
      }
    }

    for (final node in groups) {
      visit(node, node.group);
    }

    final totals = <String, double>{};
    final groupLabels = <String, String>{};
    final groupColors = <String, Color>{};

    for (final node in groups) {
      groupLabels[node.group.id] = node.group.name;
      groupColors[node.group.id] =
          colorFromHex(node.group.color) ?? colors.accent;
    }

    for (final subscription in subscriptions) {
      final monthly = monthlyEquivalentMinor(
        subscription.priceMinor,
        subscription.cycleUnit,
        subscription.cycleCount,
      );
      final groupId = subscription.groupId;
      final topLevel = groupId == null
          ? null
          : topLevelById[groupId] ?? parentByChildId[groupId];
      final key = topLevel?.id ?? _otherKey;
      totals[key] = (totals[key] ?? 0) + monthly;
      if (topLevel != null) {
        groupLabels[key] = topLevel.name;
        groupColors[key] = colorFromHex(topLevel.color) ?? colors.accent;
      }
    }

    if (totals.isEmpty) {
      return [
        _GroupSlice(label: l10n.groupOther, color: colors.textMuted, value: 1),
      ];
    }

    return totals.entries.map((entry) {
      return _GroupSlice(
        label: groupLabels[entry.key] ?? l10n.groupOther,
        color: groupColors[entry.key] ?? colors.textMuted,
        value: entry.value,
      );
    }).toList();
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.slice, required this.percent});

  final _GroupSlice slice;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          slice.label,
          style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: 4),
        Text(
          '$percent%',
          style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

class _GroupSlice {
  const _GroupSlice({
    required this.label,
    required this.color,
    required this.value,
  });

  final String label;
  final Color color;
  final double value;
}

const _otherKey = '__other__';
