/*
 * Archivo: general_stats_screen.dart
 * Descripción: Este archivo contiene la definición de la pantalla de estadísticas  
 *              generales.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:CoachCraft/widgets/match/filter_section_stats.dart';
import 'package:CoachCraft/screens/stats/individual_stats_player_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
    'goalsReceived': 0,
    'shots': 0,
    'shotsOnGoal': 0,
    'yellowCards': 0,
    'redCards': 0,
    'foul': 0,
  };

  List<Map<String, dynamic>> matchesStats = [];
  bool isLoading = true;
  bool _isSearchingExpanded = false;
  bool _isInfoExpanded = false;

  // Nuevas variables
  String _season = 'Todos'; 
  String _matchType = 'Todos'; 
  int matchesCount = 0; // Contador de partidos
  

  @override
  void initState() {
    super.initState();
    fetchGeneralStats(_season, _matchType, null); // Usa las variables de clase directamente
  }

  DateTimeRange _getDateRangeForSeason(String season) {
    if (season == 'Todos') {
      return DateTimeRange(
        start: DateTime(1900, 1, 1),  
        end: DateTime(2100, 12, 31),
      );
    } else {
      final yearStart = int.parse(season.split('-')[0]); 
      final yearEnd = int.parse(season.split('-')[1]);   

      final startDate = DateTime(yearStart, 8, 1); 
      final endDate = DateTime(2000+yearEnd, 7, 31); 

      return DateTimeRange(start: startDate, end: endDate);
    }
  }

 Future<void> fetchGeneralStats(String season, String matchType, DateTimeRange? dateRange) async {
    setState(() => isLoading = true);
    try {
      String? teamId = await getTeamId(context);
      if (teamId == null) {
        throw Exception('El ID del equipo es null');
      }

      
      DateTimeRange seasonDateRange = _getDateRangeForSeason(season);
      Query matchesQuery = FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .where('matchDate', isGreaterThanOrEqualTo: seasonDateRange.start.toIso8601String())
            .where('matchDate', isLessThanOrEqualTo: seasonDateRange.end.toIso8601String());

        // Aplicar filtro de tipo de partido si corresponde
        if (matchType != 'Todos') {
          matchesQuery = matchesQuery.where('matchType', isEqualTo: matchType);
        }

        // Ejecutar la consulta y obtener los partidos
        QuerySnapshot matchesSnapshot = await matchesQuery.get();

      print('Partidos encontrados: ${matchesSnapshot.docs.length}');
      matchesCount = matchesSnapshot.docs.length;

      // Inicializar estadísticas generales
      Map<String, dynamic> statsAccumulated = {
        'goals': 0,
        'assists': 0,
        'saves': 0,
        'goalsReceived': 0,
        'shotsReceived': 0,
        'shots': 0,
        'shotsOnGoal': 0,
        'yellowCards': 0,
        'redCards': 0,
        'foul': 0,
        'tackle': 0,
        'succesfulTackle': 0,
      };

      List<Map<String, dynamic>> matchStatsList = [];

      for (var match in matchesSnapshot.docs) {
        print('Procesando partido con ID: ${match.id}');

        Map<String, dynamic> matchData = match.data() as Map<String, dynamic>;

        // Obtener datos del partido
        String rivalName = matchData['rivalTeam'] ?? 'Desconocido';
        String matchDate = matchData['matchDate'] ?? '';

        DateTime? parsedDate;

        if (matchDate.isNotEmpty) {
          // Intentamos convertir la cadena en un objeto DateTime
          parsedDate = DateTime.tryParse(matchDate);

          if (parsedDate != null) {
            // Si se pudo convertir correctamente, la formateamos en dd-MM-yyyy
            matchDate = DateFormat('dd-MM-yyyy').format(parsedDate);
          } else {
            // Si no se pudo convertir, dejamos el texto como "Fecha no disponible"
            matchDate = 'Fecha no disponible';
          }
        } else {
          matchDate = 'Fecha no disponible';
        } 

        print('Rival: $rivalName, Fecha: $matchDate');

        QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(match.id)
            .collection('players')
            .get();

        print('Jugadores encontrados en el partido: ${playerSnapshot.docs.length}');

        // Mapa para estadísticas del partido
        Map<String, dynamic> matchStats = {
          'matchName': rivalName,
          'matchDate': matchDate,
          'goals': 0,
          'assists': 0,
          'saves': 0,
          'goalsReceived': 0,
          'shotsReceived': 0,
          'shots': 0,
          'shotsOnGoal': 0,
          'yellowCards': 0,
          'redCards': 0,
          'foul': 0,
          'tackle': 0,
          'succesfulTackle': 0,
        };

        // Acumular estadísticas de los jugadores
        for (var player in playerSnapshot.docs) {
          Map<String, dynamic> playerData = player.data() as Map<String, dynamic>;

          print('Datos del jugador: $playerData');

          // Acumular en estadísticas generales
          for (var key in statsAccumulated.keys) {
            statsAccumulated[key] += playerData[key] ?? 0;
            matchStats[key] += playerData[key] ?? 0;
          }
        }

        // Guardar estadísticas del partido
        matchStatsList.add(matchStats);
      }

      // Actualizar estado con estadísticas generales y por partido
      setState(() {
        generalStats = statsAccumulated;
        matchesStats = matchStatsList;
      });

      print('Estadísticas acumuladas: $generalStats');
      print('Estadísticas por partido: $matchStatsList');

    } catch (e) {
      print('Error al obtener las estadísticas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener estadísticas: $e")),
      );
    } finally {
      setState(() => isLoading = false);
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

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Estadísticas Generales'),
            pinned: false, 
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_pin_circle_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IndividualStatsPlayerScreen()), 
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  setState(() {
                    _isInfoExpanded = !_isInfoExpanded; 
                    if (_isInfoExpanded) {
                      _isSearchingExpanded = false; 
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () {
                  setState(() {
                    _isSearchingExpanded = !_isSearchingExpanded; 
                    if (_isSearchingExpanded) {
                      _isInfoExpanded = false; 
                    }
                  });
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                if (isLoading) 
                  const Center(child: CircularProgressIndicator())
                else
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Formulario para buscar partidos
                        if (_isSearchingExpanded) ...[
                          FilterSectionStats(
                            season: _season,
                            matchType: _matchType,
                            onFilterChanged: (String season, String matchType, DateTimeRange? dateRange) {
                              setState(() {
                                _season = season;
                                _matchType = matchType;
                                fetchGeneralStats(_season, _matchType, dateRange);
                              });
                            },
                          ),
                        ],

                        if (_isInfoExpanded) ...[
                          Wrap(
                            spacing: 20.0,
                            runSpacing: 20.0,
                            alignment: WrapAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.sports_soccer),
                                  Text('Gol'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.group_add_sharp),
                                  Text('Asistencia'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.sports_handball_sharp),
                                  Text('Tiros Recibidos'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.sports_handball_sharp, color: Colors.green),
                                  Text('Paradas'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.sports_soccer, color: Colors.red),
                                  Text('Gol en Contra'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.gps_not_fixed),
                                  Text('Tiros'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.gps_fixed_rounded),
                                  Text('Tiros a Puerta'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.square, color: Colors.yellow),
                                  Text('Tarjeta Amarilla'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.square, color: Colors.red),
                                  Text('Tarjeta Roja'),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(Icons.sports),
                                  Text('Falta'),
                                ],
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        // Mostrar las estadísticas de cada partido
                        Text(
                          'Estadísticas por Partido',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Fecha')),
                                DataColumn(label: Icon(Icons.sports_soccer)),
                                DataColumn(label: Icon(Icons.group_add_sharp)),
                                DataColumn(label: Icon(Icons.sports_handball_sharp)),
                                DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.green)),
                                DataColumn(label: Icon(Icons.sports_soccer, color: Colors.red)),
                                DataColumn(label: Icon(Icons.gps_not_fixed)),
                                DataColumn(label: Icon(Icons.gps_fixed_rounded)),
                                DataColumn(label: Icon(Icons.square, color: Colors.yellow)),
                                DataColumn(label: Icon(Icons.square, color: Colors.red)),
                                DataColumn(label: Icon(Icons.sports)),
                              ],
                              rows: matchesStats.map((match) {
                                return DataRow(cells: [
                                  DataCell(Text(match['matchName'].toString())),
                                  DataCell(Text(match['matchDate'].toString())),
                                  DataCell(Text(match['goals'].toString())),
                                  DataCell(Text(match['assists'].toString())),
                                  DataCell(Text(match['shotsReceived'].toString())),
                                  DataCell(Text(match['saves'].toString())),
                                  DataCell(Text(match['goalsReceived'].toString())),
                                  DataCell(Text(match['shots'].toString())),
                                  DataCell(Text(match['shotsOnGoal'].toString())),
                                  DataCell(Text(match['yellowCards'].toString())),
                                  DataCell(Text(match['redCards'].toString())),
                                  DataCell(Text(match['foul'].toString())),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Estadísticas Generales',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildGeneralStatsTable(),
                        const SizedBox(height: 6),
                        // Agregar el gráfico
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: [
                            // Gráfico: Paradas vs Goles Recibidos
                            if ((generalStats['shotsReceived']?.toDouble() ?? 0) > 0 || 
                                (generalStats['saves']?.toDouble() ?? 0) > 0)
                              _buildPieChart(
                                title: 'Paradas Vs Goles Recibidos',
                                sectionData: [
                                  PieChartSectionData(
                                    value: generalStats['goalsReceived']?.toDouble() ?? 0,
                                    title: '${generalStats['goalsReceived']?.toString() ?? 0}',
                                    color: Colors.red,
                                  ),
                                  PieChartSectionData(
                                    value: generalStats['saves']?.toDouble() ?? 0,
                                    title: '${generalStats['saves']?.toString() ?? 0}',
                                    color: Colors.green,
                                  ),
                                ],
                              ),

                            // Gráfico: Tiros vs Tiros a Puerta
                            if ((generalStats['shotsOnGoal']?.toDouble() ?? 0) > 0 || 
                                (generalStats['shots']?.toDouble() ?? 0) > 0)
                              _buildPieChart(
                                title: 'Tiros vs A Puerta',
                                sectionData: [
                                  PieChartSectionData(
                                    value: generalStats['shotsOnGoal']?.toDouble() ?? 0,
                                    title: '${generalStats['shotsOnGoal']?.toString() ?? 0}',
                                    color: Colors.green,
                                  ),
                                  PieChartSectionData(
                                    value: generalStats['shots']?.toDouble() ?? 0,
                                    title: '${generalStats['shots']?.toString() ?? 0}',
                                    color: Colors.amber,
                                  ),
                                ],
                              ),

                            // Gráfico: Goles vs Tiros
                            if ((generalStats['goals']?.toDouble() ?? 0) > 0 || 
                                (generalStats['shots']?.toDouble() ?? 0) > 0)
                              _buildPieChart(
                                title: 'Tiros vs Goles',
                                sectionData: [
                                  PieChartSectionData(
                                    value: generalStats['goals']?.toDouble() ?? 0,
                                    title: '${generalStats['goals']?.toString() ?? 0}',
                                    color: Colors.green,
                                  ),
                                  PieChartSectionData(
                                    value: generalStats['shots']?.toDouble() ?? 0,
                                    title: '${generalStats['shots']?.toString() ?? 0}',
                                    color: Colors.purple,
                                  ),
                                ],
                              ),

                            // Gráfico: Estadísticas combinadas (Faltas, Tarjetas Amarillas y Rojas) en barras
                            if ((generalStats['yellowCards']?.toDouble() ?? 0) > 0 || 
                                (generalStats['redCards']?.toDouble() ?? 0) > 0 || 
                                (generalStats['foul']?.toDouble() ?? 0) > 0)
                              _buildSimpleBarChart(
                                title: 'Tarjetas amarillas, rojas y faltas',
                                data: [
                                  BarChartGroupData(
                                    x: 0, // Identificador del eje X para esta barra
                                    barRods: [
                                      BarChartRodData(
                                        toY: generalStats['yellowCards']?.toDouble() ?? 0,
                                        color: Colors.yellow,
                                        width: 30,
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1, // Identificador del eje X para esta barra
                                    barRods: [
                                      BarChartRodData(
                                        toY: generalStats['redCards']?.toDouble() ?? 0,
                                        color: Colors.red,
                                        width: 30,
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 2, // Identificador del eje X para esta barra
                                    barRods: [
                                      BarChartRodData(
                                        toY: generalStats['foul']?.toDouble() ?? 0,
                                        color: Colors.teal,
                                        width: 30,
                                      ),
                                    ],                                    
                                  ),
                                ],
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGeneralStatsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Icon(Icons.sports_soccer)),
          DataColumn(label: Icon(Icons.group_add_sharp)),
          DataColumn(label: Icon(Icons.sports_handball_sharp)),
          DataColumn(label: Icon(Icons.sports_handball_sharp, color: Colors.green)),
          DataColumn(label: Icon(Icons.sports_soccer, color: Colors.red)),
          DataColumn(label: Icon(Icons.gps_not_fixed)),
          DataColumn(label: Icon(Icons.gps_fixed_rounded)),
          DataColumn(label: Icon(Icons.square, color: Colors.yellow)),
          DataColumn(label: Icon(Icons.square, color: Colors.red)),
          DataColumn(label: Icon(Icons.sports)),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text(generalStats['goals'].toString())),
            DataCell(Text(generalStats['assists'].toString())),
            DataCell(Text(generalStats['shotsReceived'].toString())),
            DataCell(Text(generalStats['saves'].toString())),
            DataCell(Text(generalStats['goalsReceived'].toString())),
            DataCell(Text(generalStats['shots'].toString())),
            DataCell(Text(generalStats['shotsOnGoal'].toString())),
            DataCell(Text(generalStats['yellowCards'].toString())),
            DataCell(Text(generalStats['redCards'].toString())),
            DataCell(Text(generalStats['foul'].toString())),
          ]),
        ],
      ),
    );
  }
}

Widget _buildPieChart({required String title, required List<PieChartSectionData> sectionData}) {
  // Verifica si no hay datos para mostrar
  if (sectionData.isEmpty) {
    return Container(); 
  }
  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      Container(
        width: 150, 
        height: 150, 
        child: PieChart(
          PieChartData(
            sections: sectionData,
            centerSpaceRadius: 30,
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSimpleBarChart({
  required List<BarChartGroupData> data, required String title, 
}) {
  return SizedBox(
    height: 450,
    child: BarChart(
      BarChartData(
        barGroups: data,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 100,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Amarillas');
                  case 1:
                    return const Text('Rojas');
                  case 2:
                    return const Text('Faltas');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(enabled: false),
      ),
    ),
  );
}