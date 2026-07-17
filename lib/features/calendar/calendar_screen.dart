import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';
import '../../app/theme/app_typography.dart';
import '../../core/color_utils.dart';
import '../../core/formatters.dart';
import '../../core/haptics.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/status_bar_fade.dart';
import '../../core/widgets/subscription_avatar.dart';
import '../../data/db/database.dart';
import '../../domain/billing/billing_math.dart';
import '../../domain/models/group_node.dart';
import '../home/home_providers.dart';
import '../shell/app_shell.dart';
import '../subscriptions/widgets/subscription_row.dart';
import 'calendar_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final _scrollController = ScrollController();
  ShellScrollRegistry? _scrollRegistry;
  int _direction = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextRegistry = ShellScrollRegistry.maybeOf(context);
    if (_scrollRegistry != nextRegistry) {
      _scrollRegistry?.unregister(2, _scrollController);
      _scrollRegistry = nextRegistry;
      _scrollRegistry?.register(2, _scrollController);
    }
  }

  @override
  void dispose() {
    _scrollRegistry?.unregister(2, _scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() => _direction = delta.sign);
    final month = ref.read(visibleCalendarMonthProvider);
    ref.read(visibleCalendarMonthProvider.notifier).state = DateTime.utc(
      month.year,
      month.month + delta,
    );
    ref.read(selectedCalendarDayProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final month = ref.watch(visibleCalendarMonthProvider);
    final renewalMap = ref.watch(renewalMapProvider);
    final selectedDay = ref.watch(selectedCalendarDayProvider);
    final selectedRenewals = selectedDay == null
        ? null
        : renewalMap[dateOnlyUtc(selectedDay)];
    final firstDay = ref.watch(firstDayOfWeekProvider).valueOrNull ?? 1;
    final defaultCurrency =
        ref.watch(defaultCurrencyProvider).valueOrNull ?? 'USD';
    final exchangeRates = ref.watch(exchangeRatesProvider).valueOrNull;
    final groups = ref.watch(groupsTreeProvider).valueOrNull ?? const [];
    final groupPaths = buildGroupPathIndex(groups);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _Header(month: month, onChangeMonth: _changeMonth),
              ),
              SliverToBoxAdapter(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity.abs() < 200) {
                      return;
                    }
                    _changeMonth(velocity < 0 ? 1 : -1);
                  },
                  child: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: Offset(0.08 * _direction, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: _CalendarGrid(
                      key: ValueKey('${month.year}-${month.month}'),
                      month: month,
                      firstDayOfWeek: firstDay,
                      renewalMap: renewalMap,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child:
                      selectedDay != null &&
                          selectedRenewals != null &&
                          selectedRenewals.isNotEmpty
                      ? _SelectedRenewals(
                          date: selectedDay,
                          subscriptions: selectedRenewals,
                          groupPaths: groupPaths,
                        )
                      : _MonthlySummary(
                          renewalMap: renewalMap,
                          currencyCode:
                              exchangeRates?.baseCurrency ?? defaultCurrency,
                          amountsBySubscriptionId: exchangeRates == null
                              ? null
                              : {
                                  for (final subscription
                                      in renewalMap.values.expand(
                                        (items) => items,
                                      ))
                                    subscription.id: exchangeRates
                                        .convertToBase(
                                          subscription.priceMinor.toDouble(),
                                          subscription.currency,
                                        ),
                                },
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          const StatusBarFade(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.month, required this.onChangeMonth});

  final DateTime month;
  final ValueChanged<int> onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final monthLabel = Dates.monthYear(month, l10n.localeName);
    final metrics = context.metrics;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.screenGutter,
        MediaQuery.viewPaddingOf(context).top + 22,
        metrics.screenGutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.navCalendar,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MonthButton(
                icon: Icons.chevron_left_rounded,
                label: l10n.previousMonth,
                onPressed: () => onChangeMonth(-1),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: moneyStyle(
                    Theme.of(context).textTheme.titleLarge ??
                        const TextStyle(fontWeight: FontWeight.w600),
                  ).copyWith(color: colors.textPrimary),
                ),
              ),
              _MonthButton(
                icon: Icons.chevron_right_rounded,
                label: l10n.nextMonth,
                onPressed: () => onChangeMonth(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Pressable(
          onPressed: onPressed,
          haptic: HapticType.light,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends ConsumerWidget {
  const _CalendarGrid({
    required this.month,
    required this.firstDayOfWeek,
    required this.renewalMap,
    super.key,
  });

  final DateTime month;
  final int firstDayOfWeek;
  final Map<DateTime, List<Subscription>> renewalMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = _weekdayLabels(l10n.localeName, firstDayOfWeek);
    final days = _gridDays(month, firstDayOfWeek);
    final selected = ref.watch(selectedCalendarDayProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            children: weekdays
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          for (var row = 0; row < 6; row++)
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: days
                    .skip(row * 7)
                    .take(7)
                    .map(
                      (day) => Expanded(
                        child: _DayCell(
                          day: day,
                          currentMonth:
                              day.year == month.year &&
                              day.month == month.month,
                          renewals: renewalMap[dateOnlyUtc(day)] ?? const [],
                          selected: _sameDay(selected, day),
                          onPressed: () {
                            final renewals =
                                renewalMap[dateOnlyUtc(day)] ?? const [];
                            if (renewals.isEmpty) {
                              ref
                                      .read(
                                        selectedCalendarDayProvider.notifier,
                                      )
                                      .state =
                                  null;
                              return;
                            }
                            Haptics.selection();
                            ref
                                .read(selectedCalendarDayProvider.notifier)
                                .state = dateOnlyUtc(
                              day,
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.currentMonth,
    required this.renewals,
    required this.selected,
    required this.onPressed,
  });

  final DateTime day;
  final bool currentMonth;
  final List<Subscription> renewals;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final today = _sameDay(day, DateTime.now());
    final l10n = AppLocalizations.of(context)!;
    final dayColor = today
        ? colors.accent
        : currentMonth
        ? colors.textPrimary
        : colors.textMuted;
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${Dates.short(day, l10n.localeName)}, '
          '${l10n.renewalsCount(renewals.length)}',
      child: ExcludeSemantics(
        child: Pressable(
          onPressed: onPressed,
          haptic: renewals.isEmpty ? HapticType.light : HapticType.selection,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? colors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: selected
                    ? Border.all(color: colors.accent, width: 1.25)
                    : null,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: today ? colors.accentSoft : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${day.day}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: dayColor,
                                fontWeight: today
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 22,
                    child: renewals.isEmpty
                        ? const SizedBox.shrink()
                        : _RenewalIcons(
                            renewals: renewals,
                            separatorColor: selected
                                ? colors.surface
                                : colors.background,
                          ),
                  ),
                  const SizedBox(height: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RenewalIcons extends StatelessWidget {
  const _RenewalIcons({required this.renewals, required this.separatorColor});

  final List<Subscription> renewals;
  final Color separatorColor;

  static const _avatarSize = 18.0;
  static const _itemSize = 20.0;
  static const _itemStep = 12.0;

  @override
  Widget build(BuildContext context) {
    final visibleRenewals = renewals.take(renewals.length > 3 ? 2 : 3).toList();
    final hasOverflow = renewals.length > 3;
    final itemCount = visibleRenewals.length + (hasOverflow ? 1 : 0);
    final width = _itemSize + ((itemCount - 1) * _itemStep);

    return Center(
      child: SizedBox(
        width: width,
        height: _itemSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < visibleRenewals.length; index++)
              Positioned(
                left: index * _itemStep,
                child: _CalendarAvatar(
                  subscription: visibleRenewals[index],
                  separatorColor: separatorColor,
                ),
              ),
            if (hasOverflow)
              Positioned(
                left: visibleRenewals.length * _itemStep,
                child: Container(
                  width: _itemSize,
                  height: _itemSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: separatorColor, width: 1),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        '+${renewals.length - visibleRenewals.length}',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.colors.textSecondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarAvatar extends StatelessWidget {
  const _CalendarAvatar({
    required this.subscription,
    required this.separatorColor,
  });

  final Subscription subscription;
  final Color separatorColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _RenewalIcons._itemSize,
      height: _RenewalIcons._itemSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: separatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: separatorColor, width: 1),
      ),
      child: SubscriptionAvatar(
        name: subscription.name,
        iconName: subscription.iconName,
        color: colorFromHex(subscription.colorHex) ?? context.colors.accent,
        size: _RenewalIcons._avatarSize,
      ),
    );
  }
}

class _SelectedRenewals extends StatelessWidget {
  const _SelectedRenewals({
    required this.date,
    required this.subscriptions,
    required this.groupPaths,
  });

  final DateTime date;
  final List<Subscription> subscriptions;
  final Map<String, GroupPath> groupPaths;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              l10n.renewalsOn(Dates.short(date, l10n.localeName)),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          for (final subscription in subscriptions)
            SubscriptionRow(
              subscription: subscription,
              subtitle: Dates.short(date, l10n.localeName),
              groupPath: groupPaths[subscription.groupId]?.label(),
              onTap: () => context.push('/subscriptions/${subscription.id}'),
            ),
        ],
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({
    required this.renewalMap,
    required this.currencyCode,
    required this.amountsBySubscriptionId,
  });

  final Map<DateTime, List<Subscription>> renewalMap;
  final String currencyCode;
  final Map<String, double>? amountsBySubscriptionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final renewals = renewalMap.values.expand((items) => items).toList();
    final hasAllConvertedAmounts =
        amountsBySubscriptionId != null &&
        renewals.every(
          (subscription) =>
              amountsBySubscriptionId!.containsKey(subscription.id),
        );
    final total = hasAllConvertedAmounts
        ? renewals.fold<double>(
            0,
            (sum, subscription) =>
                sum + amountsBySubscriptionId![subscription.id]!,
          )
        : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                l10n.thisMonth,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
              ),
              const Spacer(),
              Text(
                total == null
                    ? '—'
                    : Money.format(
                        total.round(),
                        currencyCode,
                        locale: l10n.localeName,
                      ),
                textAlign: TextAlign.right,
                style:
                    moneyStyle(
                      Theme.of(context).textTheme.titleLarge ??
                          const TextStyle(fontSize: 18),
                    ).copyWith(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.renewalsCount(renewals.length),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

List<DateTime> _gridDays(DateTime month, int firstDayOfWeek) {
  final first = DateTime.utc(month.year, month.month);
  final offset = (first.weekday - firstDayOfWeek) % 7;
  final start = first.subtract(Duration(days: offset));
  return List.generate(42, (index) => start.add(Duration(days: index)));
}

List<String> _weekdayLabels(String locale, int firstDayOfWeek) {
  final base = DateTime.utc(2024, 1, firstDayOfWeek);
  return List.generate(
    7,
    (index) => DateFormat.E(locale).format(base.add(Duration(days: index))),
  );
}

bool _sameDay(DateTime? a, DateTime? b) {
  return a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
}
