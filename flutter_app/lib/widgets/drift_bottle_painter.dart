import 'package:flutter/material.dart';

class DriftBottleWidget extends StatelessWidget {
  final double tiltAngle;
  final bool isDayMode;
  final Color? glowColor;
  final double size;

  const DriftBottleWidget({
    super.key,
    this.tiltAngle = 0.0,
    this.isDayMode = false,
    this.glowColor,
    this.size = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ??
        (isDayMode ? const Color(0x40D4A853) : const Color(0x307EC8E3));
    return Transform.rotate(
      angle: tiltAngle,
      child: SizedBox(
        width: 80 * size,
        height: 54 * size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow behind bottle
            Container(
              width: 70 * size,
              height: 44 * size,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: glow,
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Bottle image
            Image.asset(
              'assets/images/bottle.png',
              width: 80 * size,
              height: 54 * size,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
