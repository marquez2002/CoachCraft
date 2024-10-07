import 'package:flutter/material.dart';

class Ball extends StatefulWidget {
  final Offset initialPosition; // Posición inicial del balón
  final String image;

  const Ball({
    required this.initialPosition,
    required this.image,
    super.key,
  });

  @override
  _BallState createState() => _BallState();
}

class _BallState extends State<Ball> {
  late Offset _position;

  // Tamaño mínimo y máximo del balón
  static const double minBallSize = 1; // tamaño mínimo en píxeles
  static const double maxBallSize = 300; // tamaño máximo en píxeles

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition; // Establece la posición inicial
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calcular el tamaño del balón en función de la altura de la pantalla
    double ballSize = screenHeight * 0.07; // 10% de la altura de la pantalla

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
          widget.image,
          width: ballSize, // Tamaño calculado dependiente de la pantalla
          height: ballSize, // Tamaño calculado dependiente de la pantalla
        ),
      ),
    );
  }
}
