import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_platform.dart';
import '../../../core/haptics.dart';
import '../../../core/widgets/pressable.dart';

class RenvoyNavBar extends StatelessWidget {
  const RenvoyNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final isCupertino = isCupertinoPlatform(context);
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _NavItem(
        label: l10n.navHome,
        icon: isCupertino ? CupertinoIcons.house : Icons.home_outlined,
        activeIcon: isCupertino
            ? CupertinoIcons.house_fill
            : Icons.home_rounded,
      ),
      _NavItem(
        label: l10n.navSubscriptions,
        icon: isCupertino
            ? CupertinoIcons.creditcard
            : Icons.credit_card_outlined,
        activeIcon: isCupertino
            ? CupertinoIcons.creditcard_fill
            : Icons.credit_card_rounded,
      ),
      _NavItem(
        label: l10n.navCalendar,
        icon: isCupertino
            ? CupertinoIcons.calendar
            : Icons.calendar_month_outlined,
        activeIcon: isCupertino
            ? CupertinoIcons.calendar
            : Icons.calendar_month_rounded,
      ),
      _NavItem(
        label: l10n.navSettings,
        icon: isCupertino ? CupertinoIcons.settings : Icons.settings_outlined,
        activeIcon: isCupertino
            ? CupertinoIcons.settings_solid
            : Icons.settings_rounded,
      ),
    ];

    return Container(
      height: (isCupertino ? 68 : 72) + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: _RenvoyNavBarItem(
                item: items[index],
                selected: index == currentIndex,
                onTap: () => onTap(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _RenvoyNavBarItem extends StatelessWidget {
  const _RenvoyNavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final targetColor = selected ? colors.accent : colors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Pressable(
        onPressed: onTap,
        haptic: HapticType.selection,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              color: targetColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  width: selected ? 18 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colors.brandWarm,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    key: ValueKey('${item.label}-$selected'),
                    color: targetColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 3),
                Text(item.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
