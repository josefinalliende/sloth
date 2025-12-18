import 'dart:math' show Random;

import 'package:flutter/material.dart';

class WnAnimatedPixelOverlay extends StatelessWidget {
  const WnAnimatedPixelOverlay({
    super.key,
    required this.progress,
    required this.color,
    required this.width,
    required this.height,
    this.pixelSize = 8.0,
    this.shouldDrawThreshold = 0.55,
    this.seed = 42,
  });

  final double progress;
  final Color color;
  final double width;
  final double height;
  final double pixelSize;
  final double shouldDrawThreshold;
  final int seed;

  static final Map<int, List<double>> _offsetsCache = {};

  static List<double> _getOffsets(int seed) {
    return _offsetsCache.putIfAbsent(seed, () {
      final random = Random(seed);
      return List.generate(100, (_) => random.nextDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AnimatedPixelPainter(
        progress: progress,
        color: color,
        offsets: _getOffsets(seed),
        pixelSize: pixelSize,
        shouldDrawThreshold: shouldDrawThreshold,
      ),
      size: Size(width, height),
    );
  }
}

class _AnimatedPixelPainter extends CustomPainter {
  _AnimatedPixelPainter({
    required this.progress,
    required this.color,
    required this.offsets,
    this.pixelSize = 8.0,
    this.shouldDrawThreshold = 0.55,
  });

  final double progress;
  final Color color;
  final List<double> offsets;
  final double pixelSize;
  final double shouldDrawThreshold;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = (size.width / pixelSize).ceil();
    final rows = (size.height / pixelSize).ceil();

    var offsetIndex = 0;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final phase = offsets[offsetIndex % offsets.length];
        offsetIndex++;

        final wave = ((progress + phase) % 1.0);
        final opacity = (wave < 0.5) ? (wave * 2) : (1 - (wave - 0.5) * 2);
        final shouldDraw = offsets[(offsetIndex + 17) % offsets.length] > shouldDrawThreshold;

        if (shouldDraw) {
          final paint = Paint()
            ..color = color.withValues(alpha: opacity * 0.5)
            ..style = PaintingStyle.fill;

          canvas.drawRect(
            Rect.fromLTWH(
              col * pixelSize,
              row * pixelSize,
              pixelSize,
              pixelSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_AnimatedPixelPainter oldDelegate) => oldDelegate.progress != progress;
}
