import 'dart:math';
import 'package:flutter/material.dart';
import 'drift_bottle_painter.dart';

class BottleSlot {
  final double xPercent;
  final double yPercent;
  final double tiltAngle;
  final double phaseShift;
  final double bobAmplitude;
  final double bobPeriod;
  bool isBeingPicked;

  BottleSlot({
    required this.xPercent,
    required this.yPercent,
    required this.tiltAngle,
    required this.phaseShift,
    required this.bobAmplitude,
    required this.bobPeriod,
    this.isBeingPicked = false,
  });

  static List<BottleSlot> generate(int count) {
    final rng = Random();
    return List.generate(count, (i) {
      return BottleSlot(
        xPercent: 0.12 + (i * 0.22) + rng.nextDouble() * 0.08,
        yPercent: 0.58 + rng.nextDouble() * 0.06,
        tiltAngle: (rng.nextDouble() - 0.5) * 0.45,
        phaseShift: rng.nextDouble() * 2 * pi,
        bobAmplitude: 4.0 + rng.nextDouble() * 4.0,
        bobPeriod: 6.0 + rng.nextDouble() * 2.0,
      );
    });
  }
}

class FloatingBottle extends StatefulWidget {
  final BottleSlot slot;
  final VoidCallback onTap;
  final bool isDayMode;

  const FloatingBottle({
    super.key,
    required this.slot,
    required this.onTap,
    required this.isDayMode,
  });

  @override
  State<FloatingBottle> createState() => _FloatingBottleState();
}

class _FloatingBottleState extends State<FloatingBottle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.slot.bobPeriod * 1000).toInt(),
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final bottleW = 80.0;
    final bottleH = 54.0;
    final baseX = screen.width * widget.slot.xPercent - bottleW / 2;
    final baseY = screen.height * widget.slot.yPercent - bottleH / 2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value * 2 * pi + widget.slot.phaseShift;
        final yOff = sin(phase) * widget.slot.bobAmplitude;
        final xOff = sin(phase * 0.7 + 1.0) * 3.0;
        return Positioned(
          left: baseX + xOff,
          top: baseY + yOff,
          child: child!,
        );
      },
      child: _BottleTappable(
        slot: widget.slot,
        isDayMode: widget.isDayMode,
        onTap: widget.onTap,
      ),
    );
  }
}

class _BottleTappable extends StatelessWidget {
  final BottleSlot slot;
  final bool isDayMode;
  final VoidCallback onTap;

  const _BottleTappable({
    required this.slot,
    required this.isDayMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: slot.isBeingPicked ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedOpacity(
          opacity: slot.isBeingPicked ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DriftBottleWidget(
              tiltAngle: slot.tiltAngle,
              isDayMode: isDayMode,
            ),
          ),
        ),
      ),
    );
  }
}
