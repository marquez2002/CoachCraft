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

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition; // Establece la posición inicial
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * _position.dx,
      top: MediaQuery.of(context).size.height * _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            Offset newPosition = _position + Offset(
              details.delta.dx / MediaQuery.of(context).size.width,
              details.delta.dy / MediaQuery.of(context).size.height,
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
          width: 70, // Tamaño del balón
          height: 70,
        ),
      ),
    );
  }
}
