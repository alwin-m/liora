import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/smart_prediction_model.dart';
import '../core/cycle_algorithm.dart';

class LiquidCubeVisualization extends StatefulWidget {
  final FlowLevel flowLevel;
  final double size;
  final bool isExpected;
  final DayType dayType;

  const LiquidCubeVisualization({
    super.key,
    required this.flowLevel,
    this.size = 100,
    this.isExpected = false,
    this.dayType = DayType.normal,
  });

  @override
  State<LiquidCubeVisualization> createState() => _LiquidCubeVisualizationState();
}

class _LiquidCubeVisualizationState extends State<LiquidCubeVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fill;
    switch (widget.flowLevel) {
      case FlowLevel.spotting:
        fill = 0.15;
        break;
      case FlowLevel.light:
        fill = 0.35;
        break;
      case FlowLevel.medium:
        fill = 0.60;
        break;
      case FlowLevel.heavy:
        fill = 0.85;
        break;
      case FlowLevel.extreme:
        fill = 1.0;
        break;
      default:
        fill = 0.0;
    }

    // Custom fill for Ovulation/Fertile if flowLevel is none
    if (widget.flowLevel == FlowLevel.none) {
      if (widget.dayType == DayType.ovulation) fill = 0.4;
      if (widget.dayType == DayType.fertile) fill = 0.3;
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey[50], // Very light background
        borderRadius: BorderRadius.circular(widget.size * 0.28),
        boxShadow: widget.isExpected 
          ? null 
          : [
            BoxShadow(
              color: _getBaseColor().withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            )
          ],
        border: widget.isExpected 
          ? Border.all(color: _getBaseColor().withAlpha(60), width: 1.5, style: BorderStyle.solid)
          : Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size * 0.28),
        child: Stack(
          children: [
            // Grid background
            _buildGrid(),
            
            // Waves
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _LiquidPainter(
                    animationValue: _controller.value,
                    fillLevel: fill,
                    isExpected: widget.isExpected,
                    color: _getBaseColor(),
                  ),
                );
              },
            ),

             // Reflection highlight for top corner
            Positioned(
              top: 5,
              left: 5,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBaseColor() {
    switch (widget.dayType) {
      case DayType.period:
        return const Color(0xFFE63946); // Blood Red
      case DayType.fertile:
        return const Color(0xFF81C784); // Fertile Green
      case DayType.ovulation:
        return const Color(0xFFB39DDB); // Ovulation Purple
      default:
        return Colors.grey[300]!;
    }
  }

  Widget _buildGrid() {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _GridPainter(),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double animationValue;
  final double fillLevel;
  final bool isExpected;
  final Color color;

  _LiquidPainter({
    required this.animationValue,
    required this.fillLevel,
    required this.isExpected,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillLevel <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(isExpected ? 0.25 : 0.85);

    final path = Path();
    final yOffset = size.height * (1 - fillLevel);
    final waveHeight = size.height * 0.04;

    path.moveTo(0, yOffset);

    // Harmonic wave calculation
    for (double x = 0; x <= size.width; x++) {
      final y = yOffset +
          math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) *
              waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Dynamic Foam/Surface Line
    final surfacePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final surfacePath = Path();
    surfacePath.moveTo(0, yOffset);
    for (double x = 0; x <= size.width; x++) {
      final y = yOffset +
          math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) *
              waveHeight;
      surfacePath.lineTo(x, y);
    }
    canvas.drawPath(surfacePath, surfacePaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.fillLevel != fillLevel;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.04)
      ..strokeWidth = 1;

    const divisions = 4;
    final step = size.width / divisions;

    for (int i = 1; i < divisions; i++) {
      canvas.drawLine(Offset(step * i, 0), Offset(step * i, size.height), paint);
      canvas.drawLine(Offset(0, step * i), Offset(size.width, step * i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
