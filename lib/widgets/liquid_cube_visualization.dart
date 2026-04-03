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
    if (widget.dayType != DayType.period) {
       return _buildStaticIndicator();
    }

    double fill;
    switch (widget.flowLevel) {
      case FlowLevel.spotting:
        fill = 0.12;
        break;
      case FlowLevel.light:
        fill = 0.30;
        break;
      case FlowLevel.medium:
        fill = 0.58;
        break;
      case FlowLevel.heavy:
        fill = 0.82;
        break;
      case FlowLevel.extreme:
        fill = 1.0;
        break;
      default:
        fill = 0.0;
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(widget.size * 0.3),
        boxShadow: widget.isExpected 
          ? null 
          : [
            BoxShadow(
              color: _getFlowColor().withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        border: Border.all(
          color: widget.isExpected 
            ? _getFlowColor().withOpacity(0.3) 
            : Colors.white, 
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size * 0.3),
        child: Stack(
          children: [
            _buildArtisticGrid(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _LiquidPainter(
                    animationValue: _controller.value,
                    fillLevel: fill,
                    isExpected: widget.isExpected,
                    color: _getFlowColor(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticIndicator() {
    Color color;
    switch (widget.dayType) {
      case DayType.fertile: color = const Color(0xFF81C784); break;
      case DayType.ovulation: color = const Color(0xFFB39DDB); break;
      default: color = Colors.grey[200]!;
    }
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(widget.size * 0.3),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Color _getFlowColor() {
    switch (widget.flowLevel) {
      case FlowLevel.spotting:
        return const Color(0xFFFAA0A0); // Soft Rose
      case FlowLevel.light:
        return const Color(0xFFFF4D4D); // Light Red
      case FlowLevel.medium:
        return const Color(0xFFD90429); // Vibrant Red
      case FlowLevel.heavy:
        return const Color(0xFF9E0120); // Deep Crimson
      case FlowLevel.extreme:
        return const Color(0xFF660708); // Dark Mahogany
      default:
        return const Color(0xFFE63946);
    }
  }

  Widget _buildArtisticGrid() {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _ArtisticGridPainter(),
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
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..color = color.withOpacity(isExpected ? 0.3 : 0.9);

    final path = Path();
    final yOffset = size.height * (1 - fillLevel);
    final waveHeight = size.height * 0.035;

    path.moveTo(0, yOffset);

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

    // Surface highlight
    final surfacePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final surfacePath = Path();
    surfacePath.moveTo(0, yOffset);
    for (double x = 0; x <= size.width; x++) {
      final y = yOffset +
          math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) *
              waveHeight + 2;
      surfacePath.lineTo(x, y);
    }
    canvas.drawPath(surfacePath, surfacePaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) => true;
}

class _ArtisticGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.06)
      ..strokeWidth = 0.5;

    const divisions = 3;
    final step = size.width / divisions;

    for (int i = 1; i < divisions; i++) {
        canvas.drawLine(Offset(step * i, 0), Offset(step * i, size.height), paint);
        canvas.drawLine(Offset(0, step * i), Offset(size.width, step * i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
