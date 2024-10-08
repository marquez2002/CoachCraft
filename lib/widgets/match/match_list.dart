import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:CoachCraft/provider/match_provider.dart';
import 'package:CoachCraft/screens/stats/stats_screen.dart';

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
        return 'assets/image/amistoso.png'; // Recurso por defecto
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
      crossAxisCount = 3; 
    } else {
      crossAxisCount = 4; 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Partidos existentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        // Comprobar si hay partidos filtrados
        if (filteredMatches.isEmpty)
          const Text('No hay partidos disponibles', style: TextStyle(color: Colors.red)),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, 
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.2,
            ),
            itemCount: filteredMatches.length,
            itemBuilder: (context, index) {
              final match = filteredMatches[index];
              final matchData = match['data'];
              final matchId = match['id'];
              
              // Manejar posible error de parsing
              DateTime? matchDateParsed;
              try {
                matchDateParsed = DateTime.parse(matchData['matchDate']);
              } catch (e) {
                matchDateParsed = DateTime.now(); // Valor por defecto
              }
              
              final matchDate = DateFormat('dd-MM-yyyy').format(matchDateParsed);
              final locationIcon = matchData['location'] == 'Casa' ? Icons.home : Icons.flight;

              return GestureDetector(
                onTap: () {
                  // Actualiza el MatchProvider con el partido seleccionado
                  Provider.of<MatchProvider>(context, listen: false).setSelectedMatchId(matchId);

                  // Navegar a StatsScreen pasando los datos del partido
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatsScreen(
                        matchDate: matchData['matchDate'], 
                        rivalTeam: matchData['rivalTeam'], 
                        result: matchData['result'],
                        matchType: matchData['matchType'],
                        location: matchData['location'],
                        matchId: matchId,
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
                              overflow: TextOverflow.ellipsis,
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
    );
  }
}
