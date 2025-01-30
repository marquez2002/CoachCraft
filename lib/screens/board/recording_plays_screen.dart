import 'package:flutter/material.dart';
import 'package:CoachCraft/widgets/plays/football_plays_list.dart';
import 'package:CoachCraft/widgets/plays/upload_plays_form.dart';


class RecordingPlayScreen extends StatefulWidget {
  @override
  _RecordingPlayScreenState createState() => _RecordingPlayScreenState();
}

class _RecordingPlayScreenState extends State<RecordingPlayScreen> {
  bool _isExpanded = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar con el botón de acción
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

          // Si el formulario de subida está expandido, lo mostramos aquí
          if (_isExpanded)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subida de Jugadas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    UploadForm(), 
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),

          SliverFillRemaining(
              hasScrollBody: true,
              child: VideoList(), 
          ),
        ],
      ),
    );
  }
}