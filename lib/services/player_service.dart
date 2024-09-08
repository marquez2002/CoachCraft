import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCurrentPlayers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('team').get();
      return snapshot.docs.map((doc) {
        return {
          'name': doc['nombre'], // Asegúrate de que el campo 'name' existe
          'number': doc['dorsal'], // Campo para el dorsal
          'position': doc['posicion'], // Campo para la posición
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener jugadores: $e');
    }
  }
}


