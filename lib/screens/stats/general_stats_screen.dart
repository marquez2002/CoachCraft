import 'package:CoachCraft/provider/team_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneralStatsScreen extends StatefulWidget {
  const GeneralStatsScreen({Key? key}) : super(key: key);

  @override
  _GeneralStatsScreenState createState() => _GeneralStatsScreenState();
}

class _GeneralStatsScreenState extends State<GeneralStatsScreen> {
  Map<String, dynamic> generalStats = {
    'goals': 0,
    'assists': 0,
    'saves': 0,
    'shotsReceived': 0,
    'shots': 0,
    'shotsOnGoal': 0,
    'yellowCards': 0,
    'redCards': 0,
    'foul': 0,
    'tackle': 0,
    'succesfulTackle': 0,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGeneralStats(); // Load general stats on startup
  }

  // Function to calculate start date based on the selected period
  DateTime getStartDate(String period) {
    DateTime now = DateTime.now();
    if (period == 'semanal') {
      return now.subtract(const Duration(days: 7));
    } else if (period == 'mensual') {
      return DateTime(now.year, now.month - 1, now.day);
    } else {
      return DateTime(now.year - 1, now.month, now.day); // Full season (one year ago)
    }
  }

  Future<void> fetchGeneralStats({String period = 'completa'}) async {
    setState(() => isLoading = true);
    try {
      String? teamId = await getTeamId(context); // Get the selected team's ID
      if (teamId == null) {
        throw Exception('Team ID is null');
      }
      
      DateTime startDate = getStartDate(period); // Start date based on selected period
      print("Fetching matches from: $startDate");

      // Fetch matches within the specified date range
      QuerySnapshot matchesSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .get();

      print("Matches found: ${matchesSnapshot.docs.length}");

      Map<String, dynamic> statsAccumulated = {
        'goals': 0,
        'assists': 0,
        'saves': 0,
        'shotsReceived': 0,
        'shots': 0,
        'shotsOnGoal': 0,
        'yellowCards': 0,
        'redCards': 0,
        'foul': 0,
        'tackle': 0,
        'succesfulTackle': 0,
      };

      // Iterate through each match to accumulate player statistics
      for (var match in matchesSnapshot.docs) {
        QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(match.id)
            .collection('players')
            .get();

        print("Match ID: ${match.id} - Players Found: ${playerSnapshot.docs.length}");

        // Accumulate general statistics from each player
        for (var player in playerSnapshot.docs) {
          Map<String, dynamic> playerData = player.data() as Map<String, dynamic>;
          // Check if playerData contains the expected keys
          print("Player ID: ${player.id}, Data: $playerData");

          statsAccumulated['goals'] += playerData['goals'] ?? 0;
          statsAccumulated['assists'] += playerData['assists'] ?? 0;
          statsAccumulated['saves'] += playerData['saves'] ?? 0;
          statsAccumulated['shotsReceived'] += playerData['shotsReceived'] ?? 0;
          statsAccumulated['shots'] += playerData['shots'] ?? 0;
          statsAccumulated['shotsOnGoal'] += playerData['shotsOnGoal'] ?? 0;
          statsAccumulated['yellowCards'] += playerData['yellowCards'] ?? 0;
          statsAccumulated['redCards'] += playerData['redCards'] ?? 0;
          statsAccumulated['foul'] += playerData['foul'] ?? 0;
          statsAccumulated['tackle'] += playerData['tackle'] ?? 0;
          statsAccumulated['succesfulTackle'] += playerData['succesfulTackle'] ?? 0;
        }
      }

      // Assign the accumulated statistics
      setState(() {
        generalStats = statsAccumulated;
      });

      print("Accumulated Stats: $generalStats");
    } catch (e) {
      // Show error message if there is an issue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener estadísticas: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  // Function to get the selected team's ID
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Generales'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String period) {
              fetchGeneralStats(period: period);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'semanal',
                child: Text('Semanal'),
              ),
              const PopupMenuItem<String>(
                value: 'mensual',
                child: Text('Mensual'),
              ),
              const PopupMenuItem<String>(
                value: 'completa',
                child: Text('Temporada Completa'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Center(child: Icon(Icons.sports_soccer))),
                          DataColumn(label: Center(child: Icon(Icons.group_add_sharp))),
                          DataColumn(label: Center(child: Icon(Icons.sports_handball_sharp))),
                          DataColumn(label: Center(child: Icon(Icons.sports_handball_sharp, color: Colors.green))),
                          DataColumn(label: Center(child: Icon(Icons.sports_soccer))),
                          DataColumn(label: Center(child: Icon(Icons.group_add_sharp))),
                          DataColumn(label: Center(child: Icon(Icons.square, color: Colors.yellow))),
                          DataColumn(label: Center(child: Icon(Icons.square, color: Colors.red))),
                          DataColumn(label: Center(child: Icon(Icons.gps_not_fixed))),
                          DataColumn(label: Center(child: Icon(Icons.gps_fixed_rounded))),
                          DataColumn(label: Center(child: Icon(Icons.sports))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text(generalStats['goals'].toString())),
                            DataCell(Text(generalStats['assists'].toString())),
                            DataCell(Text(generalStats['shotsReceived'].toString())), 
                            DataCell(Text(generalStats['saves'].toString())),
                            DataCell(Text(generalStats['shots'].toString())),
                            DataCell(Text(generalStats['shotsOnGoal'].toString())),
                            DataCell(Text(generalStats['yellowCards'].toString())),
                            DataCell(Text(generalStats['redCards'].toString())),
                            DataCell(Text(generalStats['foul'].toString())),
                            DataCell(Text(generalStats['tackle'].toString())),
                            DataCell(Text(generalStats['succesfulTackle'].toString())),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
