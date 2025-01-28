/*
 * Archivo: field_painter_widget.dart
 * Descripción: Este archivo contiene la clase correspondiente a los puntos y el color del dibujo en la pizarra.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';

/// Clase con funciones relacionadas para el dibujo en la pizarra táctica.
class FieldPainter extends CustomPainter {
  final List<Offset> points;
  final Color drawColor;

  FieldPainter(this.points, this.drawColor);

  /// Función para dibujar en la pizarra
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = drawColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

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
