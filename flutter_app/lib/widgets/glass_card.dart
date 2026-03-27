import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.12,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDayMode = Theme.of(context).brightness == Brightness.light;

    // Day: brighter frosted glass; Night: dark translucent glass
    final effectiveOpacity = isDayMode ? opacity * 2.5 : opacity;
    final borderColor = isDayMode
        ? Colors.white.withOpacity(0.4)
        : Colors.white.withOpacity(0.18);

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(effectiveOpacity),
                Colors.white.withOpacity(effectiveOpacity * 0.33),
              ],
            ),
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );

    final wrapped = margin != null ? Padding(padding: margin!, child: card) : card;

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: wrapped);
    }
    return wrapped;
  }
}
