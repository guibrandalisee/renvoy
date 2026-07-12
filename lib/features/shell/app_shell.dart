import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/add_fab.dart';
import '../../features/shell/widgets/renvoy_nav_bar.dart';
import '../subscriptions/catalog/catalog_picker_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scrollControllers = <int, ScrollController>{};

  void _registerScrollController(int tabIndex, ScrollController controller) {
    _scrollControllers[tabIndex] = controller;
  }

  void _unregisterScrollController(int tabIndex, ScrollController controller) {
    if (_scrollControllers[tabIndex] == controller) {
      _scrollControllers.remove(tabIndex);
    }
  }

  void _goBranch(int index) {
    final isCurrent = index == widget.navigationShell.currentIndex;
    if (isCurrent) {
      final controller = _scrollControllers[index];
      if (controller != null && controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final navHeight = 64 + bottomPadding;

    return ShellScrollRegistry(
      register: _registerScrollController,
      unregister: _unregisterScrollController,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            Positioned.fill(child: widget.navigationShell),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RenvoyNavBar(
                currentIndex: widget.navigationShell.currentIndex,
                onTap: _goBranch,
              ),
            ),
            if (widget.navigationShell.currentIndex == 0 ||
                widget.navigationShell.currentIndex == 1)
              Positioned(
                right: 20,
                bottom: navHeight + 16,
                child: AddFab(
                  onPressed: () => showCatalogPickerAndOpenForm(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ShellScrollRegistry extends InheritedWidget {
  const ShellScrollRegistry({
    required this.register,
    required this.unregister,
    required super.child,
    super.key,
  });

  final void Function(int tabIndex, ScrollController controller) register;
  final void Function(int tabIndex, ScrollController controller) unregister;

  static ShellScrollRegistry? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellScrollRegistry>();
  }

  @override
  bool updateShouldNotify(ShellScrollRegistry oldWidget) {
    return register != oldWidget.register || unregister != oldWidget.unregister;
  }
}
