import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCurrentPlayers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('team').get();
      return snapshot.docs.map((doc) {
        return {
          'name': doc['nombre'], // Asegúrate de que el campo 'name' existe
          'dorsal': doc['dorsal'], // Campo para el dorsal
          'posicion': doc['posicion'], // Campo para la posición
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener jugadores: $e');
    }
  }
}

Future<void> deletePlayerByDorsal(int dorsal) async {
  try {
    // Referencia a la colección de jugadores
    CollectionReference playersCollection = FirebaseFirestore.instance.collection('team');

    // Buscar al jugador con el dorsal especificado
    QuerySnapshot querySnapshot = await playersCollection.where('dorsal', isEqualTo: dorsal).get();

    // Verificar si se encontró algún jugador con ese dorsal
    if (querySnapshot.docs.isNotEmpty) {
      // Eliminar el primer jugador encontrado (asume que solo hay un jugador con ese dorsal)
      await playersCollection.doc(querySnapshot.docs.first.id).delete();
      print('Jugador con dorsal $dorsal eliminado exitosamente.');
    } else {
      print('No se encontró ningún jugador con dorsal $dorsal.');
    }
  } catch (e) {
    print('Error al eliminar el jugador: $e');
  }
}
