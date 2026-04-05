import 'package:flutter/material.dart';

class MeasurementPainterOverlay extends CustomPainter {
  final Offset? point1;
  final Offset? point2;
  final String? distanceLabel;

  MeasurementPainterOverlay({this.point1, this.point2, this.distanceLabel});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.yellowAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final borderPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke;

    if (point1 != null && point2 != null) {
      canvas.drawLine(point1!, point2!, borderPaint);
      canvas.drawLine(point1!, point2!, linePaint);
    }

    if (point1 != null) {
      _drawDot(canvas, point1!, dotPaint, '1');
    }
    if (point2 != null) {
      _drawDot(canvas, point2!, dotPaint, '2');
    }

    if (point1 != null && point2 != null && distanceLabel != null) {
      final mid = Offset(
        (point1!.dx + point2!.dx) / 2,
        (point1!.dy + point2!.dy) / 2,
      );
      _drawDistanceLabel(canvas, distanceLabel!, mid);
    }
  }

  void _drawDot(Canvas canvas, Offset center, Paint fill, String label) {
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 10, fill);
    canvas.drawCircle(center, 10, border);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawDistanceLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const pad = 8.0;
    final rect = Rect.fromCenter(
      center: center - const Offset(0, 24),
      width: tp.width + pad * 2,
      height: tp.height + pad,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = Colors.black87,
    );
    tp.paint(canvas, Offset(rect.left + pad, rect.top + pad / 2));
  }

  @override
  bool shouldRepaint(MeasurementPainterOverlay old) =>
      old.point1 != point1 ||
      old.point2 != point2 ||
      old.distanceLabel != distanceLabel;
}
