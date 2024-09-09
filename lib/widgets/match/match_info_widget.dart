import 'package:flutter/material.dart';
import 'package:CoachCraft/models/player_stats.dart'; // Import your PlayerStats and GoalkeeperStats models

class MatchInfoWidget extends StatelessWidget {
  final TextEditingController rivalController;
  final TextEditingController dateController;
  final TextEditingController resultController;
  final String matchType;
  final String location;
  final bool isExpanded;
  final List<dynamic> playerStats; // List of player statistics
  final List<String> matchTypes; // List of match types
  final List<String> locations; // List of locations
  final Function(String?) onMatchTypeChanged; // Callback for match type change
  final Function(String?) onLocationChanged; // Callback for location change

  const MatchInfoWidget({
    Key? key,
    required this.rivalController,
    required this.dateController,
    required this.resultController,
    required this.matchType,
    required this.location,
    required this.isExpanded,
    required this.playerStats,
    required this.matchTypes,
    required this.locations,
    required this.onMatchTypeChanged,
    required this.onLocationChanged,
  }) : super(key: key);

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
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Modificar Datos del Partido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0), // Space after the header

        // Display match information
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: rivalController,
                decoration: const InputDecoration(
                  labelText: 'Rival',
                  border: OutlineInputBorder(),
                ),
                enabled: false, // Rival name is not editable
              ),
            ),
            const SizedBox(width: 8.0), // Space between Rival and Date
            Expanded(
              child: TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                ),
                enabled: false, // Date is not editable
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0), // Space after match information

        // Section for modifiable match data
        if (isExpanded) ...[
          TextField(
            controller: resultController,
            decoration: const InputDecoration(
              labelText: 'Resultado',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            value: matchType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Partido',
              border: OutlineInputBorder(),
            ),
            onChanged: onMatchTypeChanged,
            items: matchTypes
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            value: location,
            decoration: const InputDecoration(
              labelText: 'Lugar del Partido',
              border: OutlineInputBorder(),
            ),
            onChanged: onLocationChanged,
            items: locations.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),
        ],

        const Divider(height: 20, thickness: 2),
        const Text('Estadísticas de Jugadores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Expanded(
          child: ListView.builder(
            itemCount: playerStats.length,
            itemBuilder: (context, index) {
              final playerStat = playerStats[index];
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
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // Icon for goalkeepers
                          if (playerStat is GoalkeeperStats) ...[
                            const Icon(Icons.sports_handball,
                                size: 24.0), // Glove icon for goalkeeper
                            const SizedBox(width: 8.0), // Space between icon and text
                          ],
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      ..._buildStatRows(playerStat), // Generate statistic rows
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
