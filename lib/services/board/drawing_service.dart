// lib/services/drawing_service.dart
import 'package:flutter/material.dart';

class DrawingService {
  Color drawColor = Colors.red; // Color por defecto
  bool isDrawing = false; // Estado del dibujo

  void toggleDrawing() {
    isDrawing = !isDrawing;
  }

  void setColor(Color color) {
    drawColor = color;
  }
}
