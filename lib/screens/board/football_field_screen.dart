/*
 * Archivo: mid_football_field_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente a la pizarra táctica de pista completa.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/board/mid_football_field_screen.dart';
import 'package:CoachCraft/screens/board/recording_plays_screen.dart';
import 'package:CoachCraft/screens/board/photos_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:CoachCraft/widgets/board/ball_widget.dart';
import 'package:CoachCraft/widgets/board/field_painter_widget.dart';
import 'package:CoachCraft/widgets/board/football_piece_widget.dart';
import 'package:flutter/material.dart';
/*import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';*/

class FootballFieldScreen extends StatefulWidget {
  const FootballFieldScreen({Key? key}) : super(key: key);

  @override
  _FootballFieldScreenState createState() => _FootballFieldScreenState();
}

class _FootballFieldScreenState extends State<FootballFieldScreen> {
  List<Offset> points = [];
  bool isDrawing = false;
  GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;
  Color drawColor = Colors.red;
  //bool _isRecording = false;
  String? videoPath;

  // Inicializa posiciones proporcionales al tamaño de la imagen (0.0 - 1.0)  
  final List<Map<String, dynamic>> _initialPositions = [
    {'position': Offset(0.30, 0.53), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.49), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.45), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.41), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.30, 0.37), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.70, 0.53,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.49,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.45,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.41,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.70, 0.37,), 'image': 'assets/image/player_teamB.png'},
  ];

  late List<Offset> _currentPositions;

  @override
  void initState() {
    super.initState();
    _currentPositions = _initialPositions.map((e) => e['position'] as Offset).toList();
    //_checkPermissions();

  }

  void _toggleDrawing() {
    setState(() {
      isDrawing = !isDrawing;
      if (!isDrawing) {
        points.clear();
      }
    });
  }

  // Función para elegir el color
  void _setColor(Color color) {
    setState(() {
      drawColor = color;
    });
  }

  // Función para navegar entre screen.
  void _navigateToScreen(int screenNumber) {
    if (screenNumber == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MidFootballFieldScreen()));
    } else if (screenNumber == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RecordingPlayScreen()));
    } else if (screenNumber == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PhotosScreen()));
    } else {
      print('Número de pantalla no válido: $screenNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' '),
        backgroundColor: const Color.fromARGB(255, 54, 45, 46),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreenFutsal()));
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToScreen(1),
            icon: const Icon(Icons.airline_stops_outlined),
            tooltip: 'Ir a pizarra de media pista',
          ),
          IconButton(
            onPressed: () => _navigateToScreen(3),
            icon: const Icon(Icons.photo_camera),
            tooltip: 'Ir a galeria',
          ),
          IconButton(
            onPressed: () => _navigateToScreen(2),
            icon: const Icon(Icons.folder),
            tooltip: 'Ir a grabaciones',
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
                    'assets/image/football_field.png',
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
                painter: FieldPainter(points, drawColor),
                child: LayoutBuilder(
                  builder: (context, constraints) {
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
                          ...List.generate(_currentPositions.length, (index) {
                            return FootballPiece(
                              position: _currentPositions[index],
                              image: _initialPositions[index]['image'],
                            );
                          }),
                          Ball(
                            initialPosition: Offset(0.48, 0.44),
                            image: 'assets/image/balon_futsal.png',
                          ),
                          Positioned(
                            bottom: 10,
                            right: MediaQuery.of(context).size.width * 0.05,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _setColor(Colors.red),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: Size(MediaQuery.of(context).size.width * 0.02, 30),
                                  ),
                                  child: const Icon(
                                    Icons.edit, // Ícono de lápiz
                                    color: Colors.white, // Color del ícono (opcional, ajustado para contrastar)
                                  ),
                                ),
                                const SizedBox(height: 10), 
                                ElevatedButton(
                                  onPressed: () => _setColor(Colors.yellow),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                    minimumSize: Size(MediaQuery.of(context).size.width * 0.02, 30),
                                  ),
                                  child: const Icon(
                                    Icons.edit, // Ícono de lápiz
                                    color: Colors.white, // Color del ícono (opcional)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox();
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
