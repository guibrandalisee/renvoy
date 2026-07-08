import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/color_utils.dart';
import '../../../core/formatters.dart';
import '../../../core/haptics.dart';
import '../../../core/widgets/app_progress.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/status_bar_fade.dart';
import '../../../data/db/database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/notifications/reminder_scheduler.dart';
import '../../../domain/billing/billing_math.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/group_node.dart';
import '../../home/home_providers.dart';

final _subscriptionProvider = StreamProvider.family<Subscription?, String>((
  ref,
  id,
) {
  return ref.watch(subscriptionsDaoProvider).watchById(id);
});

final _priceHistoryProvider =
    StreamProvider.family<List<PriceHistoryData>, String>((ref, id) {
      return ref.watch(priceHistoryDaoProvider).watchForSubscription(id);
    });

class SubscriptionDetailScreen extends ConsumerWidget {
  const SubscriptionDetailScreen({required this.subscriptionId, super.key});

  final String subscriptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(_subscriptionProvider(subscriptionId));
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          subscriptionAsync.when(
            loading: () => const Center(child: AppProgress()),
            error: (_, _) => const Center(child: AppProgress()),
            data: (subscription) {
              if (subscription == null) {
                return const Center(child: AppProgress());
              }
              final groups =
                  ref.watch(groupsTreeProvider).valueOrNull ?? const [];
              final history =
                  ref
                      .watch(_priceHistoryProvider(subscription.id))
                      .valueOrNull ??
                  const <PriceHistoryData>[];
              final currency =
                  ref.watch(defaultCurrencyProvider).valueOrNull ??
                  subscription.currency;
              return _DetailContent(
                subscription: subscription,
                groups: groups,
                history: history,
                displayCurrency: currency,
              );
            },
          ),
          const StatusBarFade(),
        ],
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({
    required this.subscription,
    required this.groups,
    required this.history,
    required this.displayCurrency,
  });

  final Subscription subscription;
  final List<GroupNode> groups;
  final List<PriceHistoryData> history;
  final String displayCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final group = _findGroup(groups, subscription.groupId);
    final subColor = colorFromHex(subscription.colorHex) ?? colors.accent;
    final monthly = monthlyEquivalentMinor(
      subscription.priceMinor,
      subscription.cycleUnit,
      subscription.cycleCount,
    );
    final trialDate = subscription.trialEndDate == null
        ? null
        : _parseDate(subscription.trialEndDate!);
    final trialActive =
        trialDate != null && dateOnlyUtc(DateTime.now()).isBefore(trialDate);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.viewPaddingOf(context).top + 12,
              20,
              0,
            ),
            child: Row(
              children: [
                Pressable(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                  borderRadius: BorderRadius.circular(999),
                  child: _CircleButton(icon: Icons.chevron_left),
                ),
                const Spacer(),
                Pressable(
                  onPressed: () =>
                      context.push('/subscriptions/${subscription.id}/edit'),
                  borderRadius: BorderRadius.circular(999),
                  child: _CircleButton(icon: Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (subscription.iconName ?? subscription.name.substring(0, 1))
                        .toUpperCase(),
                    style: textTheme.headlineMedium?.copyWith(
                      color: subColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subscription.name,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group?.name ?? l10n.noGroup,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Money.format(
                    subscription.priceMinor,
                    subscription.currency,
                    locale: l10n.localeName,
                  ),
                  style: moneyStyle(
                    textTheme.displayLarge ??
                        const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                  ).copyWith(color: colors.textPrimary),
                ),
                if (subscription.cycleUnit != CycleUnit.month ||
                    subscription.cycleCount != 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      l10n.approxPerMonth(
                        Money.format(
                          monthly.round(),
                          displayCurrency,
                          locale: l10n.localeName,
                        ),
                      ),
                      style: moneyStyle(
                        textTheme.bodySmall ?? const TextStyle(),
                      ).copyWith(color: colors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (subscription.status == SubscriptionStatus.paused || trialActive)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: subscription.status == SubscriptionStatus.paused
                    ? colors.warningSoft
                    : colors.accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    subscription.status == SubscriptionStatus.paused
                        ? Icons.pause_circle
                        : Icons.card_giftcard,
                    size: 18,
                    color: subscription.status == SubscriptionStatus.paused
                        ? colors.warning
                        : colors.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subscription.status == SubscriptionStatus.paused
                          ? l10n.pausedNotCounted
                          : l10n.trialEndsDate(
                              Dates.short(trialDate!, l10n.localeName),
                            ),
                      style: textTheme.bodyMedium?.copyWith(
                        color: subscription.status == SubscriptionStatus.paused
                            ? colors.warning
                            : colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(child: _InfoCard(subscription: subscription)),
        if (history.isNotEmpty)
          SliverToBoxAdapter(
            child: _PriceHistoryCard(
              history: history,
              currency: subscription.currency,
            ),
          ),
        SliverToBoxAdapter(child: _ActionsSection(subscription: subscription)),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nextDate = _parseDate(subscription.nextBillDate);
    final rows = <Widget>[
      _InfoRow(
        label: l10n.nextRenewal,
        value:
            '${Dates.short(nextDate, l10n.localeName)}  ${Dates.relative(nextDate, l10n)}',
      ),
      _InfoRow(
        label: l10n.billingCycle,
        value: _cycleLabel(context, subscription),
      ),
      _InfoRow(
        label: l10n.firstBill,
        value: Dates.short(
          _parseDate(subscription.firstBillDate),
          l10n.localeName,
        ),
      ),
      if ((subscription.paymentMethod ?? '').isNotEmpty)
        _InfoRow(label: l10n.paymentMethod, value: subscription.paymentMethod!),
      if ((subscription.notes ?? '').isNotEmpty)
        _InfoRow(
          label: l10n.notes,
          value: subscription.notes!,
          multiline: true,
        ),
      if ((subscription.manageUrl ?? '').isNotEmpty)
        _InfoRow(
          label: l10n.manageSubscription,
          value: subscription.manageUrl!,
          pressable: true,
          onPressed: () async {
            final uri = Uri.tryParse(subscription.manageUrl!);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
    ];

    return _Card(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index != rows.length - 1) const _Divider(),
          ],
        ],
      ),
    );
  }
}

class _PriceHistoryCard extends StatelessWidget {
  const _PriceHistoryCard({required this.history, required this.currency});

  final List<PriceHistoryData> history;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return _Card(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.priceHistory,
              style: textTheme.titleMedium?.copyWith(color: colors.textPrimary),
            ),
          ),
          const _Divider(),
          for (final entry in history)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Dates.short(
                        DateTime.fromMillisecondsSinceEpoch(
                          entry.changedAt,
                          isUtc: true,
                        ),
                        l10n.localeName,
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    Money.format(
                      entry.oldPriceMinor,
                      currency,
                      locale: l10n.localeName,
                    ),
                    style: moneyStyle(
                      textTheme.bodyMedium ?? const TextStyle(),
                    ).copyWith(color: colors.textSecondary),
                  ),
                  Icon(Icons.arrow_forward, size: 16, color: colors.textMuted),
                  Text(
                    Money.format(
                      entry.newPriceMinor,
                      currency,
                      locale: l10n.localeName,
                    ),
                    style: moneyStyle(textTheme.bodyMedium ?? const TextStyle())
                        .copyWith(
                          color: entry.newPriceMinor > entry.oldPriceMinor
                              ? colors.danger
                              : colors.success,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionsSection extends ConsumerWidget {
  const _ActionsSection({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final paused = subscription.status == SubscriptionStatus.paused;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          _ActionRow(
            icon: paused
                ? Icons.play_circle_outline
                : Icons.pause_circle_outline,
            label: paused ? l10n.resume : l10n.pause,
            color: colors.textPrimary,
            onPressed: () async {
              await Haptics.medium();
              await ref
                  .read(subscriptionsDaoProvider)
                  .setStatus(
                    subscription.id,
                    paused
                        ? SubscriptionStatus.active
                        : SubscriptionStatus.paused,
                  );
              fireAndForgetReminderResync(ref, l10n: l10n);
            },
          ),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.copy_outlined,
            label: l10n.duplicate,
            color: colors.textPrimary,
            onPressed: () async {
              await ref
                  .read(subscriptionsDaoProvider)
                  .duplicate(subscription.id);
              fireAndForgetReminderResync(ref, l10n: l10n);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.duplicated)));
                context.go('/subscriptions');
              }
            },
          ),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.cancel_outlined,
            label: l10n.cancelSubscription,
            color: colors.warning,
            onPressed: () async {
              final confirmed = await _confirm(
                context,
                title: l10n.cancelSubscription,
                message: l10n.cancelSubscriptionMessage,
                action: l10n.cancelSubscription,
              );
              if (confirmed) {
                await ref
                    .read(subscriptionsDaoProvider)
                    .setStatus(subscription.id, SubscriptionStatus.canceled);
                fireAndForgetReminderResync(ref, l10n: l10n);
              }
            },
          ),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.delete_outline,
            label: l10n.delete,
            color: colors.danger,
            onPressed: () async {
              final confirmed = await _confirm(
                context,
                title: l10n.delete,
                message: l10n.deleteSubscriptionMessage,
                action: l10n.delete,
              );
              if (!confirmed) {
                return;
              }
              await Haptics.warning();
              await ref
                  .read(subscriptionsDaoProvider)
                  .softDelete(subscription.id);
              fireAndForgetReminderResync(ref, l10n: l10n);
              if (context.mounted) {
                context.go('/subscriptions');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 5),
                    content: Text(l10n.deleted),
                    action: SnackBarAction(
                      label: l10n.undo,
                      onPressed: () async {
                        await ref
                            .read(subscriptionsDaoProvider)
                            .restore(subscription.id);
                        fireAndForgetReminderResync(ref, l10n: l10n);
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.multiline = false,
    this.pressable = false,
    this.onPressed,
  });

  final String label;
  final String value;
  final bool multiline;
  final bool pressable;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final row = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium?.copyWith(
                color: pressable ? colors.accent : colors.textPrimary,
              ),
            ),
          ),
          if (pressable) ...[
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 16, color: colors.accent),
          ],
        ],
      ),
    );
    if (!pressable) {
      return row;
    }
    return Pressable(onPressed: onPressed, child: row);
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.margin});

  final Widget child;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: colors.textPrimary),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: context.colors.border);
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async {
  final l10n = AppLocalizations.of(context)!;
  return await showAdaptiveDialog<bool>(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.keep),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.danger,
                foregroundColor: context.colors.onAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;
}

String _cycleLabel(BuildContext context, Subscription subscription) {
  final l10n = AppLocalizations.of(context)!;
  if (subscription.cycleUnit == CycleUnit.week &&
      subscription.cycleCount == 1) {
    return l10n.weekly;
  }
  if (subscription.cycleUnit == CycleUnit.month &&
      subscription.cycleCount == 1) {
    return l10n.monthly;
  }
  if (subscription.cycleUnit == CycleUnit.month &&
      subscription.cycleCount == 3) {
    return l10n.quarterly;
  }
  if (subscription.cycleUnit == CycleUnit.month &&
      subscription.cycleCount == 6) {
    return l10n.semiAnnual;
  }
  if (subscription.cycleUnit == CycleUnit.year &&
      subscription.cycleCount == 1) {
    return l10n.yearly;
  }
  final unit = switch (subscription.cycleUnit) {
    CycleUnit.day => l10n.days,
    CycleUnit.week => l10n.weeks,
    CycleUnit.month => l10n.months,
    CycleUnit.year => l10n.years,
  };
  return l10n.everyCountUnit(subscription.cycleCount, unit);
}

DateTime _parseDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}

Group? _findGroup(List<GroupNode> nodes, String? id) {
  if (id == null) {
    return null;
  }
  for (final node in nodes) {
    if (node.group.id == id) {
      return node.group;
    }
    final child = _findGroup(node.children, id);
    if (child != null) {
      return child;
    }
  }
  return null;
}
