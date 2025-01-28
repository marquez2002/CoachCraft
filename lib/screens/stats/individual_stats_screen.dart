/*
 * Archivo: individual_stats_screen.dart
 * Descripción: Este archivo contiene la definición de la pantalla de estadísticas 
 *              individuales de los jugadores.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
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
    String? posicion = widget.playerPosicion;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true, // Hace que el AppBar desaparezca al hacer scroll hacia abajo
            snap: true, // Hace que el AppBar reaparezca rápidamente al hacer scroll hacia arriba
            title: Text('Estadísticas de ${widget.playerName} #${widget.playerDorsal}'),
          ),
          SliverToBoxAdapter( // Adaptador para contenido normal dentro de CustomScrollView
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mostrar tabla con estadísticas por partido
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Permitir scroll horizontal en la tabla
                      child: DataTable(
                        columns: _buildColumnsForPosition(posicion), // Construir columnas según la posición
                        rows: matchesStats
                            .where((match) {
                              return match['goals'] != 0 ||
                                    match['assists'] != 0 ||
                                    match['goalsReceived'] != 0 ||
                                    match['saves'] != 0 ||
                                    match['shotsReceived'] != 0 ||
                                    match['shots'] != 0 ||
                                    match['shotsOnGoal'] != 0 ||
                                    match['yellowCards'] != 0 ||
                                    match['redCards'] != 0 ||
                                    match['fouls'] != 0;
                            })
                            .map((match) {
                              return DataRow(
                                cells: _buildCellsForPosition(match, posicion), // Celdas dinámicas según posición
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Título para la sección de estadísticas por competición
                  Text(
                    'Por Competición',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Mostrar sumatorio de estadísticas por competición
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Permitir scroll horizontal
                      child: DataTable(
                        columns: posicion == 'Portero'
                            ? const [
                                DataColumn(label: Text('Competición')),
                                DataColumn(label: Icon(Icons.sports_soccer)), // Goles
                                DataColumn(label: Icon(Icons.group_add_sharp)), // Asistencias
                                DataColumn(label: Icon(Icons.sports_soccer, color: Colors.red)), // Goles recibidos
                                DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.red)), // Tiros recibidos
                                DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.green)), // Paradas
                                DataColumn(label: Icon(Icons.square, color: Colors.yellow)), // Tarjetas amarillas
                                DataColumn(label: Icon(Icons.square, color: Colors.red)), // Tarjetas rojas
                                DataColumn(label: Icon(Icons.sports)), // Faltas
                              ]
                            : const [
                                DataColumn(label: Text('Competición')),
                                DataColumn(label: Icon(Icons.sports_soccer)), // Goles
                                DataColumn(label: Icon(Icons.group_add_sharp)), // Asistencias
                                DataColumn(label: Icon(Icons.gps_not_fixed)), // Tiros
                                DataColumn(label: Icon(Icons.gps_fixed_rounded)), // Tiros a puerta
                                DataColumn(label: Icon(Icons.square, color: Colors.yellow)), // Tarjetas amarillas
                                DataColumn(label: Icon(Icons.square, color: Colors.red)), // Tarjetas rojas
                                DataColumn(label: Icon(Icons.sports)), // Faltas
                              ],
                        rows: [
                          ...groupedStatsByMatchType.entries.map((entry) {
                            return DataRow(cells: posicion == 'Portero'
                                ? [
                                    DataCell(Text(entry.key)), // Nombre del rival
                                    DataCell(Text(entry.value['goals'].toString())), // Goles
                                    DataCell(Text(entry.value['assists'].toString())), // Asistencias
                                    DataCell(Text(entry.value['goalsReceived'].toString())), // Goles recibidos
                                    DataCell(Text(entry.value['shotsReceived'].toString())), // Tiros recibidos
                                    DataCell(Text(entry.value['saves'].toString())), // Paradas
                                    DataCell(Text(entry.value['yellowCards'].toString())), // Tarjetas amarillas
                                    DataCell(Text(entry.value['redCards'].toString())), // Tarjetas rojas
                                    DataCell(Text(entry.value['fouls'].toString())), // Faltas
                                  ]
                                : [
                                    DataCell(Text(entry.key)), // Nombre del rival
                                    DataCell(Text(entry.value['goals'].toString())), // Goles
                                    DataCell(Text(entry.value['assists'].toString())), // Asistencias
                                    DataCell(Text(entry.value['shots'].toString())), // Tiros
                                    DataCell(Text(entry.value['shotsOnGoal'].toString())), // Tiros a puerta
                                    DataCell(Text(entry.value['yellowCards'].toString())), // Tarjetas amarillas
                                    DataCell(Text(entry.value['redCards'].toString())), // Tarjetas rojas
                                    DataCell(Text(entry.value['fouls'].toString())), // Faltas
                                  ]);
                          }),
                          // Agregar fila de totales generales
                          DataRow(cells: posicion == 'Portero'
                              ? [
                                  DataCell(Text('TOTALES', style: const TextStyle(fontWeight: FontWeight.bold))), // Texto de totales
                                  DataCell(Text(totalStats['goals'].toString())),
                                  DataCell(Text(totalStats['assists'].toString())),
                                  DataCell(Text(totalStats['goalsReceived'].toString())),
                                  DataCell(Text(totalStats['shotsReceived'].toString())),
                                  DataCell(Text(totalStats['saves'].toString())),
                                  DataCell(Text(totalStats['yellowCards'].toString())),
                                  DataCell(Text(totalStats['redCards'].toString())),
                                  DataCell(Text(totalStats['fouls'].toString())),
                                ]
                              : [
                                  DataCell(Text('TOTALES', style: const TextStyle(fontWeight: FontWeight.bold))), // Texto de totales
                                  DataCell(Text(totalStats['goals'].toString())),
                                  DataCell(Text(totalStats['assists'].toString())),
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
          ),
        ],
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

List<DataColumn> _buildColumnsForPosition(String posicion) {
  if (posicion == 'Portero') {
    return const [
      DataColumn(label: Text('Nombre')),
      DataColumn(label: Text('Fecha')),
      DataColumn(label: Icon(Icons.sports_soccer)),   // Goles 
      DataColumn(label: Icon(Icons.group_add_sharp)), // Asis
      DataColumn(label: Icon(Icons.sports_soccer, color: Colors.red)),   // Goles recibidos
      DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.red)), // Tiros recibidos
      DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.green)), // Paradas      
      DataColumn(label: Icon(Icons.square, color: Colors.yellow)), // Tarjetas amarillas
      DataColumn(label: Icon(Icons.square, color: Colors.red)), // Tarjetas rojas
      DataColumn(label: Icon(Icons.sports)), // Faltas
    ];
  } else {
    return const [
      DataColumn(label: Text('Nombre')),
      DataColumn(label: Text('Fecha')),
      DataColumn(label: Icon(Icons.sports_soccer)),   // Goles
      DataColumn(label: Icon(Icons.group_add_sharp)), // Asistencias
      DataColumn(label: Icon(Icons.gps_not_fixed)),
      DataColumn(label: Icon(Icons.gps_fixed_rounded)),
      DataColumn(label: Icon(Icons.square, color: Colors.yellow)), // Tarjetas amarillas
      DataColumn(label: Icon(Icons.square, color: Colors.red)), // Tarjetas rojas
      DataColumn(label: Icon(Icons.sports)), // Faltas
    ];
  }
}

List<DataCell> _buildCellsForPosition(Map<String, dynamic> match, String posicion) {
  if (posicion == 'Portero') {
    return [
      DataCell(Text(match['rivalTeam'].toString())), // Nombre del rival
      DataCell(Text(_formatDate(match['matchDate']))), // Fecha del partido
      DataCell(Text(match['goals'].toString())), // Goles
      DataCell(Text(match['assists'].toString())), // Asistencias
      DataCell(Text(match['goalsReceived'].toString())), // Goles recibidos
      DataCell(Text(match['saves'].toString())), // Atajadas
      DataCell(Text(match['shotsReceived'].toString())), // Tiros recibidos
      DataCell(Text(match['yellowCards'].toString())), // Tarjetas amarillas
      DataCell(Text(match['redCards'].toString())), // Tarjetas rojas
      DataCell(Text(match['fouls'].toString())), // Faltas
    ];
  } else {
    return [
      DataCell(Text(match['rivalTeam'].toString())), // Nombre del rival
      DataCell(Text(_formatDate(match['matchDate']))), // Fecha del partido
      DataCell(Text(match['goals'].toString())), // Goles
      DataCell(Text(match['assists'].toString())), // Asistencias
      DataCell(Text(match['shots'].toString())), // Tiros
      DataCell(Text(match['shotsOnGoal'].toString())), // Tiros a puerta
      DataCell(Text(match['yellowCards'].toString())), // Tarjetas amarillas
      DataCell(Text(match['redCards'].toString())), // Tarjetas rojas
      DataCell(Text(match['fouls'].toString())), // Faltas
    ];
  }
}

String _formatDate(String dateString) {
  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('dd/MM/yyyy'); // Formato deseado: Día/Mes/Año
  return formatter.format(dateTime);
}