import 'package:flutter/material.dart';
import '../config/theme.dart';

class ToneDrawingCanvas extends StatefulWidget {
  final ValueChanged<List<Offset>>? onStrokeChanged;
  final double height;

  const ToneDrawingCanvas({
    super.key,
    this.onStrokeChanged,
    this.height = 180,
  });

  @override
  State<ToneDrawingCanvas> createState() => ToneDrawingCanvasState();
}

class ToneDrawingCanvasState extends State<ToneDrawingCanvas> {
  final List<Offset> _points = [];
  DateTime? _lastRecord;

  void clear() {
    setState(() => _points.clear());
    widget.onStrokeChanged?.call([]);
  }

  List<Offset> get points => List.unmodifiable(_points);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        setState(() => _points.add(event.localPosition));
        widget.onStrokeChanged?.call(List.from(_points));
      },
      onPointerMove: (event) {
        final now = DateTime.now();
        if (_lastRecord == null ||
            now.difference(_lastRecord!).inMilliseconds >= 10) {
          _lastRecord = now;
          setState(() => _points.add(event.localPosition));
          widget.onStrokeChanged?.call(List.from(_points));
        }
      },
      onPointerUp: (_) {
        widget.onStrokeChanged?.call(List.from(_points));
      },
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.cardBgAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textLight.withValues(alpha: 0.5),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            // SizedBox.expand() gives CustomPaint a concrete size that fills
            // the Container — without this the painter has zero height.
            painter: _GridPainter(),
            foregroundPainter: _DrawingPainter(List.from(_points)),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textLight.withValues(alpha: 0.3)
      ..strokeWidth = 0.8;

    // Horizontal lines
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DrawingPainter extends CustomPainter {
  final List<Offset> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw dot for single touch point
    if (points.length == 1) {
      canvas.drawCircle(points.first, 4, Paint()..color = AppColors.primary);
      return;
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Draw start point
    canvas.drawCircle(
      points.first,
      5,
      Paint()..color = AppColors.primaryLight,
    );
  }

  @override
  // Always repaint — list contents change on every pointer event.
  bool shouldRepaint(_DrawingPainter old) => true;
}
