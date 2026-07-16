import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';
import '../../core/formatters.dart';
import '../../core/widgets/app_shimmer.dart';
import '../../core/widgets/empty_state.dart';
import '../subscriptions/catalog/catalog_picker_sheet.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_bar_fade.dart';
import '../../data/db/database_provider.dart';
import '../../data/db/settings_keys.dart';
import '../../domain/models/group_node.dart';
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
            error: (_, _) => _HomeError(
              controller: _scrollController,
              onRetry: () => ref.invalidate(activeSubscriptionsProvider),
            ),
            data: (subscriptions) {
              if (subscriptions.isEmpty) {
                return _HomeEmpty(controller: _scrollController);
              }

              final upcoming = upcomingAsync.valueOrNull ?? const [];
              final groups = groupsAsync.valueOrNull ?? const [];
              final groupPaths = buildGroupPathIndex(groups);

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
                  SliverToBoxAdapter(
                    child: _SectionHeader(title: l10n.upcomingRenewals),
                  ),
                  SliverList.builder(
                    itemCount: upcoming.length > 5 ? 5 : upcoming.length,
                    itemBuilder: (context, index) {
                      final subscription = upcoming[index];
                      return SubscriptionRow(
                        subscription: subscription,
                        groupPath: groupPaths[subscription.groupId]?.label(),
                        onTap: () =>
                            context.push('/subscriptions/${subscription.id}'),
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: shellBottomContentPadding(
                        context,
                        clearFloatingAction: true,
                      ),
                    ),
                  ),
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
    final metrics = context.metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.screenGutter,
        MediaQuery.viewPaddingOf(context).top + 22,
        metrics.screenGutter,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              greeting,
              maxLines: 2,
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.brandWarm,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Dates.monthYear(now, l10n.localeName),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.screenGutter,
        metrics.spaceSection,
        metrics.screenGutter,
        metrics.spaceContent,
      ),
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
        SliverToBoxAdapter(
          child: SizedBox(
            height: shellBottomContentPadding(
              context,
              clearFloatingAction: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: _Header(now: DateTime.now())),
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.subscriptions_outlined,
            title: l10n.emptyTitle,
            subtitle: l10n.emptySubtitle,
            cta: PrimaryButton(
              label: l10n.addSubscription,
              expand: false,
              icon: Icons.add_rounded,
              onPressed: () => showCatalogPickerAndOpenForm(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.controller, required this.onRetry});

  final ScrollController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: _Header(now: DateTime.now())),
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.sync_problem_rounded,
            title: l10n.homeLoadError,
            subtitle: l10n.homeLoadErrorSubtitle,
            cta: PrimaryButton(
              label: l10n.tryAgain,
              expand: false,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}
