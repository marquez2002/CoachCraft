import 'package:CoachCraft/screens/football_conv_player_screen.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class FootballListPlayer extends StatefulWidget {
  const FootballListPlayer({super.key});

  @override
  _FootballListPlayerState createState() => _FootballListPlayerState();
}

class _FootballListPlayerState extends State<FootballListPlayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jugadores'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No players found.'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Dorsal')),
                          DataColumn(label: Text('Posición')),
                          DataColumn(label: Text('Edad')),
                          DataColumn(label: Text('Altura')),
                          DataColumn(label: Text('Peso')),
                        ],
                        rows: snapshot.data!.map((player) {
                          String playerName = player['nombre'] ?? 'Nombre no disponible';
                          String playerDorsal = player['dorsal']?.toString() ?? 'Dorsal no disponible';
                          String playerPosition = player['posicion'] ?? 'Posición no disponible';
                          String playerEdad = player['edad']?.toString() ?? 'Edad no disponible';
                          String playerAltura = player['altura']?.toString() ?? 'Altura no disponible';
                          String playerPeso = player['peso']?.toString() ?? 'Peso no disponible';
                          return DataRow(cells: [
                            DataCell(Text(playerName)),
                            DataCell(Text(playerDorsal)),
                            DataCell(Text(playerPosition)),
                            DataCell(Text(playerEdad)),
                            DataCell(Text(playerAltura)),
                            DataCell(Text(playerPeso)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
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
                    child: Text('Convocatoria'),
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
