import 'dart:math';
import 'package:flutter/material.dart';

class VialPainter extends CustomPainter {
  final double fillFraction;
  final double wavePhase;
  final Color? color;

  const VialPainter({
    required this.fillFraction,
    required this.wavePhase,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillFraction <= 0) return;

    final baseColor = color ?? const Color(0xFFE67598);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseColor.withValues(alpha: 0.7),
          baseColor,
          baseColor.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final waveH = size.height * 0.05;
    final baseY = size.height * (1.0 - fillFraction);
    final path = Path()..moveTo(0, baseY);

    for (double x = 0; x <= size.width; x += 1.0) {
      path.lineTo(
        x,
        baseY + sin((x / size.width) * 2 * pi + wavePhase * 2 * pi) * waveH,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Shimmer effect
    final shimmer = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final sp = Path()
      ..moveTo(size.width * 0.1, baseY - 3)
      ..quadraticBezierTo(size.width * 0.4, baseY - 8, size.width * 0.7, baseY - 3)
      ..lineTo(size.width * 0.7, baseY + 4)
      ..quadraticBezierTo(size.width * 0.4, baseY + 9, size.width * 0.1, baseY + 4)
      ..close();
    canvas.drawPath(sp, shimmer);
  }

  @override
  bool shouldRepaint(VialPainter old) =>
      old.fillFraction != fillFraction || old.wavePhase != wavePhase || old.color != color;
}
