import 'dart:math';
import 'package:flutter/material.dart';
import 'glass_card.dart';

/// A GlassCard that gently bobs up and down, like floating on water.
class FloatingCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Duration duration;
  final double amplitude; // how many pixels to float up/down

  const FloatingCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.12,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.onTap,
    this.duration = const Duration(milliseconds: 4000),
    this.amplitude = 1,
  });

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
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
        final offset = sin(_controller.value * pi) * widget.amplitude;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: GlassCard(
        blur: widget.blur,
        opacity: widget.opacity,
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        margin: widget.margin,
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}
