import 'package:flutter/material.dart';

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

class _FootballPieceState extends State<FootballPiece> {
  late Offset _position;

  // Tamaño mínimo y máximo de la pieza
  static const double minPieceSize = 1; // tamaño mínimo en píxeles
  static const double maxPieceSize = 300; // tamaño máximo en píxeles

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
    double pieceSize = screenHeight * 0.125; // 5% de la altura de la pantalla

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
          widget.image,
          width: pieceSize, // Tamaño calculado dependiente de la pantalla
          height: pieceSize, // Tamaño calculado dependiente de la pantalla
        ),
      ),
    );
  }
}
