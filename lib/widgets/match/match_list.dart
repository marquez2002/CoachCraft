import 'package:CoachCraft/screens/stats/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredMatches;

  const MatchList({Key? key, required this.filteredMatches}) : super(key: key);

  String getBackgroundImage(String matchType) {
    switch (matchType) {
      case 'Amistoso':
        return 'assets/image/amistoso.png';
      case 'Liga':
        return 'assets/image/liga.png';
      case 'Copa':
        return 'assets/image/copa.png';
      case 'Supercopa':
        return 'assets/image/supercopa.png';
      case 'Playoffs':
        return 'assets/image/playoffs.png';
      default:
        return 'assets/image/amistoso.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el ancho de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    // Calcula cuántas tarjetas se pueden mostrar en una fila
    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2; // Móviles
    } else if (screenWidth < 900) {
      crossAxisCount = 3; // Tabletas pequeñas
    } else {
      crossAxisCount = 5; // Pantallas más grandes
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Partidos existentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Usar el número calculado de tarjetas por fila
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.2,
              ),
              itemCount: filteredMatches.length,
              itemBuilder: (context, index) {
                final match = filteredMatches[index];
                final matchData = match['data'];
                final matchDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(matchData['matchDate']));
                final locationIcon = matchData['location'] == 'Casa' ? Icons.home : Icons.flight;

                return GestureDetector(
                  onTap: () {
                    // Navegar a StatsScreen pasando los datos del partido
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatsScreen(
                          matchDate: matchData['matchDate'], // Pasar la fecha del partido
                          rivalTeam: matchData['rivalTeam'], // Pasar el equipo rival
                          result: matchData['result'], // Pasar el resultado
                          matchType: matchData['matchType'], // Pasar el tipo de partido
                          location: matchData['location']
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(getBackgroundImage(matchData['matchType'])),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(locationIcon, size: 16),
                              const SizedBox(width: 8.0),
                              Text(
                                'Rival: ${matchData['rivalTeam']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text('Fecha: $matchDate', style: const TextStyle(fontSize: 14, color: Colors.black)),
                          Text('Resultado: ${matchData['result']}', style: const TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(height: 8.0),
                          Text(
                            matchData['matchType'],
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
