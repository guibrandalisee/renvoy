import 'package:flutter/material.dart';

import '../haptics.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.pressedScale = 0.97,
    this.haptic = HapticType.none,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double pressedScale;
  final HapticType haptic;
  final BorderRadius? borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pointerIsDown = false;
  bool _isInside = false;
  bool _longPressTriggered = false;

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
    _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
    );
  }

  void _animateUp() {
    _controller.animateBack(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.elasticOut,
    );
  }

  bool _containsGlobalPosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return false;
    }

    final localPosition = box.globalToLocal(globalPosition);
    return (Offset.zero & box.size).contains(localPosition);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_isEnabled) {
      return;
    }

    _pointerIsDown = true;
    _isInside = true;
    _longPressTriggered = false;
    _animateDown();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_pointerIsDown) {
      return;
    }

    final nextIsInside = _containsGlobalPosition(event.position);
    if (_isInside == nextIsInside) {
      return;
    }

    _isInside = nextIsInside;
    if (_isInside) {
      _animateDown();
    } else {
      _animateUp();
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_pointerIsDown) {
      return;
    }

    final shouldFire =
        _isEnabled &&
        !_longPressTriggered &&
        _containsGlobalPosition(event.position);
    _pointerIsDown = false;
    _isInside = false;
    _animateUp();

    if (shouldFire) {
      Haptics.play(widget.haptic);
      widget.onPressed?.call();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _pointerIsDown = false;
    _isInside = false;
    _longPressTriggered = false;
    _animateUp();
  }

  void _handleLongPress() {
    if (!_isEnabled || widget.onLongPress == null || !_isInside) {
      return;
    }

    _longPressTriggered = true;
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
        final opacity = 1 - (0.08 * value);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );

    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: _handleLongPress,
        child: child,
      ),
    );
  }
}
