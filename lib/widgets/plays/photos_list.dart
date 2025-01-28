/*
 * Archivo: photos_list.dart
 * Descripción: Este archivo contiene un servicio que permite listar las fotos que se guardan en el sistema.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/board/photo_viewer_screen.dart'; // Pantalla para visualizar fotos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// Función para obtener el teamId
Future<String?> getTeamId() async {
  try {
    // Obtener el primer documento de la colección 'teams'
    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').limit(1).get();
    
    if (teamSnapshot.docs.isNotEmpty) {
      // Retornar el ID del primer equipo encontrado
      return teamSnapshot.docs.first.id;
    } else {
      throw Exception('No se encontraron equipos'); 
    }
  } catch (e) {
    throw Exception('Error al obtener el teamId: $e'); 
  }
}

/// Clase para el listado de fotos
class PhotosList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Función que permite eliminar fotos.
  Future<void> _deletePhoto(BuildContext context, String documentId, String photoUrl) async {
    try {
      // Eliminar la foto de Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(photoUrl);
      await storageRef.delete();

      // Obtener el teamId
      String? teamId = await getTeamId();

      // Ahora eliminar el documento de Firestore
      await FirebaseFirestore.instance.collection('teams')
        .doc(teamId) 
        .collection('photos') 
        .doc(documentId)
        .delete();

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto eliminada con éxito')),
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la foto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getTeamId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Verifica si se obtuvo un ID de equipo
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No hay equipos disponibles.'));
        }

        String teamId = snapshot.data!;

        // Ahora puedes usar el teamId para crear el StreamBuilder
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('teams')
              .doc(teamId)
              .collection('photos') 
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay fotos guardadas'));
            }

            final photos = snapshot.data!.docs;

            double screenWidth = MediaQuery.of(context).size.width;

            // Calcula cuántas tarjetas se pueden mostrar en una fila
            int crossAxisCount;
            if (screenWidth < 600) {
              crossAxisCount = 2; 
            } else {
              crossAxisCount = 4; 
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(' ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, 
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      final name = photo['name'];
                      final photoUrl = photo['photoUrl']; 
                      final documentId = photo.id; 

                      return Card(
                        child: GestureDetector(
                          onTap: () {
                            // Navega a la pantalla de visualización de fotos
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewerScreen(photoUrl: photoUrl),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(photoUrl), 
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('$name', style: const TextStyle(fontSize: 14, color: Colors.white)),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deletePhoto(context, documentId, photoUrl),
                                        tooltip: 'Eliminar Foto',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      },
    );
  }
}
