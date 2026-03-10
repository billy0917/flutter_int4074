import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Draws tone contour shapes using CustomPainter
class TonePainter extends CustomPainter {
  final int toneNumber;
  final Color? color;
  final double strokeWidth;
  final bool animated;
  final double progress; // 0.0 ~ 1.0 for animation

  const TonePainter({
    required this.toneNumber,
    this.color,
    this.strokeWidth = 3.0,
    this.animated = false,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? AppConstants.toneColor(toneNumber)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    Path path;

    switch (toneNumber) {
      case 1: // 一聲 — flat high line
        path = Path()
          ..moveTo(w * 0.1, h * 0.3)
          ..lineTo(w * 0.9, h * 0.3);
      case 2: // 二聲 — rising
        path = Path()
          ..moveTo(w * 0.1, h * 0.7)
          ..lineTo(w * 0.9, h * 0.2);
      case 3: // 三聲 — dipping (V shape)
        path = Path()
          ..moveTo(w * 0.1, h * 0.35)
          ..cubicTo(
              w * 0.3, h * 0.7, w * 0.5, h * 0.85, w * 0.6, h * 0.8)
          ..cubicTo(
              w * 0.75, h * 0.75, w * 0.85, h * 0.55, w * 0.9, h * 0.35);
      case 4: // 四聲 — falling
        path = Path()
          ..moveTo(w * 0.1, h * 0.2)
          ..lineTo(w * 0.9, h * 0.8);
      default: // 輕聲 — small dot
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.6),
          strokeWidth * 2,
          paint..style = PaintingStyle.fill,
        );
        return;
    }

    if (animated && progress < 1.0) {
      final metrics = path.computeMetrics().first;
      final extractedPath =
          metrics.extractPath(0, metrics.length * progress);
      canvas.drawPath(extractedPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(TonePainter oldDelegate) =>
      oldDelegate.toneNumber != toneNumber ||
      oldDelegate.progress != progress;
}

class ToneContourWidget extends StatefulWidget {
  final int toneNumber;
  final double width;
  final double height;
  final bool animate;

  const ToneContourWidget({
    super.key,
    required this.toneNumber,
    this.width = 80,
    this.height = 40,
    this.animate = false,
  });

  @override
  State<ToneContourWidget> createState() => _ToneContourWidgetState();
}

class _ToneContourWidgetState extends State<ToneContourWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.animate) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return CustomPaint(
        size: Size(widget.width, widget.height),
        painter: TonePainter(toneNumber: widget.toneNumber),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: Size(widget.width, widget.height),
        painter: TonePainter(
          toneNumber: widget.toneNumber,
          animated: true,
          progress: _controller.value,
        ),
      ),
    );
  }
}
