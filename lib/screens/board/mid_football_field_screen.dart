import 'package:CoachCraft/screens/board/football_field_screen.dart';
import 'package:CoachCraft/widgets/board/ball_widget.dart';
import 'package:CoachCraft/widgets/board/field_painter_widget.dart';
import 'package:CoachCraft/widgets/board/football_piece_widget.dart';
import 'package:flutter/material.dart';

class MidFootballFieldScreen extends StatefulWidget {
  const MidFootballFieldScreen({Key? key}) : super(key: key);

  @override
  _MidFootballFieldScreenState createState() => _MidFootballFieldScreenState();
}

class _MidFootballFieldScreenState extends State<MidFootballFieldScreen> {
  List<Offset> points = [];
  bool isDrawing = false;
  GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;
  Color drawColor = Colors.red; // Color por defecto

    // Inicializa posiciones proporcionales al tamaño de la imagen (0.0 - 1.0)
  final List<Map<String, dynamic>> _initialPositions = [
    {'position': Offset(0.30, 0.49), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.45), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.41), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.37), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.33), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.70, 0.49), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.45), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.41), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.37), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.33), 'image': 'assets/image/player_teamB.png'},
  ];


  // Almacena las posiciones actuales de las piezas
  late List<Offset> _currentPositions;

  @override
  void initState() {
    super.initState();
    // Inicializa las posiciones actuales con las posiciones iniciales.
    _currentPositions = _initialPositions.map((e) => e['position'] as Offset).toList();
  }

  void _toggleDrawing() {
    setState(() {
      isDrawing = !isDrawing;
      if (!isDrawing) {
        points.clear();
      }
    });
  }

  void _setColor(Color color) {
    setState(() {
      drawColor = color; // Cambia el color de dibujo
    });
  }

  void _navigateToOtherScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FootballFieldScreen()),
    );
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
            onPressed: _navigateToOtherScreen,
            icon: const Icon(Icons.airline_stops_outlined),
            tooltip: 'Ir a pizarra de media pista',
          ),
          IconButton(
            onPressed: _toggleDrawing,
            icon: Icon(isDrawing ? Icons.block_outlined : Icons.edit_outlined),
            tooltip: isDrawing ? 'Dejar de dibujar' : 'Dibujar',
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 54, 45, 46),
        child: Stack(
          children: [
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Image.asset(
                    'assets/image/mid_football_field.png',
                    key: _imageKey,
                    fit: BoxFit.contain,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  );
                },
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
                painter: FieldPainter(points, drawColor), // Usa el color de dibujo
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Si el tamaño de la imagen no está calculado, actualízalo.
                    if (_imageSize == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final RenderBox renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox;  
                        setState(() {
                          _imageSize = renderBox.size;
                        });
                      });
                    }
                    if (_imageSize != null) {
                      return Stack(
                        children: [
                          // Colocar las piezas de fútbol
                          ...List.generate(_currentPositions.length, (index) {
                            return FootballPiece(
                              position: _currentPositions[index],
                              image: _initialPositions[index]['image'],
                            );
                          }),
                          // Agregar el balón y permitir su movimiento
                          Ball(
                            initialPosition: Offset(0.48, 0.44), // Posición inicial en el centro
                            image: 'assets/image/balon_futsal.png',
                          ),
                          Positioned(
                            bottom: 20,
                            right: MediaQuery.of(context).size.width * 0.1, // Cambiado a right para posicionar a la derecha
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _setColor(Colors.red),
                                  child: const Text(' '),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                ),
                                const SizedBox(width: 10), // Espaciador entre los botones
                                ElevatedButton(
                                  onPressed: () => _setColor(Colors.yellow),
                                  child: const Text(' '),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox(); // Esperando que se calcule el tamaño de la imagen.
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
