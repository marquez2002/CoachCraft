import 'package:cloud_firestore/cloud_firestore.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createMatch(Map<String, dynamic> matchData) async {
    DocumentReference docRef = await _firestore.collection('matches').add(matchData);
    return docRef.id; // Retorna el ID del nuevo partido creado
  }

  Future<void> savePlayersForMatch(String matchId, List<Map<String, dynamic>> players) async {
    try {
      // Guardar los jugadores en una subcolección dentro del documento del partido
      for (var player in players) {
        await _firestore.collection('matches').doc(matchId).collection('players').add(player);
      }
    } catch (e) {
      throw Exception('Error al guardar jugadores para el partido: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMatches() async {
    QuerySnapshot snapshot = await _firestore.collection('matches').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'data': doc.data() as Map<String, dynamic>,
    }).toList();
  }
}

