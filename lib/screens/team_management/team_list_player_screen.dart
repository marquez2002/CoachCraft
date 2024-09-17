/*
 * Archivo: team_list_player_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente con listar los jugadores
 *              de un equipo concreto situado en firebase.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
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
      appBar: AppBar(
        title: const Text('Jugadores'), 
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getPlayers(),
        builder: (context, snapshot) {
          // Manejo de diferentes estados de la conexión
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); 
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); 
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Jugador No Encontrado.')); 
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Se calcula el ancho basado en el tamaño del dispositivo
                double tableWidth = constraints.maxWidth; // Ancho máximo de la tabla

                return Column(
                  children: [
                    // Ajuste aquí para que el contenido esté en la parte superior
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0), 
                      child: Align(
                        alignment: Alignment.topCenter, 
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, 
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: tableWidth, 
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
              },
            );
          }
        },
      ),
    );
  }
}
