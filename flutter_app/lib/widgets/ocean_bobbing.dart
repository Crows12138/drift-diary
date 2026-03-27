import 'dart:math';
import 'package:flutter/material.dart';

/// Provides the global bobbing animation phase to descendants.
class OceanBobbingScope extends InheritedWidget {
  final double phase; // 0.0 to 1.0

  const OceanBobbingScope({
    super.key,
    required this.phase,
    required super.child,
  });

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<OceanBobbingScope>()
            ?.phase ??
        0.0;
  }

  @override
  bool updateShouldNotify(OceanBobbingScope old) => phase != old.phase;
}

/// Wraps content with a gentle up-and-down bobbing, like sitting on a boat.
class OceanBobbing extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;

  const OceanBobbing({
    super.key,
    required this.child,
    this.amplitude = 2.0,
    this.duration = const Duration(seconds: 7),
  });

  @override
  State<OceanBobbing> createState() => _OceanBobbingState();
}

class _OceanBobbingState extends State<OceanBobbing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = sin(_controller.value * 2 * pi) * widget.amplitude;
        return OceanBobbingScope(
          phase: _controller.value,
          child: Transform.translate(
            offset: Offset(0, offset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Extra per-element bobbing with a different phase for natural variation.
class BobbingElement extends StatelessWidget {
  final Widget child;
  final double phaseShift;
  final double amplitude;

  const BobbingElement({
    super.key,
    required this.child,
    this.phaseShift = 0,
    this.amplitude = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final globalPhase = OceanBobbingScope.of(context);
    final offset = sin(globalPhase * 2 * pi + phaseShift) * amplitude;
    return Transform.translate(
      offset: Offset(0, offset),
      child: child,
    );
  }
}
