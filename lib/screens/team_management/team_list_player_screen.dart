import 'package:flutter/material.dart';
import 'package:CoachCraft/services/player/player_service.dart'; 
import 'team_conv_player_screen.dart'; 
import '../../widgets/player/player_widget.dart'; 

/// Widget principal que representa la lista de jugadores de fútbol.
class FootballListPlayer extends StatefulWidget {
  const FootballListPlayer({super.key});

  @override
  _FootballListPlayerState createState() => _FootballListPlayerState();
}

/// Estado del widget FootballListPlayer que maneja la lógica de la interfaz.
class _FootballListPlayerState extends State<FootballListPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Jugadores'), // Título de la AppBar
            floating: true, // Permite que la AppBar flote
            pinned: false, // La AppBar no permanecerá fijada en la parte superior
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getPlayers(context),
              builder: (context, snapshot) {
                // Manejo de diferentes estados de la conexión
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
                                maxWidth: MediaQuery.of(context).size.width, // Ancho máximo de la tabla
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
                              // Navegar a la pantalla de convocatoria de jugadores
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
