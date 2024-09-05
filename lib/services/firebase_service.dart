
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

