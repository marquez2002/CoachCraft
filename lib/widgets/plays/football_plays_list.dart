import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VideoList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getBackgroundImage(String type) {
    switch (type) {
      case 'ataque':
        return 'assets/image/ataque_type.png';
      case 'defensa':
        return 'assets/image/defensa_type.png';
      default:
        return 'assets/image/ataque_type.png'; // Imagen por defecto si no se encuentra el tipo
    }
  }

  IconData getIconForType(String type) {
    switch (type) {
      case 'ataque':
        return Icons.sports_soccer; // Ícono de balón de fútbol
      case 'defensa':
        return Icons.shield_rounded; // Ícono de candado
      default:
        return Icons.help; // Ícono por defecto si no se encuentra el tipo
    }
  }

  Future<void> _viewVideo(String videoUrl) async {

  }

  Future<void> _deleteVideo(String documentId, String videoUrl) async {

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('football_plays').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay videos guardados'));
        }

        final videos = snapshot.data!.docs;

        double screenWidth = MediaQuery.of(context).size.width;

        // Calcula cuántas tarjetas se pueden mostrar en una fila
        int crossAxisCount;
        if (screenWidth < 600) {
          crossAxisCount = 2; // Móviles
        }  else {
          crossAxisCount = 3; // Pantallas más grandes
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jugadas Guardadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Usar el número calculado de tarjetas por fila
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final plays = videos[index];
                  final nombre = plays['name'];
                  final tipo = plays['type'];
                  final videoUrl = plays['videoUrl']; // Asumiendo que el URL del video está en el campo 'videoUrl'
                  final documentId = plays.id; // El ID del documento para eliminar

                  return Card(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(getBackgroundImage(tipo)), // Se utiliza el tipo de la jugada
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(getIconForType(tipo), size: 20, color: Colors.black),
                                const SizedBox(width: 8.0),
                                Text('$nombre', style: const TextStyle(fontSize: 14, color: Colors.black)),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  onPressed: () => _viewVideo(videoUrl),
                                  tooltip: 'Ver Video',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Aquí puedes implementar la lógica para modificar el video
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Modificar video no implementado')),
                                    );
                                  },
                                  tooltip: 'Modificar Video',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteVideo(documentId, videoUrl),
                                  tooltip: 'Eliminar Video',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
