
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getPlayers() async {
  List<Map<String, dynamic>> players = [];
  CollectionReference collectionReferencePlayers = FirebaseFirestore.instance.collection('team');
  QuerySnapshot queryPlayers = await collectionReferencePlayers.get();
  queryPlayers.docs.forEach((doc) {
    players.add(doc.data() as Map<String, dynamic>);
  });

  players.sort((a, b) {
    int dorsalA = int.tryParse(a['dorsal']?.toString() ?? '0') ?? 0;
    int dorsalB = int.tryParse(b['dorsal']?.toString() ?? '0') ?? 0;
    return dorsalA.compareTo(dorsalB);
  });

  return players;
}

// Función para añadir un jugador a Firestore
Future<void> addPlayer(Map<String, dynamic> playerData) async {
  try {
    await FirebaseFirestore.instance.collection('team').add(playerData);
  } catch (e) {
    throw Exception('Error adding player: $e');
  }
}

// Función para modificar el jugador
Future<void> modifyPlayer(int dorsal, Map<String, dynamic> playerData) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('team')
        .where('dorsal', isEqualTo: dorsal)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('team')
          .doc(docId) // Usar el ID del documento
          .update(playerData);
    } else {
      throw Exception("Jugador con dorsal $dorsal no encontrado");
    }
  } catch (e) {
    throw Exception('Error al modificar jugador: $e');
  }
}

