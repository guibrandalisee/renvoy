import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/haptics.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/status_bar_fade.dart';
import '../../../data/db/database.dart';
import '../../../domain/models/enums.dart';
import '../../shell/app_shell.dart';
import '../widgets/subscription_row.dart';
import 'subscriptions_list_providers.dart';

class SubscriptionsListScreen extends ConsumerStatefulWidget {
  const SubscriptionsListScreen({super.key});

  @override
  ConsumerState<SubscriptionsListScreen> createState() =>
      _SubscriptionsListScreenState();
}

class _SubscriptionsListScreenState
    extends ConsumerState<SubscriptionsListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(const Duration(milliseconds: 250));
  ShellScrollRegistry? _scrollRegistry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextRegistry = ShellScrollRegistry.maybeOf(context);
    if (_scrollRegistry != nextRegistry) {
      _scrollRegistry?.unregister(1, _scrollController);
      _scrollRegistry = nextRegistry;
      _scrollRegistry?.register(1, _scrollController);
    }
  }

  @override
  void dispose() {
    _scrollRegistry?.unregister(1, _scrollController);
    _debouncer.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final all = ref.watch(subscriptionsListProvider).valueOrNull ?? [];
    final filtered = ref.watch(filteredSubscriptionsProvider);
    final search = ref.watch(subscriptionSearchProvider);
    final status = ref.watch(subscriptionStatusFilterProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _Header(onGroups: () => context.push('/groups')),
              ),
              SliverToBoxAdapter(
                child: _SearchField(
                  controller: _searchController,
                  onChanged: (value) => _debouncer.run(
                    () => ref.read(subscriptionSearchProvider.notifier).state =
                        value,
                  ),
                  onClear: () {
                    _searchController.clear();
                    ref.read(subscriptionSearchProvider.notifier).state = '';
                    setState(() {});
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: _FilterRow()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (all.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
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
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: colors.onAccent),
                        ),
                      ),
                    ),
                  ),
                )
              else if (filtered.isEmpty || search.isNotEmpty || status != null)
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: l10n.noResults,
                      subtitle: l10n.noResultsSubtitle,
                    ),
                  )
                else
                  _SubscriptionSliverList(subscriptions: filtered)
              else
                _SubscriptionSliverList(subscriptions: filtered),
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
  const _Header({required this.onGroups});

  final VoidCallback onGroups;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
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
            l10n.navSubscriptions,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: colors.textPrimary),
          ),
          const Spacer(),
          Pressable(
            onPressed: onGroups,
            haptic: HapticType.light,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_outlined,
                size: 20,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: widget.controller,
        onChanged: (value) {
          setState(() {});
          widget.onChanged(value);
        },
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: Icon(Icons.search, size: 20, color: colors.textMuted),
          suffixIcon: widget.controller.text.isEmpty
              ? null
              : Center(
                  widthFactor: 1,
                  child: Pressable(
                    onPressed: widget.onClear,
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
          filled: true,
          fillColor: colors.surface,
          hintStyle: TextStyle(color: colors.textMuted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.accent),
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedStatus = ref.watch(subscriptionStatusFilterProvider);
    final sort = ref.watch(subscriptionSortProvider);
    final statuses = <SubscriptionStatus?>[
      null,
      SubscriptionStatus.active,
      SubscriptionStatus.paused,
      SubscriptionStatus.canceled,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 20),
          for (final status in statuses) ...[
            _Chip(
              label: _statusLabel(status, l10n),
              selected: selectedStatus == status,
              onPressed: () {
                Haptics.selection();
                ref.read(subscriptionStatusFilterProvider.notifier).state =
                    status;
              },
            ),
            const SizedBox(width: 8),
          ],
          _Dot(),
          const SizedBox(width: 8),
          _Chip(
            label: _sortLabel(sort, l10n),
            selected: false,
            icon: Icons.swap_vert,
            onPressed: () => _showSortSheet(context, ref, sort),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      haptic: HapticType.selection,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.accentSoft : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? colors.accent : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? colors.accent : colors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? colors.accent : colors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SubscriptionSliverList extends StatelessWidget {
  const _SubscriptionSliverList({required this.subscriptions});

  final List<Subscription> subscriptions;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return SubscriptionRow(
          subscription: subscription,
          showMonthlyEquivalent: true,
          onTap: () => context.push('/subscriptions/${subscription.id}'),
        );
      },
    );
  }
}

Future<void> _showSortSheet(
  BuildContext context,
  WidgetRef ref,
  SubscriptionSort selected,
) async {
  final l10n = AppLocalizations.of(context)!;
  final picked = await showAppSheet<SubscriptionSort>(
    context: context,
    title: l10n.sortBy,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: SubscriptionSort.values
          .map(
            (sort) => _SortRow(
              sort: sort,
              selected: sort == selected,
              label: _sortLabel(sort, l10n),
            ),
          )
          .toList(),
    ),
  );
  if (picked != null) {
    ref.read(subscriptionSortProvider.notifier).state = picked;
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({
    required this.sort,
    required this.selected,
    required this.label,
  });

  final SubscriptionSort sort;
  final bool selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: () => Navigator.of(context).pop(sort),
      haptic: HapticType.selection,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: colors.accent),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(SubscriptionStatus? status, AppLocalizations l10n) {
  return switch (status) {
    null => l10n.all,
    SubscriptionStatus.active => l10n.active,
    SubscriptionStatus.paused => l10n.paused,
    SubscriptionStatus.canceled => l10n.canceled,
  };
}

String _sortLabel(SubscriptionSort sort, AppLocalizations l10n) {
  return switch (sort) {
    SubscriptionSort.nextRenewal => l10n.sortNextRenewal,
    SubscriptionSort.price => l10n.sortPrice,
    SubscriptionSort.name => l10n.sortName,
  };
}
