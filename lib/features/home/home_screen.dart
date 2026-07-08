import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/haptics.dart';
import '../../core/widgets/app_shimmer.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/status_bar_fade.dart';
import '../../data/db/database_provider.dart';
import '../../data/db/settings_keys.dart';
import 'home_providers.dart';
import 'widgets/hero_spend_card.dart';
import 'widgets/spend_by_group_card.dart';
import 'widgets/upcoming_renewal_row.dart';
import '../shell/app_shell.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  ShellScrollRegistry? _scrollRegistry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextRegistry = ShellScrollRegistry.maybeOf(context);
    if (_scrollRegistry != nextRegistry) {
      _scrollRegistry?.unregister(0, _scrollController);
      _scrollRegistry = nextRegistry;
      _scrollRegistry?.register(0, _scrollController);
    }
  }

  @override
  void dispose() {
    _scrollRegistry?.unregister(0, _scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
    final upcomingAsync = ref.watch(upcomingProvider);
    final groupsAsync = ref.watch(groupsTreeProvider);
    final monthlyView =
        ref.watch(monthlyEquivalentViewProvider).valueOrNull ?? true;
    final monthlyTotal = ref.watch(monthlyTotalMinorProvider);
    final defaultCurrency = ref.watch(defaultCurrencyProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          subscriptionsAsync.when(
            loading: () => _HomeLoading(controller: _scrollController),
            error: (_, _) => _HomeEmpty(
              controller: _scrollController,
              topPadding: MediaQuery.viewPaddingOf(context).top + 24,
            ),
            data: (subscriptions) {
              if (subscriptions.isEmpty) {
                return _HomeEmpty(
                  controller: _scrollController,
                  topPadding: MediaQuery.viewPaddingOf(context).top + 24,
                );
              }

              final upcoming = upcomingAsync.valueOrNull ?? const [];
              final groups = groupsAsync.valueOrNull ?? const [];

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _Header(now: DateTime.now())),
                  SliverToBoxAdapter(
                    child: HeroSpendCard(
                      monthlyTotalMinor: monthlyTotal,
                      activeCount: subscriptions.length,
                      monthlyView: monthlyView,
                      currencyCode: defaultCurrency.valueOrNull ?? 'USD',
                      onToggle: () async {
                        await ref
                            .read(settingsDaoProvider)
                            .setValue(
                              SettingsKeys.monthlyEquivalentView,
                              monthlyView ? 'yearly' : 'monthly',
                            );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SectionHeader(title: l10n.upcomingRenewals),
                  ),
                  SliverList.builder(
                    itemCount: upcoming.length > 5 ? 5 : upcoming.length,
                    itemBuilder: (context, index) {
                      final subscription = upcoming[index];
                      return SubscriptionRow(
                        subscription: subscription,
                        onTap: () =>
                            context.push('/subscriptions/${subscription.id}'),
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: _SectionHeader(title: l10n.spendByGroup),
                  ),
                  SliverToBoxAdapter(
                    child: SpendByGroupCard(
                      subscriptions: subscriptions,
                      groups: groups,
                      totalMonthlyMinor: monthlyTotal,
                      currencyCode: defaultCurrency.valueOrNull ?? 'USD',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
          const StatusBarFade(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final greeting = switch (now.hour) {
      < 12 => l10n.greetingMorning,
      < 18 => l10n.greetingAfternoon,
      _ => l10n.greetingEvening,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.viewPaddingOf(context).top + 24,
        20,
        0,
      ),
      child: Row(
        children: [
          Text(
            greeting,
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          const Spacer(),
          Text(
            Dates.monthYear(now, l10n.localeName),
            style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: context.colors.textPrimary),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: _Header(now: DateTime.now())),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ShimmerBox(width: double.infinity, height: 140, radius: 24),
          ),
        ),
        for (var index = 0; index < 3; index++)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ShimmerBox(width: double.infinity, height: 68, radius: 20),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty({required this.controller, required this.topPadding});

  final ScrollController controller;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: _Header(now: DateTime.now())),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: EmptyState(
              icon: Icons.subscriptions_outlined,
              title: l10n.emptyTitle,
              subtitle: l10n.emptySubtitle,
              cta: Pressable(
                onPressed: () => context.push('/subscriptions/new'),
                haptic: HapticType.selection,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.addSubscription,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: colors.onAccent),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
