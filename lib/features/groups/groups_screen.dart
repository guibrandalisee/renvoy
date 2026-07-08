import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/color_utils.dart';
import '../../core/formatters.dart';
import '../../core/haptics.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../data/db/database.dart';
import '../../data/db/database_provider.dart';
import '../../domain/billing/billing_math.dart';
import '../../domain/models/group_node.dart';
import '../home/home_providers.dart';

const groupColorPalette = [
  '#7C5CFC',
  '#38BDF8',
  '#34D399',
  '#FBBF24',
  '#F87171',
  '#F472B6',
  '#A78BFA',
  '#22D3EE',
  '#FB923C',
  '#4ADE80',
];

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final groups = ref.watch(groupsTreeProvider).valueOrNull ?? const [];
    final subscriptions =
        ref.watch(subscriptionsListForGroupsProvider).valueOrNull ??
        const <Subscription>[];
    final currency = ref.watch(defaultCurrencyProvider).valueOrNull ?? 'USD';

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.viewPaddingOf(context).top + 12,
                  20,
                  0,
                ),
                child: Row(
                  children: [
                    Pressable(
                      onPressed: () => context.pop(),
                      haptic: HapticType.light,
                      borderRadius: BorderRadius.circular(999),
                      child: _CircleButton(icon: Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        l10n.groupsTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Pressable(
                      onPressed: () => _showGroupSheet(context, ref, groups),
                      haptic: HapticType.light,
                      borderRadius: BorderRadius.circular(999),
                      child: _CircleButton(icon: Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: groups.isEmpty
                    ? EmptyState(
                        icon: Icons.folder_open,
                        title: l10n.groupsEmpty,
                        subtitle: l10n.groupsEmptySubtitle,
                        cta: Pressable(
                          onPressed: () =>
                              _showGroupSheet(context, ref, groups),
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
                              l10n.createGroup,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: colors.onAccent),
                            ),
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 120),
                        children: [
                          for (final node in groups) ...[
                            _GroupRow(
                              node: node,
                              depth: 0,
                              subscriptions: subscriptions,
                              currencyCode: currency,
                              onTap: () => _showGroupSheet(
                                context,
                                ref,
                                groups,
                                node: node,
                              ),
                            ),
                            for (final child in node.children)
                              _GroupRow(
                                node: child,
                                depth: 1,
                                subscriptions: subscriptions,
                                currencyCode: currency,
                                parent: node,
                                onTap: () => _showGroupSheet(
                                  context,
                                  ref,
                                  groups,
                                  node: child,
                                ),
                              ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final subscriptionsListForGroupsProvider = StreamProvider<List<Subscription>>((
  ref,
) {
  return ref.watch(subscriptionsDaoProvider).watchAll();
});

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

class _GroupRow extends ConsumerWidget {
  const _GroupRow({
    required this.node,
    required this.depth,
    required this.subscriptions,
    required this.currencyCode,
    required this.onTap,
    this.parent,
  });

  final GroupNode node;
  final int depth;
  final List<Subscription> subscriptions;
  final String currencyCode;
  final VoidCallback onTap;
  final GroupNode? parent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final group = node.group;
    final groupColor = colorFromHex(group.color) ?? colors.accent;
    final ids = _groupIds(node).toSet();
    final groupSubscriptions = subscriptions
        .where((subscription) => ids.contains(subscription.groupId))
        .toList();
    final monthly = groupSubscriptions.fold<double>(
      0,
      (sum, subscription) =>
          sum +
          monthlyEquivalentMinor(
            subscription.priceMinor,
            subscription.cycleUnit,
            subscription.cycleCount,
          ),
    );
    final leftMargin = 20.0 + depth * 20;

    return Dismissible(
      key: ValueKey(group.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, ref, node, parent),
      background: Container(
        margin: EdgeInsets.fromLTRB(leftMargin, 0, 20, 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.dangerSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: colors.danger),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(leftMargin, 0, 20, 8),
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
                  width: depth == 0 ? 36 : 32,
                  height: depth == 0 ? 36 : 32,
                  decoration: BoxDecoration(
                    color: groupColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForName(group.icon),
                    size: 18,
                    color: groupColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.groupSummary(
                          node.subscriptionCount,
                          Money.format(
                            monthly.round(),
                            currencyCode,
                            locale: AppLocalizations.of(context)!.localeName,
                          ),
                        ),
                        style: moneyStyle(
                          Theme.of(context).textTheme.bodySmall ??
                              const TextStyle(),
                        ).copyWith(color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: colors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showGroupSheet(
  BuildContext context,
  WidgetRef ref,
  List<GroupNode> groups, {
  GroupNode? node,
}) async {
  await showAppSheet<void>(
    context: context,
    title: node == null
        ? AppLocalizations.of(context)!.createGroup
        : AppLocalizations.of(context)!.editGroup,
    child: _GroupForm(groups: groups, node: node),
  );
}

class _GroupForm extends ConsumerStatefulWidget {
  const _GroupForm({required this.groups, this.node});

  final List<GroupNode> groups;
  final GroupNode? node;

  @override
  ConsumerState<_GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends ConsumerState<_GroupForm> {
  late final TextEditingController _nameController;
  late String _icon;
  late String _color;
  String? _parentId;

  @override
  void initState() {
    super.initState();
    final group = widget.node?.group;
    _nameController = TextEditingController(text: group?.name ?? '');
    _icon = group?.icon ?? 'category_outlined';
    _color = group?.color ?? groupColorPalette.first;
    _parentId = group?.parentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    final dao = ref.read(groupsDaoProvider);
    final existing = widget.node?.group;
    if (existing == null) {
      await dao.insert(
        GroupsCompanion.insert(
          id: '',
          createdAt: 0,
          updatedAt: 0,
          name: name,
          icon: _icon,
          color: _color,
          parentId: Value(_parentId),
        ),
      );
    } else {
      await dao.updateGroup(
        GroupsCompanion(
          id: Value(existing.id),
          name: Value(name),
          icon: Value(_icon),
          color: Value(_color),
          parentId: Value(
            widget.node!.children.isEmpty ? _parentId : existing.parentId,
          ),
        ),
      );
    }
    await Haptics.success();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final topLevelGroups = widget.groups.map((node) => node.group).toList();
    final canPickParent = widget.node == null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: _inputDecoration(context, l10n.name),
          ),
          const SizedBox(height: 16),
          _Label(l10n.icon),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _iconNames
                .map(
                  (icon) => _PickerCircle(
                    size: 44,
                    selected: _icon == icon,
                    onPressed: () => setState(() => _icon = icon),
                    child: Icon(
                      _iconForName(icon),
                      size: 20,
                      color: _icon == icon
                          ? colors.accent
                          : colors.textSecondary,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _Label(l10n.color),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: groupColorPalette
                .map(
                  (hex) => _ColorCircle(
                    hex: hex,
                    selected: _color == hex,
                    onPressed: () => setState(() => _color = hex),
                  ),
                )
                .toList(),
          ),
          if (canPickParent) ...[
            const SizedBox(height: 16),
            _Label(l10n.parentGroup),
            _ParentPicker(
              groups: topLevelGroups,
              selectedId: _parentId,
              onChanged: (value) => setState(() => _parentId = value),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(onPressed: _save, child: Text(l10n.save)),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

InputDecoration _inputDecoration(BuildContext context, String hint) {
  final colors = context.colors;
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: colors.surface,
    hintStyle: TextStyle(color: colors.textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.accent),
    ),
  );
}

class _PickerCircle extends StatelessWidget {
  const _PickerCircle({
    required this.size,
    required this.selected,
    required this.onPressed,
    required this.child,
  });

  final double size;
  final bool selected;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      haptic: HapticType.selection,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? colors.accentSoft : colors.surfaceElevated,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.hex,
    required this.selected,
    required this.onPressed,
  });

  final String hex;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = colorFromHex(hex) ?? colors.accent;
    return Pressable(
      onPressed: onPressed,
      haptic: HapticType.selection,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colors.accent : colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check, size: 18, color: colors.onAccent)
            : null,
      ),
    );
  }
}

class _ParentPicker extends StatelessWidget {
  const _ParentPicker({
    required this.groups,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Group> groups;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <Group?>[null, ...groups];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((group) {
        final selected = group?.id == selectedId;
        return Pressable(
          onPressed: () => onChanged(group?.id),
          haptic: HapticType.selection,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? context.colors.accentSoft
                  : context.colors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? context.colors.accent : context.colors.border,
              ),
            ),
            child: Text(
              group?.name ?? l10n.noneTopLevel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected
                    ? context.colors.accent
                    : context.colors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

Future<bool> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  GroupNode node,
  GroupNode? parent,
) async {
  final hasChildren = node.children.isNotEmpty;
  final hasSubscriptions =
      node.subscriptionCount >
      node.children.fold<int>(0, (sum, child) => sum + child.subscriptionCount);
  if (!hasChildren && !hasSubscriptions) {
    final confirmed = await _confirmDialog(
      context,
      AppLocalizations.of(context)!.deleteGroupMessage,
    );
    if (confirmed) {
      await Haptics.warning();
      await ref.read(groupsDaoProvider).softDelete(node.group.id);
    }
    return false;
  }

  final action = await showAppSheet<_DeleteAction>(
    context: context,
    title: AppLocalizations.of(context)!.delete,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (parent != null || hasChildren)
          _DeleteOption(
            label: AppLocalizations.of(context)!.moveContentsUp,
            onPressed: () => Navigator.of(context).pop(_DeleteAction.moveUp),
          ),
        _DeleteOption(
          label: AppLocalizations.of(context)!.ungroupSubscriptions,
          onPressed: () => Navigator.of(context).pop(_DeleteAction.ungroup),
        ),
        _DeleteOption(
          label: AppLocalizations.of(context)!.deleteEverything,
          danger: true,
          onPressed: () => Navigator.of(context).pop(_DeleteAction.cascade),
        ),
      ],
    ),
  );
  if (action == null) {
    return false;
  }
  if (!context.mounted) {
    return false;
  }
  if (action == _DeleteAction.cascade) {
    final message = AppLocalizations.of(context)!.deleteEverythingMessage;
    final confirmed = await _confirmDialog(context, message);
    if (!confirmed) {
      return false;
    }
  }
  await Haptics.warning();
  final dao = ref.read(groupsDaoProvider);
  switch (action) {
    case _DeleteAction.moveUp:
      await dao.deleteGroupMoveChildrenUp(node.group.id);
    case _DeleteAction.ungroup:
      await dao.deleteGroupUngroupSubscriptions(node.group.id);
    case _DeleteAction.cascade:
      await dao.deleteGroupCascade(node.group.id);
  }
  return false;
}

class _DeleteOption extends StatelessWidget {
  const _DeleteOption({
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      haptic: danger ? HapticType.warning : HapticType.selection,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: danger
                  ? context.colors.danger
                  : context.colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _confirmDialog(BuildContext context, String message) async {
  final l10n = AppLocalizations.of(context)!;
  return await showAdaptiveDialog<bool>(
        context: context,
        builder: (context) => AlertDialog.adaptive(
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
              child: Text(l10n.delete),
            ),
          ],
        ),
      ) ??
      false;
}

enum _DeleteAction { moveUp, ungroup, cascade }

List<String> _groupIds(GroupNode node) {
  return [
    node.group.id,
    for (final child in node.children) ..._groupIds(child),
  ];
}

IconData _iconForName(String icon) {
  return switch (icon) {
    'movie' => Icons.movie,
    'music_note' || 'music' => Icons.music_note,
    'sports_esports' || 'device-gamepad' => Icons.sports_esports,
    'work_outline' || 'briefcase' => Icons.work_outline,
    'favorite_border' || 'heart' => Icons.favorite_border,
    'bolt' => Icons.bolt,
    'home_outlined' => Icons.home_outlined,
    'school_outlined' => Icons.school_outlined,
    'flight_takeoff' => Icons.flight_takeoff,
    'restaurant_outlined' => Icons.restaurant_outlined,
    'pets' => Icons.pets,
    _ => Icons.category_outlined,
  };
}

const _iconNames = [
  'movie',
  'music_note',
  'sports_esports',
  'work_outline',
  'favorite_border',
  'bolt',
  'home_outlined',
  'school_outlined',
  'flight_takeoff',
  'restaurant_outlined',
  'pets',
  'category_outlined',
];
