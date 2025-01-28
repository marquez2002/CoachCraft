/*
 * Archivo: ball_widget.dart
 * Descripción: Este archivo contiene la clase correspondiente a la bola de la pizarra.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';

/// Clase de la bola en la pizarra táctica
class Ball extends StatefulWidget {
  final Offset initialPosition; 
  final String image;

  const Ball({
    required this.initialPosition,
    required this.image,
    super.key,
  });

  @override
  _BallState createState() => _BallState();
}

/// Clase del estado de la bola en la pizarra táctica
class _BallState extends State<Ball> {
  late Offset _position;

  static const double minBallSize = 1; 
  static const double maxBallSize = 300;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    double ballSize = screenHeight * 0.07; 

    // Ajustar el tamaño entre el tamaño mínimo y máximo
    ballSize = ballSize.clamp(minBallSize, maxBallSize);

    return Positioned(
      left: screenWidth * _position.dx,
      top: screenHeight * _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            Offset newPosition = _position + Offset(
              details.delta.dx / screenWidth,
              details.delta.dy / screenHeight,
            );

            // Asegúrate de que la nueva posición esté dentro de los límites
            newPosition = Offset(
              newPosition.dx.clamp(0.0, 1.0),
              newPosition.dy.clamp(0.0, 1.0),
            );

            _position = newPosition;
          });
        },
        child: Image.asset(
          // Tamaño calculado dependiente de la pantalla
          widget.image,
          width: ballSize, 
          height: ballSize,
        ),
      ),
    );
  }
}
