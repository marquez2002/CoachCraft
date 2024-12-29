/*
 * Archivo: team_list_player_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente al listado de jugadores del equipo.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';
import 'package:CoachCraft/services/player/player_service.dart'; 
import 'team_conv_player_screen.dart'; 
import '../../widgets/player/player_widget.dart'; 

class FootballListPlayer extends StatefulWidget {
  const FootballListPlayer({super.key});

  @override
  _FootballListPlayerState createState() => _FootballListPlayerState();
}

class _FootballListPlayerState extends State<FootballListPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Jugadores'), 
            floating: true, 
            pinned: false, 
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getPlayers(context),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0), 
                        child: Align(
                          alignment: Alignment.topCenter, 
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, 
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width,
                              ),
                              child: PlayerDataTable(players: snapshot.data!), 
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), 
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 200, 
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
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
