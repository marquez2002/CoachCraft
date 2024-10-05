import 'package:CoachCraft/provider/team_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IndividualStatsScreen extends StatefulWidget {
  final String playerName;
  final int playerDorsal;
  final String playerPosicion;

  const IndividualStatsScreen({
    Key? key,
    required this.playerName,
    required this.playerDorsal,
    required this.playerPosicion,
  }) : super(key: key);

  @override
  _IndividualStatsScreenState createState() => _IndividualStatsScreenState();
}

class _IndividualStatsScreenState extends State<IndividualStatsScreen> {
  List<Map<String, dynamic>> matchesStats = [];
  Map<String, int> totalStats = {
      'goals': 0,
      'assists': 0,
      'goalsReceived': 0,
      'shotsReceived': 0,
      'saves': 0,
      'shots': 0,
      'shotsOnGoal': 0,
      'yellowCards': 0,
      'redCards': 0,
      'fouls': 0,
  };

  // Mapa para almacenar estadísticas agrupadas por tipo de partido
  Map<String, Map<String, int>> groupedStatsByMatchType = {};

  @override
  void initState() {
    super.initState();
    fetchPlayerStats();
  }

  Future<void> fetchPlayerStats() async {
    String? teamId = await getTeamId(context);
    if (teamId == null) {
      showError('No se encontró el equipo seleccionado');
      return;
    }

    try {
      // Obtener partidos del equipo
      QuerySnapshot matchesSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .get();

      // Comprobar si hay partidos
      if (matchesSnapshot.docs.isEmpty) {
        showError('No se encontraron partidos');
        return;
      }

      List<Map<String, dynamic>> playerStats = [];

      // Iterar sobre cada partido
      for (var matchDoc in matchesSnapshot.docs) {
        // Obtener jugadores del partido específico
        QuerySnapshot playersSnapshot = await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(matchDoc.id)
            .collection('players')
            .where('nombre', isEqualTo: widget.playerName)
            .get();

        // Comprobar si el jugador está en el partido
        if (playersSnapshot.docs.isEmpty) continue;

        // Inicializar estadísticas del partido
        Map<String, dynamic> matchStats = _initializeMatchStats(matchDoc);

        // Sumar estadísticas del jugador
        for (var playerDoc in playersSnapshot.docs) {
          Map<String, dynamic> playerData = playerDoc.data() as Map<String, dynamic>;
          _updateMatchStats(matchStats, playerData);
        }

        // Acumular estadísticas generales
        _accumulateTotalStats(matchStats);

        // Acumular estadísticas por tipo de partido
        _accumulateStatsByMatchType(matchStats);

        // Añadir las estadísticas de este partido a la lista
        playerStats.add(matchStats);
      }

      // Actualizar el estado con las estadísticas obtenidas
      setState(() {
        matchesStats = playerStats;
      });

    } catch (e) {
      showError('Error al obtener las estadísticas: $e');
    }
  }

  Map<String, dynamic> _initializeMatchStats(QueryDocumentSnapshot matchDoc) {
    return {
      'rivalTeam': matchDoc['rivalTeam'],
      'matchDate': matchDoc['matchDate'],
      'matchType': matchDoc['matchType'], // Asegúrate de que esto exista en tu documento
      'goals': 0,
      'assists': 0,
      'goalsReceived': 0,
      'shotsReceived': 0,
      'saves': 0,
      'shots': 0,
      'shotsOnGoal': 0,
      'yellowCards': 0,
      'redCards': 0,
      'fouls': 0,
    };
  }

  void _updateMatchStats(Map<String, dynamic> matchStats, Map<String, dynamic> playerData) {
    matchStats['goals'] += (playerData['goals'] as num?)?.toInt() ?? 0;
    matchStats['assists'] += (playerData['assists'] as num?)?.toInt() ?? 0;
    matchStats['goalsReceived'] += (playerData['goalReceived'] as num?)?.toInt() ?? 0;
    matchStats['shotsReceived'] += (playerData['shotsReceived'] as num?)?.toInt() ?? 0;
    matchStats['saves'] += (playerData['saves'] as num?)?.toInt() ?? 0;
    matchStats['shots'] += (playerData['shots'] as num?)?.toInt() ?? 0;
    matchStats['shotsOnGoal'] += (playerData['shotsOnGoal'] as num?)?.toInt() ?? 0;
    matchStats['yellowCards'] += (playerData['yellowCards'] as num?)?.toInt() ?? 0;
    matchStats['redCards'] += (playerData['redCards'] as num?)?.toInt() ?? 0;
    matchStats['fouls'] += (playerData['foul'] as num?)?.toInt() ?? 0;
  }

  void _accumulateTotalStats(Map<String, dynamic> matchStats) {
    totalStats['goals'] = (totalStats['goals'] ?? 0) + (matchStats['goals'] as num?)!.toInt();
    totalStats['assists'] = (totalStats['assists'] ?? 0) + (matchStats['assists'] as num?)!.toInt();
    totalStats['goalsReceived'] = (totalStats['goalsReceived'] ?? 0) + (matchStats['goalsReceived'] as num?)!.toInt();
    totalStats['shotsReceived'] = (totalStats['shotsReceived'] ?? 0) + (matchStats['shotsReceived'] as num?)!.toInt();
    totalStats['saves'] = (totalStats['saves'] ?? 0) + (matchStats['saves'] as num?)!.toInt();
    totalStats['shots'] = (totalStats['shots'] ?? 0) + (matchStats['shots'] as num?)!.toInt();
    totalStats['shotsOnGoal'] = (totalStats['shotsOnGoal'] ?? 0) + (matchStats['shotsOnGoal'] as num?)!.toInt();
    totalStats['yellowCards'] = (totalStats['yellowCards'] ?? 0) + (matchStats['yellowCards'] as num?)!.toInt();
    totalStats['redCards'] = (totalStats['redCards'] ?? 0) + (matchStats['redCards'] as num?)!.toInt();
    totalStats['fouls'] = (totalStats['fouls'] ?? 0) + (matchStats['fouls'] as num?)!.toInt();
  }

  void _accumulateStatsByMatchType(Map<String, dynamic> matchStats) {
    String matchType = matchStats['matchType']; // Asegúrate de que esto exista en matchStats

    if (!groupedStatsByMatchType.containsKey(matchType)) {
      groupedStatsByMatchType[matchType] = {
        'goals': 0,
        'assists': 0,
        'goalsReceived': 0,
        'shotsReceived': 0,
        'saves': 0,
        'shots': 0,
        'shotsOnGoal': 0,
        'yellowCards': 0,
        'redCards': 0,
        'fouls': 0,
      };
    }

    groupedStatsByMatchType[matchType]!['goals'] = (groupedStatsByMatchType[matchType]!['goals'] ?? 0) + (matchStats['goals'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['assists'] = (groupedStatsByMatchType[matchType]!['assists'] ?? 0) + (matchStats['assists'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['goalsReceived'] = (groupedStatsByMatchType[matchType]!['goalsReceived'] ?? 0) + (matchStats['goalsReceived'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['shotsReceived'] = (groupedStatsByMatchType[matchType]!['shotsReceived'] ?? 0) + (matchStats['shotsReceived'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['saves'] = (groupedStatsByMatchType[matchType]!['saves'] ?? 0) + (matchStats['saves'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['shots'] = (groupedStatsByMatchType[matchType]!['shots'] ?? 0) + (matchStats['shots'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['shotsOnGoal'] = (groupedStatsByMatchType[matchType]!['shotsOnGoal'] ?? 0) + (matchStats['shotsOnGoal'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['yellowCards'] = (groupedStatsByMatchType[matchType]!['yellowCards'] ?? 0) + (matchStats['yellowCards'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['redCards'] = (groupedStatsByMatchType[matchType]!['redCards'] ?? 0) + (matchStats['redCards'] as num?)!.toInt();
    groupedStatsByMatchType[matchType]!['fouls'] = (groupedStatsByMatchType[matchType]!['fouls'] ?? 0) + (matchStats['fouls'] as num?)!.toInt();   
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      // Si es un Timestamp, conviértelo a DateTime
      return DateFormat('dd/MM/yyyy').format(date.toDate());
    } else if (date is String) {
      // Si es un String, intenta convertirlo a DateTime
      DateTime? parsedDate = DateTime.tryParse(date);
      if (parsedDate != null) {
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } else {
        // Manejar el caso donde la cadena no se puede convertir a DateTime
        return 'Fecha no válida';
      }
    } else {
      // Manejar otros casos
      return 'Formato de fecha desconocido';
    }
  }

  
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de ${widget.playerName} #${widget.playerDorsal}'),      
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Cambia a center
          children: [
            // Mostrar tabla con estadísticas por partido
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Icon(Icons.sports_soccer)),
                    DataColumn(label: Icon(Icons.group_add_sharp)),
                    DataColumn(label: Icon(Icons.sports_soccer, color: Colors.red)),
                    DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.green)),
                    DataColumn(label: Icon(Icons.sports_handball_sharp)),                                        
                    DataColumn(label: Icon(Icons.gps_not_fixed)),
                    DataColumn(label: Icon(Icons.gps_fixed_rounded)),
                    DataColumn(label: Icon(Icons.square, color: Colors.yellow)),
                    DataColumn(label: Icon(Icons.square, color: Colors.red)),
                    DataColumn(label: Icon(Icons.sports)),
                  ],
                  rows: matchesStats.map((match) {
                    return DataRow(cells: [
                      DataCell(Text(match['rivalTeam'].toString())),
                      DataCell(Text(_formatDate(match['matchDate']))), 
                      DataCell(Text(match['goals'].toString())),
                      DataCell(Text(match['assists'].toString())),
                      DataCell(Text(match['goalsReceived'].toString())),
                      DataCell(Text(match['saves'].toString())),
                      DataCell(Text(match['shotsReceived'].toString())),                                            
                      DataCell(Text(match['shots'].toString())),
                      DataCell(Text(match['shotsOnGoal'].toString())),
                      DataCell(Text(match['yellowCards'].toString())),
                      DataCell(Text(match['redCards'].toString())),
                      DataCell(Text(match['fouls'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Mostrar sumatorio de estadísticas agrupadas por tipo de partido
            Text(
              'Por Competición',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Mostrar sumatorio de estadísticas por competición
            Center( // Centrar la segunda tabla
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Icon(Icons.sports_soccer)),
                    DataColumn(label: Icon(Icons.group_add_sharp)),
                    DataColumn(label: Icon(Icons.sports_soccer, color: Colors.red)),
                    DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.green)),
                    DataColumn(label: Icon(Icons.sports_handball_sharp)),                                        
                    DataColumn(label: Icon(Icons.gps_not_fixed)),
                    DataColumn(label: Icon(Icons.gps_fixed_rounded)),
                    DataColumn(label: Icon(Icons.square, color: Colors.yellow)),
                    DataColumn(label: Icon(Icons.square, color: Colors.red)),
                    DataColumn(label: Icon(Icons.sports)),
                  ],
                  rows: [
                    ...groupedStatsByMatchType.entries.map((entry) {
                      return DataRow(cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value['goals'].toString())),
                        DataCell(Text(entry.value['assists'].toString())),
                        DataCell(Text(entry.value['goalsReceived'].toString())),
                        DataCell(Text(entry.value['saves'].toString())),
                        DataCell(Text(entry.value['shotsReceived'].toString())),
                        DataCell(Text(entry.value['shots'].toString())),
                        DataCell(Text(entry.value['shotsOnGoal'].toString())),
                        DataCell(Text(entry.value['yellowCards'].toString())),
                        DataCell(Text(entry.value['redCards'].toString())),
                        DataCell(Text(entry.value['fouls'].toString())),
                      ]);
                    }).toList(),
                    // Agregar fila de totales generales
                    DataRow(cells: [
                      DataCell(Text('TOTALES')),
                      DataCell(Text(totalStats['goals'].toString())),
                      DataCell(Text(totalStats['assists'].toString())),
                      DataCell(Text(totalStats['goalsReceived'].toString())),
                      DataCell(Text(totalStats['saves'].toString())),
                      DataCell(Text(totalStats['shotsReceived'].toString())),                                            
                      DataCell(Text(totalStats['shots'].toString())),
                      DataCell(Text(totalStats['shotsOnGoal'].toString())),
                      DataCell(Text(totalStats['yellowCards'].toString())),
                      DataCell(Text(totalStats['redCards'].toString())),
                      DataCell(Text(totalStats['fouls'].toString())),
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

// Obtener el ID del equipo
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
