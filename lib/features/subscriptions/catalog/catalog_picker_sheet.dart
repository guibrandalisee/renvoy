import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/color_utils.dart';
import '../../../core/haptics.dart';
import '../../../core/text_normalize.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/subscription_avatar.dart';
import '../../../data/catalog/catalog_models.dart';
import '../../../data/catalog/catalog_repository.dart';
import '../../../domain/catalog/group_matcher.dart';
import '../../home/home_providers.dart';
import '../edit/subscription_form_screen.dart';

Future<void> showCatalogPickerAndOpenForm(BuildContext context) async {
  final result = await showAppSheet<_CatalogPickerResult>(
    context: context,
    title: AppLocalizations.of(context)!.catalogPickerTitle,
    child: const _CatalogPicker(),
  );
  if (!context.mounted || result == null) return;
  context.push('/subscriptions/new', extra: result.prefill);
}

class _CatalogPickerResult {
  const _CatalogPickerResult({this.prefill});

  final SubscriptionFormPrefill? prefill;
}

class _CatalogPicker extends ConsumerStatefulWidget {
  const _CatalogPicker();

  @override
  ConsumerState<_CatalogPicker> createState() => _CatalogPickerState();
}

class _CatalogPickerState extends ConsumerState<_CatalogPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final services = ref.watch(catalogServicesProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: l10n.catalogSearchHint,
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CustomServiceRow(onPressed: _openCustom),
          const SizedBox(height: 4),
          Expanded(
            child: services.when(
              loading: _CatalogLoading.new,
              error: (_, _) => _CatalogError(
                onRetry: () => ref.invalidate(catalogServicesProvider),
              ),
              data: (items) {
                final query = normalizeForSearch(_query);
                final filtered = items.where((service) {
                  return normalizeForSearch(service.name).contains(query) ||
                      normalizeForSearch(service.slug).contains(query);
                }).toList();
                if (filtered.isEmpty) return const _CatalogEmpty();
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _CatalogServiceRow(
                    service: filtered[index],
                    onPressed: () => _openService(filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openCustom() {
    Navigator.of(context).pop(const _CatalogPickerResult());
  }

  Future<void> _openService(CatalogService service) async {
    await Haptics.light();
    final groups = await ref.read(groupsTreeProvider.future);
    if (!mounted) return;
    Navigator.of(context).pop(
      _CatalogPickerResult(
        prefill: SubscriptionFormPrefill(
          name: service.name,
          serviceSlug: service.slug,
          iconName: service.iconSlug == null
              ? 'fav:${service.domain}'
              : 'si:${service.iconSlug}',
          colorHex: service.color,
          manageUrl: service.manageUrl,
          groupId: matchCatalogServiceGroupId(service, groups),
        ),
      ),
    );
  }
}

class _CustomServiceRow extends StatelessWidget {
  const _CustomServiceRow({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      haptic: HapticType.light,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accentSoft,
              ),
              child: Icon(Icons.add, color: colors.accent),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.catalogCreateCustom,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogServiceRow extends StatelessWidget {
  const _CatalogServiceRow({required this.service, required this.onPressed});
  final CatalogService service;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = colorFromHex(service.color) ?? colors.accent;
    final iconName = service.iconSlug == null
        ? 'fav:${service.domain}'
        : 'si:${service.iconSlug}';
    return Pressable(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SubscriptionAvatar(
              name: service.name,
              iconName: iconName,
              color: color,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                service.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogLoading extends StatelessWidget {
  const _CatalogLoading();
  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: 7,
    itemBuilder: (context, index) => const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ShimmerBox(width: 40, height: 40, radius: 999),
          SizedBox(width: 12),
          Expanded(
            child: ShimmerBox(width: double.infinity, height: 18, radius: 8),
          ),
        ],
      ),
    ),
  );
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.cloud_off_outlined,
    title: AppLocalizations.of(context)!.catalogUnavailableTitle,
    subtitle: AppLocalizations.of(context)!.catalogUnavailableSubtitle,
    cta: Pressable(
      onPressed: onRetry,
      haptic: HapticType.light,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: context.colors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context)!.catalogTryAgain,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: context.colors.onAccent),
        ),
      ),
    ),
  );
}

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty();
  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.search_off_outlined,
    title: AppLocalizations.of(context)!.catalogEmptyTitle,
    subtitle: AppLocalizations.of(context)!.catalogEmptySubtitle,
  );
}
