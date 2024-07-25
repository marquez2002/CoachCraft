/*import 'package:CoachCraft/models/player.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FootballPlayersList extends StatefulWidget {
  const FootballPlayersList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FootballPlayersListState createState() => _FootballPlayersListState();
}

class _FootballPlayersListState extends State<FootballPlayersList> {
  final _playersStream = FirebaseFirestore.instance.collection('teams').doc('teamID').collection('players').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Jugadores'),
        backgroundColor: Color.fromARGB(255, 54, 45, 46),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _playersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Player> players = snapshot.data!.docs.map((document) => Player.fromMap(document.data())).toList();

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                title: Text(player.name),
                subtitle: Text('Dorsal: ${player.dorsal}, Posición: ${player.position}'),
                onTap: () {
                  // Navigate to a player details screen or perform other actions
                },
              );
            },
          );
        },
      ),
    );
  }
}*/
