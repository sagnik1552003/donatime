import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/forest_theme.dart';

class CircularTimeSlider extends StatefulWidget {
  final int initialMinutes;
  final Function(int) onTimeChanged;
  final Color? trackColor;
  final Color? progressColor;

  const CircularTimeSlider({
    super.key,
    required this.initialMinutes,
    required this.onTimeChanged,
    this.trackColor,
    this.progressColor,
  });

  @override
  State<CircularTimeSlider> createState() => _CircularTimeSliderState();
}

class _CircularTimeSliderState extends State<CircularTimeSlider> {
  late double _progress;
  bool _isDragging = false;
  
  // Constants for time range
  static const int minMinutes = 5;
  static const int maxMinutes = 120;

  @override
  void initState() {
    super.initState();
    // Map 5-120 minutes to 0.0-1.0 progress
    _progress = (widget.initialMinutes - minMinutes) / (maxMinutes - minMinutes);
  }

  void _updateProgress(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    
    // Calculate angle from center
    double angle = atan2(dy, dx);
    
    // Convert angle to progress (starting from top, clockwise)
    double normalizedAngle = angle + pi / 2;
    if (normalizedAngle < 0) {
      normalizedAngle += 2 * pi;
    }

    // Map angle to progress (0 to 1)
    double newProgress = normalizedAngle / (2 * pi);
    
    // Clamp to valid range (0.0-1.0 progress)
    newProgress = newProgress.clamp(0.0, 1.0);
    
    setState(() {
      _progress = newProgress;
    });

    // Convert back to minutes (5-120 range)
    final minutes = (minMinutes + _progress * (maxMinutes - minMinutes)).round();
    widget.onTimeChanged(minutes);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 350,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
          _updateProgress(details.localPosition, const Size(350, 350));
        },
        onPanUpdate: (details) {
          _updateProgress(details.localPosition, const Size(350, 350));
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
        },
        onTapDown: (details) {
          setState(() {
            _isDragging = true;
          });
          _updateProgress(details.localPosition, const Size(350, 350));
        },
        onTapUp: (_) {
          setState(() {
            _isDragging = false;
          });
        },
        child: CustomPaint(
          size: const Size(350, 350),
          painter: _CircularSliderPainter(
            progress: _progress,
            trackColor: widget.trackColor ?? ForestTheme.dividerBrown,
            progressColor: widget.progressColor ?? ForestTheme.brownMedium,
            isDragging: _isDragging,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(minMinutes + _progress * (maxMinutes - minMinutes)).round()}',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: ForestTheme.textBrown,
                  ),
                ),
                Text(
                  'minutes',
                  style: TextStyle(
                    fontSize: 18,
                    color: ForestTheme.textLightBrown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularSliderPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final bool isDragging;

  _CircularSliderPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 16.0;

    // Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final startAngle = -pi / 2; // Start from top
      final sweepAngle = progress * 2 * pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Draw thumb (knob) at the end of progress
    final thumbAngle = -pi / 2 + progress * 2 * pi;
    final thumbX = center.dx + radius * cos(thumbAngle);
    final thumbY = center.dy + radius * sin(thumbAngle);

    // Draw shadow for thumb
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      Offset(thumbX + 2, thumbY + 2),
      isDragging ? 24.0 : 20.0,
      shadowPaint,
    );

    final thumbPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    final thumbRadius = isDragging ? 24.0 : 20.0;
    canvas.drawCircle(Offset(thumbX, thumbY), thumbRadius, thumbPaint);

    // Draw thumb border
    final thumbBorderPaint = Paint()
      ..color = ForestTheme.creamSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(Offset(thumbX, thumbY), thumbRadius, thumbBorderPaint);
  }

  @override
  bool shouldRepaint(_CircularSliderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDragging != isDragging;
  }
}
