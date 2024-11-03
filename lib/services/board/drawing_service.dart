/*
 * Archivo: drawing_service.dart
 * Descripción: Este archivo contiene la clase concreta para dibujar en la pizarra táctica.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
import 'package:flutter/material.dart';

class DrawingService {
  Color drawColor = Colors.red; 
  bool isDrawing = false; 

  /// Función que indica cuando se puede o no se puede dibujar,
  void toggleDrawing() {
    isDrawing = !isDrawing;
  }

  /// Función que permite indicar con que color queremos dibujar.
  void setColor(Color color) {
    drawColor = color;
  }
}
