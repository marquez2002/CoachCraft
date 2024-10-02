import 'package:CoachCraft/provider/team_provider.dart';
import 'package:CoachCraft/screens/stats/individual_stats_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IndividualStatsPlayerScreen extends StatefulWidget {
  const IndividualStatsPlayerScreen({Key? key}) : super(key: key);

  @override
  _IndividualStatsPlayerScreenState createState() => _IndividualStatsPlayerScreenState();
}

class _IndividualStatsPlayerScreenState extends State<IndividualStatsPlayerScreen> {
  List<Map<String, dynamic>> uniquePlayers = [];

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    Set<String> playerNames = Set();
    List<Map<String, dynamic>> playersList = [];

    String? teamId = await getTeamId(context);
    if (teamId == null) {
      throw Exception('El ID del equipo es null');
    }

    QuerySnapshot matchesSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .collection('matches')
        .get();

    for (var matchDoc in matchesSnapshot.docs) {
      QuerySnapshot playersSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .doc(matchDoc.id)
          .collection('players')
          .get();

      for (var playerDoc in playersSnapshot.docs) {
        Map<String, dynamic> playerData = playerDoc.data() as Map<String, dynamic>;
        String playerName = playerData['nombre'];
        int dorsal = playerData['dorsal'];
        String posicion = playerData['posicion'];

        if (!playerNames.contains(playerName)) {
          playerNames.add(playerName);

          playersList.add({
            'nombre': playerName,
            'dorsal': dorsal,
            'posicion': posicion,
          });
        }
      }
    }

    setState(() {
      uniquePlayers = playersList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jugadores del equipo'),
      ),
      body: uniquePlayers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width / 200).floor(),
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: uniquePlayers.length,
              itemBuilder: (context, index) {
                var player = uniquePlayers[index];
                String imagePath = player['posicion'] == 'Portero'
                    ? 'assets/image/goalkeeper_tshirt2.png'
                    : 'assets/image/player_tshirt2.png';

                return GestureDetector(
                  onTap: () {
                    // Navegar a la pantalla de estadísticas del jugador
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IndividualStatsScreen(
                          playerName: player['nombre'],
                          playerDorsal: player['dorsal'],
                          playerPosicion: player['posicion'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 45),
                            Text(
                              player['nombre'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${player['dorsal']}',
                              style: TextStyle(
                                fontSize: 70,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

Future<String?> getTeamId(BuildContext context) async {
  try {
    String selectedTeam = Provider.of<TeamProvider>(context, listen: false).selectedTeamName;
    if (selectedTeam.isEmpty) {
      throw Exception('No hay equipo seleccionado');
    }
    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .where('name', isEqualTo: selectedTeam)
        .limit(1)
        .get();
    if (teamSnapshot.docs.isNotEmpty) {
      return teamSnapshot.docs.first.id;
    } else {
      throw Exception('No se encontró el equipo seleccionado');
    }
  } catch (e) {
    throw Exception('Error al obtener el teamId: $e');
  }
}
