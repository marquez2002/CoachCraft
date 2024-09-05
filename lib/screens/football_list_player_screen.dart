import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'football_conv_player_screen.dart';
import '../widgets/player_widget.dart';

class FootballListPlayer extends StatefulWidget {
  const FootballListPlayer({super.key});

  @override
  _FootballListPlayerState createState() => _FootballListPlayerState();
}

class _FootballListPlayerState extends State<FootballListPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jugadores'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Jugador No Encontrado.'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: PlayerDataTable(players: snapshot.data!),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FootballConvPlayer()),
                      );
                    },
                    child: const Text('Convocatoria'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
