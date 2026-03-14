import 'package:flutter/material.dart';

class AmbientBackground extends StatelessWidget {
  final List<AmbientOrb> orbs;
  final Widget child;

  const AmbientBackground({
    super.key,
    required this.child,
    this.orbs = const [],
  });

  /// Default mood-based background
  factory AmbientBackground.mood({
    Key? key,
    required String mood,
    required Widget child,
  }) {
    final colors = _moodOrbs(mood);
    return AmbientBackground(key: key, orbs: colors, child: child);
  }

  /// Default homepage background
  factory AmbientBackground.home({Key? key, required Widget child}) {
    return AmbientBackground(
      key: key,
      orbs: const [
        AmbientOrb(color: Color(0xFF7C83FD), x: 0.2, y: 0.15, radius: 0.45),
        AmbientOrb(color: Color(0xFFE2B0FF), x: 0.8, y: 0.3, radius: 0.35),
        AmbientOrb(color: Color(0xFF4D96FF), x: 0.5, y: 0.75, radius: 0.4),
      ],
      child: child,
    );
  }

  static List<AmbientOrb> _moodOrbs(String mood) {
    return switch (mood) {
      'happy' => const [
          AmbientOrb(color: Color(0xFFFFD93D), x: 0.3, y: 0.2, radius: 0.45),
          AmbientOrb(color: Color(0xFFFF8C32), x: 0.75, y: 0.4, radius: 0.35),
          AmbientOrb(color: Color(0xFFF472B6), x: 0.4, y: 0.7, radius: 0.3),
        ],
      'calm' => const [
          AmbientOrb(color: Color(0xFF6BCB77), x: 0.25, y: 0.2, radius: 0.45),
          AmbientOrb(color: Color(0xFF4D96FF), x: 0.7, y: 0.35, radius: 0.35),
          AmbientOrb(color: Color(0xFF7C83FD), x: 0.5, y: 0.7, radius: 0.3),
        ],
      'sad' => const [
          AmbientOrb(color: Color(0xFF4D96FF), x: 0.3, y: 0.25, radius: 0.5),
          AmbientOrb(color: Color(0xFF7C83FD), x: 0.7, y: 0.4, radius: 0.35),
          AmbientOrb(color: Color(0xFF1A1A5E), x: 0.4, y: 0.7, radius: 0.4),
        ],
      'anxious' => const [
          AmbientOrb(color: Color(0xFFFF8C32), x: 0.25, y: 0.2, radius: 0.4),
          AmbientOrb(color: Color(0xFFFFD93D), x: 0.7, y: 0.35, radius: 0.35),
          AmbientOrb(color: Color(0xFFC084FC), x: 0.5, y: 0.7, radius: 0.3),
        ],
      'angry' => const [
          AmbientOrb(color: Color(0xFFFF6B6B), x: 0.3, y: 0.2, radius: 0.45),
          AmbientOrb(color: Color(0xFFFF8C32), x: 0.75, y: 0.4, radius: 0.35),
          AmbientOrb(color: Color(0xFF7C2D12), x: 0.4, y: 0.7, radius: 0.3),
        ],
      'confused' => const [
          AmbientOrb(color: Color(0xFFC084FC), x: 0.25, y: 0.2, radius: 0.45),
          AmbientOrb(color: Color(0xFF7C83FD), x: 0.7, y: 0.35, radius: 0.35),
          AmbientOrb(color: Color(0xFFE2B0FF), x: 0.5, y: 0.7, radius: 0.3),
        ],
      'grateful' => const [
          AmbientOrb(color: Color(0xFFF472B6), x: 0.3, y: 0.2, radius: 0.45),
          AmbientOrb(color: Color(0xFFE2B0FF), x: 0.75, y: 0.4, radius: 0.35),
          AmbientOrb(color: Color(0xFFFFD93D), x: 0.4, y: 0.7, radius: 0.3),
        ],
      _ => const [
          AmbientOrb(color: Color(0xFF7C83FD), x: 0.3, y: 0.2, radius: 0.4),
          AmbientOrb(color: Color(0xFFE2B0FF), x: 0.7, y: 0.35, radius: 0.35),
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Background color
        Container(color: const Color(0xFF0F0F1A)),
        // Ambient orbs
        for (final orb in orbs)
          Positioned(
            left: size.width * orb.x - size.width * orb.radius,
            top: size.height * orb.y - size.height * orb.radius,
            child: Container(
              width: size.width * orb.radius * 2,
              height: size.width * orb.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    orb.color.withOpacity(0.3),
                    orb.color.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        // Content
        child,
      ],
    );
  }
}

class AmbientOrb {
  final Color color;
  final double x; // 0..1 fraction of screen width
  final double y; // 0..1 fraction of screen height
  final double radius; // fraction of screen width

  const AmbientOrb({
    required this.color,
    required this.x,
    required this.y,
    required this.radius,
  });
}
