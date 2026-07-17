import 'dart:developer' as developer;

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

  static const _logName = 'CatalogPicker';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final services = ref.watch(catalogServicesProvider);
    ref.listen<AsyncValue<List<CatalogService>>>(catalogServicesProvider, (
      _,
      next,
    ) {
      if (!next.hasError) return;
      developer.log(
        'Catalog unavailable in picker: '
        '${next.error.runtimeType}: ${next.error}',
        name: _logName,
        error: next.error,
        stackTrace: next.stackTrace,
        level: 1000,
      );
    });
    final resultItems = services.when<List<Widget>>(
      loading: () => List.generate(
        7,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              ShimmerBox(width: 40, height: 40, radius: 999),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 18,
                  radius: 8,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, _) => [_CatalogError(onRetry: _retryCatalog)],
      data: (items) {
        final query = normalizeForSearch(_query);
        final filtered = items.where((service) {
          return normalizeForSearch(service.name).contains(query) ||
              normalizeForSearch(service.slug).contains(query);
        }).toList();
        if (filtered.isEmpty) return const [_CatalogEmpty()];
        return filtered
            .map(
              (service) => _CatalogServiceRow(
                service: service,
                onPressed: () => _openService(service),
              ),
            )
            .toList();
      },
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.55,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            onSubmitted: (_) {
              if (_query.trim().isNotEmpty) _openCustom();
            },
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
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
          _CustomServiceRow(
            label: _query.trim().isEmpty
                ? l10n.catalogCreateCustom
                : l10n.catalogCreateCustomNamed(_query.trim()),
            onPressed: _openCustom,
          ),
          const SizedBox(height: 4),
          ...resultItems,
        ],
      ),
    );
  }

  void _retryCatalog() {
    developer.log('Retrying catalog request from picker', name: _logName);
    ref.invalidate(catalogServicesProvider);
  }

  void _openCustom() {
    final name = _query.trim();
    Navigator.of(context).pop(
      _CatalogPickerResult(
        prefill: name.isEmpty ? null : SubscriptionFormPrefill(name: name),
      ),
    );
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
          iconName: service.iconName,
          colorHex: service.color,
          manageUrl: service.manageUrl,
          groupId: matchCatalogServiceGroupId(service, groups),
        ),
      ),
    );
  }
}

class _CustomServiceRow extends StatelessWidget {
  const _CustomServiceRow({required this.label, required this.onPressed});
  final String label;
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
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    return Pressable(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SubscriptionAvatar(
              name: service.name,
              iconName: service.iconName,
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
