import 'package:flutter/material.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _NavItem(
        label: l10n.navHome,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      _NavItem(
        label: l10n.navSubscriptions,
        icon: Icons.credit_card_outlined,
        activeIcon: Icons.credit_card,
      ),
      _NavItem(
        label: l10n.navCalendar,
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
      ),
      _NavItem(
        label: l10n.navSettings,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
      ),
    ];

    return Container(
      height: 64 + bottomPadding,
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

    return Pressable(
      onPressed: onTap,
      haptic: HapticType.selection,
      pressedScale: 0.95,
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey('${item.label}-$selected'),
                  color: targetColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(item.label),
            ],
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
