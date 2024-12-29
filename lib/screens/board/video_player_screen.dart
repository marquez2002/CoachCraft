/*
 * Archivo: video_player_screen.dart
 * Descripción: Este archivo contiene la definición de la clase VideoPlayerScreen, 
 *              para visualizar los videos de jugadas subidas a Firebase.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
import 'dart:io';
import 'package:flutter/material.dart';
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
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  
  // Funcion para inicializar el video.
  Future<void> _initializeVideo() async {
    if (widget.videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    } else {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }

    await _controller.initialize(); 

    setState(() {
      _isLoading = false; 
      _isPlaying = true;
    });

    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reproducir Video'),
      ),
      body: GestureDetector(
        onTap: () {          
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
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator() 
              : Column(
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
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
