import 'package:cloud_firestore/cloud_firestore.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchMatches() async {
    QuerySnapshot snapshot = await _firestore.collection('matches').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'data': doc.data() as Map<String, dynamic>,
    }).toList();
  }

  Future<void> createMatch(Map<String, dynamic> matchData) async {
    await _firestore.collection('matches').add(matchData);
  }
}
