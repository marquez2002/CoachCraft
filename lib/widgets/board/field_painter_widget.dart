import 'package:flutter/material.dart';

class FieldPainter extends CustomPainter {
  final List<Offset> points;
  final Color drawColor;

  FieldPainter(this.points, this.drawColor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = drawColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0; // Cambia el ancho del trazo según sea necesario

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset(-1, -1) && points[i + 1] != Offset(-1, -1)) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
