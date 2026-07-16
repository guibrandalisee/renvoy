import 'package:flutter/material.dart';

import '../haptics.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.pressedScale = 1,
    this.haptic = HapticType.none,
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double pressedScale;
  final HapticType haptic;
  final BorderRadius? borderRadius;

  /// How the underlying gesture detector behaves during hit testing.
  ///
  /// Defaults to [HitTestBehavior.opaque] so the whole area occupied by the
  /// widget is tappable (not just the painted child), which gives buttons a
  /// comfortable touch target.
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isEnabled =>
      widget.enabled &&
      (widget.onPressed != null || widget.onLongPress != null);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateDown() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
    );
  }

  void _animateUp() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 0;
      return;
    }
    _controller.animateBack(
      0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) {
      return;
    }
    _animateDown();
  }

  void _handleTapUp(TapUpDetails details) {
    _animateUp();
  }

  void _handleTapCancel() {
    _animateUp();
  }

  void _handleTap() {
    if (!_isEnabled || widget.onPressed == null) {
      return;
    }
    Haptics.play(widget.haptic);
    widget.onPressed?.call();
  }

  void _handleLongPress() {
    if (!_isEnabled || widget.onLongPress == null) {
      return;
    }
    _animateUp();
    Haptics.play(widget.haptic);
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = _controller.value;
        final scale = 1 - ((1 - widget.pressedScale) * value);
        final opacity = 1 - (0.12 * value);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );

    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    // Using GestureDetector (rather than a raw Listener) means the tap joins
    // the gesture arena, so an ancestor scrollable can win and cancel the tap.
    // This prevents accidental presses while the user is scrolling.
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _isEnabled ? _handleTapDown : null,
      onTapUp: _isEnabled ? _handleTapUp : null,
      onTapCancel: _isEnabled ? _handleTapCancel : null,
      onTap: _isEnabled ? _handleTap : null,
      onLongPress: (_isEnabled && widget.onLongPress != null)
          ? _handleLongPress
          : null,
      child: child,
    );
  }
}
