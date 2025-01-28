/*
 * Archivo: football_plays_list.dart
 * Descripción: Este archivo contiene un servicio que permite realizar diferentes operaciones sobre
 *              la base de datos a nivel de jugadores, como añadir jugador, listar jugadores, etc.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/board/video_player_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Funcion para obtener el id del equipo concreto.
Future<String?> getTeamId() async {
  try {
    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').limit(1).get();
    
    if (teamSnapshot.docs.isNotEmpty) {
      return teamSnapshot.docs.first.id;
    } else {
      throw Exception('No se encontraron equipos');
    }
  } catch (e) {
    throw Exception('Error al obtener el teamId: $e');
  }
}

/// Clase de la lista de videos
class VideoList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función que permite modificar el fondo de las tarjetas de los videos.
  String getBackgroundImage(String type) {
    switch (type) {
      case 'ataque':
        return 'assets/image/ataque_type.png';
      case 'defensa':
        return 'assets/image/defensa_type.png';
      default:
        return 'assets/image/default_type.png';
    }
  }

  // Función que permite modificar el icono que aparece en las tarjetas de los videos.
  IconData getIconForType(String type) {
    switch (type) {
      case 'ataque':
        return Icons.sports_soccer;
      case 'defensa':
        return Icons.shield_rounded;
      default:
        return Icons.video_library;
    }
  }

  // Función que permite eliminar videos con confirmación.
  Future<void> _confirmDelete(BuildContext context, String documentId, String videoUrl) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Video'),
          content: const Text('¿Estás seguro de que deseas eliminar este video?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteVideo(context, documentId, videoUrl);
    }
  }

  // Función que elimina un video.
  Future<void> _deleteVideo(BuildContext context, String documentId, String videoUrl) async {
    try {
      // Eliminar el video de Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(videoUrl);
      await storageRef.delete();

      // Obtener el teamId (si es una función asincrónica)
      String? teamId = await getTeamId();

      // Ahora eliminar el documento de Firestore
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId) 
          .collection('football_plays')
          .doc(documentId)
          .delete();

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video eliminado con éxito')),
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el video: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getTeamId(),
      builder: (context, teamIdSnapshot) {
        if (teamIdSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (teamIdSnapshot.hasError) {
          return Center(child: Text('Error: ${teamIdSnapshot.error}'));
        }

        // Verifica si se obtuvo un ID de equipo
        if (!teamIdSnapshot.hasData || teamIdSnapshot.data == null) {
          return const Center(child: Text('No hay equipos disponibles.'));
        }

        String teamId = teamIdSnapshot.data!;

        // Ahora podemos usar el teamId para crear el StreamBuilder
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('teams')
              .doc(teamId)
              .collection('football_plays')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay videos guardados'));
            }

            final videos = snapshot.data!.docs;

            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final plays = videos[index];
                final nombre = plays['name'] ?? 'Sin nombre';
                final tipo = plays['type'] ?? 'desconocido';
                final videoUrl = plays['videoUrl'] ?? '';
                final documentId = plays.id;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(getBackgroundImage(tipo)),
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
                              const SizedBox(width: 12.0),
                              Text(nombre, style: const TextStyle(fontSize: 14, color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  if (videoUrl.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('URL del video no disponible')),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
                                    ),
                                  );
                                },
                                tooltip: 'Ver Video',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDelete(context, documentId, videoUrl),
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
            );
          },
        );
      },
    );
  }
}
