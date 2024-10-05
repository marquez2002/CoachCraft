import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Verificamos si el videoUrl es un archivo local o un enlace de red
    if (widget.videoUrl.startsWith('http')) {
      // Si es un URL, usamos VideoPlayerController.networkUrl
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    } else {
      // Si es un archivo local, usamos VideoPlayerController.file
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }

    await _controller.initialize(); // Inicializar el controlador
    setState(() {}); 

    // Autoplay del video
    _controller.play();
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Asegurarse de liberar recursos cuando el widget se destruye
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen ? null : AppBar(
        title: Text('Reproducir Video'),
      ),
      body: GestureDetector(
        onTap: _toggleFullScreen, 
        child: Center(
          child: _controller.value.isInitialized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                                _isPlaying = false;
                              } else {
                                _controller.play();
                                _isPlaying = true;
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: () {
                            setState(() {
                              _controller.seekTo(Duration.zero);
                              _controller.pause();
                              _isPlaying = false;
                            });
                          },
                        ),
                        // Botón para pantalla completa
                        IconButton(
                          icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    ),
                  ],
                )
              : CircularProgressIndicator(), 
        ),
      ),
    );
  }
}
