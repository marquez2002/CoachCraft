import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:CoachCraft/provider/match_provider.dart';
import 'package:CoachCraft/screens/stats/stats_screen.dart';

class MatchList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredMatches;
  final bool isLoading;

  const MatchList({Key? key, required this.filteredMatches, this.isLoading = false}) : super(key: key);

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

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Partidos existentes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8.0),

                // FutureBuilder para esperar 2 segundos antes de mostrar "No hay partidos disponibles"
                FutureBuilder(
                  future: Future.delayed(const Duration(seconds: 2)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(); // Espacio vacío mientras esperamos
                    }
                    if (filteredMatches.isEmpty) {
                      return const Text(
                        'No hay partidos disponibles',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
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

                      DateTime? matchDateParsed;
                      try {
                        matchDateParsed = DateTime.parse(matchData['matchDate']);
                      } catch (e) {
                        matchDateParsed = DateTime.now();
                      }

                      final matchDate = DateFormat('dd-MM-yyyy').format(matchDateParsed);
                      final locationIcon = matchData['location'] == 'Casa' ? Icons.home : Icons.flight;

                      return GestureDetector(
                        onTap: () {
                          Provider.of<MatchProvider>(context, listen: false)
                              .setSelectedMatchId(matchId);
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
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Fecha: $matchDate',
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                ),
                                Text(
                                  'Resultado: ${matchData['result']}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  matchData['matchType'],
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                      color: Colors.black),
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
