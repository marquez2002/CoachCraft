import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'team_conv_player_screen.dart';
import '../../widgets/player_widget.dart';

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
            return LayoutBuilder(
              builder: (context, constraints) {
                // Se calcula el ancho basado en el tamaño del dispositivo
                double tableWidth = constraints.maxWidth * 0.9; // 90% del ancho disponible

                return Column(
                  children: [
                    // Ajuste aquí para que el contenido esté en la parte superior
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0), // Separar del AppBar
                      child: Align(
                        alignment: Alignment.topCenter, // Alinear en la parte superior y centro
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: tableWidth, // Ajustar el ancho de la tabla
                            ),
                            child: PlayerDataTable(players: snapshot.data!),
                          ),
                        ),
                      ),
                    ),
                    // Botón en la parte inferior
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity, // Botón ocupa todo el ancho
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
              },
            );
          }
        },
      ),
    );
  }
}
