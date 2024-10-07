import 'package:CoachCraft/screens/board/football_field_screen.dart';
import 'package:CoachCraft/screens/board/recording_plays_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:CoachCraft/widgets/board/ball_widget.dart';
import 'package:CoachCraft/widgets/board/field_painter_widget.dart';
import 'package:CoachCraft/widgets/board/football_piece_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:intl/intl.dart';

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
  bool _isRecording = false;
  String? videoPath; // Ruta del video grabado

  // Inicializa posiciones proporcionales al tamaño de la imagen (0.0 - 1.0)
  final List<Map<String, dynamic>> _initialPositions = [
    {'position': Offset(0.53, 0.30), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.49, 0.30), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.45, 0.30), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.41, 0.30), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.37, 0.30), 'image': 'assets/image/player_teamA.png'},
    {'position': Offset(0.53, 0.70,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.49, 0.70,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.45, 0.70,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.41, 0.70,), 'image': 'assets/image/player_teamB.png'},
    {'position': Offset(0.37, 0.70,), 'image': 'assets/image/player_teamB.png'},
    
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

  void _navigateToScreen(int screenNumber) {
  if (screenNumber == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FootballFieldScreen()),
    );
  } else if (screenNumber == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecordingPlayScreen()),
    );
  } else {
    // Manejo de error si el número no es válido (opcional)
    print('Número de pantalla no válido: $screenNumber');
  }
}


  Future<void> _startRecording() async {
    // Obtiene la fecha y hora actual para el nombre del archivo
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd_HHmmss');
    String formattedDate = dateFormat.format(now);

    // Establece la ruta del video con la fecha y hora
    videoPath = '/football_plays_$formattedDate.mp4';

    // Inicia la grabación
    await FlutterScreenRecording.startRecordScreen(videoPath!);

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    // Detén la grabación
    await FlutterScreenRecording.stopRecordScreen;

    setState(() {
      _isRecording = false;
    });

    // Aquí podrías guardar el video o hacer algo más con él.
    // Por ejemplo, podrías mostrar un mensaje al usuario.
    print('Video grabado en: $videoPath');
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
            // Redirigir a la pantalla de menú Futsal cuando se presiona el botón de atrás
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MenuScreenFutsal(), 
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
            onPressed: _isRecording ? _stopRecording : _startRecording,
            tooltip: _isRecording ? 'Detener Grabación' : 'Iniciar Grabación',
          ),
          IconButton(
            onPressed: () => _navigateToScreen(1), // Navega a MidFootballFieldScreen
            icon: const Icon(Icons.airline_stops_outlined),
            tooltip: 'Ir a pizarra de media pista',
          ),
          IconButton(
            onPressed: () => _navigateToScreen(2), // Navega a RecordingPlayScreen
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
                            initialPosition: Offset(0.48, 0.48), // Posición inicial en el centro
                            image: 'assets/image/balon_futsal.png',
                          ),
                          // Botones de color
                          Positioned(
                            bottom: 10,
                            right: MediaQuery.of(context).size.width * 0.05, // Posiciona los botones a la derecha
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
                              children: [
                                ElevatedButton(
                                  onPressed: () => _setColor(Colors.red),
                                  child: const Text(''), // Puedes agregar un texto si es necesario
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: Size(MediaQuery.of(context).size.width * 0.02, 30), // Ajusta el ancho del botón
                                  ),
                                ),
                                const SizedBox(height: 0.00000000001), // Espaciador entre los botones
                                ElevatedButton(
                                  onPressed: () => _setColor(Colors.yellow),
                                  child: const Text(''), // Puedes agregar un texto si es necesario
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                    minimumSize: Size(MediaQuery.of(context).size.width * 0.02, 30), // Ajusta el ancho del botón
                                  ),
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

  