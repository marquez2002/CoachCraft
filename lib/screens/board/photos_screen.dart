import 'package:flutter/material.dart';
import 'package:CoachCraft/widgets/plays/photos_list.dart';
import 'package:CoachCraft/widgets/plays/upload_photo_form.dart';

class PhotosScreen extends StatefulWidget {
  @override
  _PhotosScreenState createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  bool _isExpanded = false; // Controla el estado de expansión

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar con botón de acción
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Imágenes'),
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
                    UploadPhotosForm(), 
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),

          // Lista de videos usando SliverToBoxAdapter
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6, // Establecer altura para evitar problemas de desbordamiento
              child: PhotosList(), // Este widget contiene la lista de videos
            ),
          ),
        ],
      ),
    );
  }
}
