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
            title: const Text('Fotos'),
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

          // Si el formulario de fotos está expandido, lo mostramos aquí
          if (_isExpanded) 
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subida de Fotos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    UploadPhotosForm(),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),

          // SliverList para la lista de fotos
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,  // Ajusta el tamaño según sea necesario
              child: PhotosList(), // Asegúrate de que PhotosList tenga un tamaño definido y sea scrollable
            ),
          )
        ],
      ),
    );
  }
}
