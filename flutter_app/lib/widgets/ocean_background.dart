import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OceanBackground extends StatefulWidget {
  final Widget child;
  final double waveHeight;
  final bool showStars;

  const OceanBackground({
    super.key,
    required this.child,
    this.waveHeight = 0.32,
    this.showStars = true,
  });

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDayMode = Theme.of(context).brightness == Brightness.light;
    final gradientColors = AppTheme.gradientColors(isDayMode);

    return Stack(
      children: [
        // Sky + Ocean gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              colors: gradientColors,
            ),
          ),
        ),

        // Stars — night only
        if (!isDayMode && widget.showStars) _buildStars(context),

        // Moonlight reflection — night only
        if (!isDayMode)
          Positioned(
            right: 60,
            top: 0,
            bottom: 0,
            width: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.05, 0.15, 0.5, 0.7, 1.0],
                  colors: [
                    Colors.transparent,
                    const Color(0xFFD4E5FF).withOpacity(0.03),
                    const Color(0xFFD4E5FF).withOpacity(0.015),
                    const Color(0xFFA8C8E8).withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        // Sun glow — day only
        if (isDayMode)
          Positioned(
            right: 40,
            top: 30,
            width: 180,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF5F0E0).withOpacity(0.25),
                    const Color(0xFFF5F0E0).withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

        // Horizon glow
        Positioned(
          left: 0,
          right: 0,
          top: MediaQuery.of(context).size.height * 0.42,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.3, 0),
                radius: 1.5,
                colors: [
                  isDayMode
                      ? const Color(0xFFF5F0E0).withOpacity(0.2)
                      : const Color(0xFF2A4A6B).withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Layered waves — mountain-ridge style
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _WavePainter(
                animationValue: _controller.value,
                waveHeight: widget.waveHeight,
                isDayMode: isDayMode,
              ),
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }

  Widget _buildStars(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rng = Random(42);
    final children = <Widget>[];

    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.45;
      final starSize = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.4 + 0.1;

      children.add(Positioned(
        left: x,
        top: y,
        child: Container(
          width: starSize,
          height: starSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFCCDDEE).withOpacity(opacity),
          ),
        ),
      ));
    }

    return Stack(children: children);
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final double waveHeight;
  final bool isDayMode;

  _WavePainter({
    required this.animationValue,
    required this.waveHeight,
    required this.isDayMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animationValue * 2 * pi;

    // Mountain-ridge style: 7 layers, back layers with larger amplitude
    final layers = isDayMode ? _dayLayers() : _nightLayers();

    for (final layer in layers) {
      final paint = Paint()
        ..color = layer.color
        ..style = PaintingStyle.fill;

      final path = Path();
      final baseY = size.height * (1 - waveHeight) + layer.yShift;

      path.moveTo(0, size.height);
      path.lineTo(0, baseY);

      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / size.width;
        final y = baseY +
            sin(normalizedX * 2 * pi * layer.frequency +
                    phase * layer.speed) *
                layer.amplitude +
            sin(normalizedX * 3 * pi * layer.frequency * 0.7 +
                    phase * layer.speed * 0.5 +
                    1.3) *
                layer.amplitude *
                0.4;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }

    // Shimmer line on top wave edge
    final shimmerColor = isDayMode
        ? const Color(0xFFFFFFFF).withOpacity(0.08)
        : const Color(0xFFAABBCC).withOpacity(0.04);

    final shimmerPaint = Paint()
      ..color = shimmerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final shimmerPath = Path();
    final shimmerY = size.height * (1 - waveHeight);
    shimmerPath.moveTo(0, shimmerY);

    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final y = shimmerY +
          sin(normalizedX * 2 * pi * 1.0 + phase * 0.6) * 4 +
          sin(normalizedX * 3 * pi * 0.7 + phase * 0.3 + 1.3) * 1.5;
      shimmerPath.lineTo(x, y);
    }

    canvas.drawPath(shimmerPath, shimmerPaint);
  }

  List<_WaveLayer> _nightLayers() {
    return [
      // Back layers — mountain ridges, larger amplitude, slower
      _WaveLayer(
        color: const Color(0xFF1A3555).withOpacity(0.2),
        amplitude: 10,
        frequency: 0.4,
        speed: 0.25,
        yShift: -20,
      ),
      _WaveLayer(
        color: const Color(0xFF173050).withOpacity(0.28),
        amplitude: 8,
        frequency: 0.6,
        speed: 0.35,
        yShift: -12,
      ),
      _WaveLayer(
        color: const Color(0xFF152B4A).withOpacity(0.35),
        amplitude: 7,
        frequency: 0.8,
        speed: 0.45,
        yShift: -4,
      ),
      // Mid layers
      _WaveLayer(
        color: const Color(0xFF132845).withOpacity(0.45),
        amplitude: 5,
        frequency: 1.0,
        speed: 0.6,
        yShift: 4,
      ),
      _WaveLayer(
        color: const Color(0xFF102340).withOpacity(0.55),
        amplitude: 4,
        frequency: 1.3,
        speed: 0.8,
        yShift: 10,
      ),
      // Front layers — closer, more opaque
      _WaveLayer(
        color: const Color(0xFF0D1E38).withOpacity(0.65),
        amplitude: 3,
        frequency: 1.6,
        speed: 1.0,
        yShift: 16,
      ),
      _WaveLayer(
        color: const Color(0xFF0B1A30).withOpacity(0.75),
        amplitude: 2,
        frequency: 2.0,
        speed: 1.2,
        yShift: 22,
      ),
    ];
  }

  List<_WaveLayer> _dayLayers() {
    return [
      // Back ridges — softer blues
      _WaveLayer(
        color: const Color(0xFF5A9FCB).withOpacity(0.15),
        amplitude: 10,
        frequency: 0.4,
        speed: 0.25,
        yShift: -20,
      ),
      _WaveLayer(
        color: const Color(0xFF4A8FBB).withOpacity(0.2),
        amplitude: 8,
        frequency: 0.6,
        speed: 0.35,
        yShift: -12,
      ),
      _WaveLayer(
        color: const Color(0xFF3A7FAB).withOpacity(0.28),
        amplitude: 7,
        frequency: 0.8,
        speed: 0.45,
        yShift: -4,
      ),
      // Mid
      _WaveLayer(
        color: const Color(0xFF2A6F9B).withOpacity(0.35),
        amplitude: 5,
        frequency: 1.0,
        speed: 0.6,
        yShift: 4,
      ),
      _WaveLayer(
        color: const Color(0xFF1A5F8B).withOpacity(0.4),
        amplitude: 4,
        frequency: 1.3,
        speed: 0.8,
        yShift: 10,
      ),
      // Front
      _WaveLayer(
        color: const Color(0xFF104F7B).withOpacity(0.5),
        amplitude: 3,
        frequency: 1.6,
        speed: 1.0,
        yShift: 16,
      ),
      _WaveLayer(
        color: const Color(0xFF083D77).withOpacity(0.6),
        amplitude: 2,
        frequency: 2.0,
        speed: 1.2,
        yShift: 22,
      ),
    ];
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isDayMode != isDayMode;
}

class _WaveLayer {
  final Color color;
  final double amplitude;
  final double frequency;
  final double speed;
  final double yShift;

  const _WaveLayer({
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.yShift,
  });
}
