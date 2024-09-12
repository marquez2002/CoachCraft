// lib/screens/recording_plays_screen.dart
import 'package:flutter/material.dart';

class RecordingPlayScreen extends StatelessWidget {
// Asegúrate de marcar como required

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabaciones'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Video ${index + 1}'),
            onTap: () {
              // Aquí puedes agregar la lógica para reproducir el video
            },
          );
        },
      ),
    );
  }
}
