/*
 * Archivo: photo_viewer_screen.dart
 * Descripción: Este archivo contiene la definición de la clase PhotoViewerScreen, 
 *              para visualizar las fotos subidas a Firebase.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';

class PhotoViewerScreen extends StatelessWidget {
  final String photoUrl;

  const PhotoViewerScreen({Key? key, required this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Foto'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(photoUrl), 
        ),
      ),
    );
  }
}
