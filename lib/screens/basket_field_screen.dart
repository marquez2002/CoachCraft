import 'package:CoachCraft/widgets/field_painter_widget.dart';
import 'package:CoachCraft/widgets/football_piece_widget.dart';
import 'package:flutter/material.dart';

class BasketFieldScreen extends StatefulWidget {
  const BasketFieldScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BasketFieldScreenState createState() => _BasketFieldScreenState();
}

class _BasketFieldScreenState extends State<BasketFieldScreen> {
  List<Offset> points = [];
  bool isDrawing = false;

  void _toggleDrawing() {
    setState(() {
      isDrawing = !isDrawing;
      if (!isDrawing) {
        points.clear();
      }
    });
  }

  void _clearDrawing() {
    setState(() {
      points.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' '),
        backgroundColor: const Color.fromARGB(255, 54, 45, 46),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleDrawing,
            icon: Icon(isDrawing ? Icons.brush : Icons.edit),
            tooltip: isDrawing ? 'Dejar de dibujar' : 'Dibujar',
          ),
          IconButton(
            onPressed: _clearDrawing,
            icon: const Icon(Icons.delete),
            tooltip: 'Borrar',
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 54, 45, 46),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/image/basketball_field.png',
                fit: BoxFit.contain,
              ),
            ),
            GestureDetector(
              onPanUpdate: (details) {
                if (isDrawing) {
                  setState(() {
                    points.add(details.localPosition);
                  });
                }
              },
              onPanEnd: (details) {
                if (isDrawing) {
                  setState(() {
                    points.add(const Offset(-1, -1));
                  });
                }
              },
              child: CustomPaint(
                painter: FieldPainter(points),
                child: Container(),
              ),
            ),
            const FootballPiece(position: Offset(0.45, 0.2), image: 'assets/image/player_teamA.png'),
            const FootballPiece(position: Offset(0.15, 0.2), image: 'assets/image/player_teamA.png'),
            const FootballPiece(position: Offset(0.3, 0.12), image: 'assets/image/player_teamA.png'),
            const FootballPiece(position: Offset(0.45, 0.12), image: 'assets/image/player_teamA.png'),
            const FootballPiece(position: Offset(0.25, 0.25), image: 'assets/image/player_teamA.png'),
            const FootballPiece(position: Offset(0.45, 0.8), image: 'assets/image/balon_futsal.png'),
            const FootballPiece(position: Offset(0.45, 0.8), image: 'assets/image/player_teamB.png'),
            const FootballPiece(position: Offset(0.65, 0.5), image: 'assets/image/player_teamB.png'),
            const FootballPiece(position: Offset(0.35, 0.65), image: 'assets/image/player_teamB.png'),
            const FootballPiece(position: Offset(0.45, 0.7), image: 'assets/image/player_teamB.png'),
            const FootballPiece(position: Offset(0.45, 0.45), image: 'assets/image/player_teamB.png'),
          ],
        ),
      ),
    );
  }
}
