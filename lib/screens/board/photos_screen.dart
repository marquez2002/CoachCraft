import 'package:CoachCraft/widgets/plays/photos_list.dart';
import 'package:CoachCraft/widgets/plays/upload_photo_form.dart';
import 'package:flutter/material.dart';


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

          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de formulario de carga de fotos
                      if (_isExpanded) // Solo muestra el formulario si está expandido
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Subida de Fotos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            UploadPhotosForm(), 
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      // Lista de fotos
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7, 
                        child: PhotosList(), 
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
