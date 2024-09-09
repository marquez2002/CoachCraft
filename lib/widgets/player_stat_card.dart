import 'package:flutter/material.dart';
import '../models/player_stats.dart';

class PlayerStatCard extends StatelessWidget {
  final dynamic playerStat;

  const PlayerStatCard({Key? key, required this.playerStat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  playerStat.nombre,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Use a conditional operator to include the icon and spacing if playerStat is a GoalkeeperStats
                if (playerStat.posicion == "Portero") ... [
                  const Icon(Icons.sports_handball, size: 24.0), // Glove icon for goalkeeper
                  const SizedBox(width: 8.0), // Space between icon and text
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatRows(dynamic playerStat) {
    if (playerStat is PlayerStats) {
      return [
        Text('Goles: ${playerStat.goals}'),
        Text('Asistencias: ${playerStat.assists}'),
        Text('Tarjetas Amarillas: ${playerStat.yellowCards}'),
        Text('Tarjetas Rojas: ${playerStat.redCards}'),
      ];
    } else if (playerStat is GoalkeeperStats) {
      return [
        Text('Goles: ${playerStat.goals}'),
        Text('Paradas: ${playerStat.saves}'),
        Text('Tarjetas Amarillas: ${playerStat.yellowCards}'),
        Text('Tarjetas Rojas: ${playerStat.redCards}'),
      ];
    }
    return []; // Retorna vacío si no coincide
  }
}
