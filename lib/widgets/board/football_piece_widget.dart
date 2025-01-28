/*
 * Archivo: football_piece_widget.dart
 * Descripción: Este archivo contiene la clase correspondiente a la fichas/tazos de la pizarra.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';

/// Clase correspondiente con las fichas de los jugadores.
class FootballPiece extends StatefulWidget {
  final Offset position;
  final String image;

  const FootballPiece({
    required this.position,
    required this.image,
    super.key,
  });

  @override
  _FootballPieceState createState() => _FootballPieceState();
}

/// Clase correspondiente al estado de las fichas de los jugadores.
class _FootballPieceState extends State<FootballPiece> {
  late Offset _position;

  // Tamaño mínimo y máximo de la pieza
  static const double minPieceSize = 1; 
  static const double maxPieceSize = 300;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calcular el tamaño de la pieza en función de la altura de la pantalla
    double pieceSize = screenHeight * 0.125; 

    // Ajustar el tamaño entre el tamaño mínimo y máximo
    pieceSize = pieceSize.clamp(minPieceSize, maxPieceSize);

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
          width: pieceSize, 
          height: pieceSize, 
        ),
      ),
    );
  }
}
