import 'package:CoachCraft/widgets/plays/football_plays_list.dart';
import 'package:CoachCraft/widgets/plays/upload_plays_form.dart';
import 'package:flutter/material.dart';

class RecordingPlayScreen extends StatefulWidget {
  @override
  _RecordingPlayScreenState createState() => _RecordingPlayScreenState();
}

class _RecordingPlayScreenState extends State<RecordingPlayScreen> {
  bool _isExpanded = false; // Controla el estado de expansión

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabaciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded; // Cambia el estado de expansión
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subida de Jugadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more), // Ícono de expansión
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            if (_isExpanded) // Solo muestra el formulario si está expandido
              UploadForm(),
            const SizedBox(height: 16.0),
            Expanded(child: VideoList()), // Llama a VideoList aquí
          ],
        ),
      ),
    );
  }
}