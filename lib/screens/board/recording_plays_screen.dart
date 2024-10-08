import 'package:flutter/material.dart';
import 'package:CoachCraft/widgets/plays/football_plays_list.dart';
import 'package:CoachCraft/widgets/plays/upload_plays_form.dart';

class RecordingPlayScreen extends StatefulWidget {
  @override
  _RecordingPlayScreenState createState() => _RecordingPlayScreenState();
}

class _RecordingPlayScreenState extends State<RecordingPlayScreen> {
  bool _isExpanded = false; // Controla el estado de expansión

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true, 
            snap: true, 
            title: const Text('Jugadas'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add), 
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded; 
                  });
                },
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de formulario de carga
                      if (_isExpanded) // Solo muestra el formulario si está expandido
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Subida de Jugadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 1.0),
                            UploadForm(), // Muestra el formulario de subida de jugadas
                            const SizedBox(height: 1.0),
                          ],
                        ),
                      // Lista de videos filtrados
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7, // Puedes ajustar el tamaño
                        child: VideoList(), // Llama a VideoList aquí
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
