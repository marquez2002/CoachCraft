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
  String _season = 'Todos'; // Almacenar la temporada seleccionada
  String _matchType = 'Todos'; // Almacenar el tipo
  DateTimeRange? _dateRange;
  int matchesCount = 0; // Contador de partidos

  @override
  void initState() {
    super.initState();
    fetchGeneralStats(_season, _matchType, _dateRange); // Carga inicial de estadísticas
  }

  DateTime getStartDate(String period) {
    DateTime now = DateTime.now();

    if (period == 'semanal') {
      return now.subtract(const Duration(days: 7));
    } else if (period == 'mensual') {
      return DateTime(now.year, now.month - 1, now.day);
    } else {
      DateTime augustFirst = DateTime(now.year, 8, 1);

      if (now.isBefore(augustFirst)) {
        return DateTime(now.year - 1, 8, 1);
      } else {
        return augustFirst;
      }
    }
  }

  // Fetch general stats from Firestore con filtrado de temporada y tipo de partido
  Future<void> fetchGeneralStats(String season, String matchType, DateTimeRange? dateRange) async {
    setState(() => isLoading = true); // Inicia el estado de carga
    try {
      // Obtener ID del equipo seleccionado
      String? teamId = await getTeamId(context);
      if (teamId == null) {
        throw Exception('El ID del equipo es null');
      }

      // Obtener la fecha de inicio según la temporada seleccionada
      DateTime startDate = season != 'Todos' ? getStartDate(season) : DateTime(1900); 
      print("Buscando partidos desde: $startDate para el equipo: $teamId");

      // Convertir la fecha de inicio a String para Firestore
      String startDateAsString = startDate.toIso8601String();

      // Iniciar la consulta con filtro de fecha
      Query matchesQuery = FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .where('matchDate', isGreaterThanOrEqualTo: startDateAsString);

      // Aplicar filtro de tipo de partido si no es "Todos"
      if (matchType != 'Todos') {
        matchesQuery = matchesQuery.where('matchType', isEqualTo: matchType);
      }

      // Ejecutar la consulta
      QuerySnapshot matchesSnapshot = await matchesQuery.get();
      print("Partidos encontrados: ${matchesSnapshot.docs.length}");
      matchesCount = matchesSnapshot.docs.length;

      // Limpiar estadísticas previas y preparar el acumulador
      matchesStats.clear(); 
      Map<String, dynamic> statsAccumulated = {
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

      // Iterar a través de los partidos encontrados
      for (var match in matchesSnapshot.docs) {
        print("Procesando partido con ID: ${match.id}");

        // Obtener el nombre y la fecha del partido
        String matchName = match['rivalTeam'] ?? 'Partido sin nombre';
        DateTime matchDate = DateTime.parse(match['matchDate']);
        String formattedDate = DateFormat('dd-MM-yyyy').format(matchDate);

        // Inicializar estadísticas para el partido actual
        Map<String, dynamic> matchStats = {
          'matchName': matchName,
          'matchDate': formattedDate,
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

        // Acceder a la colección de jugadores dentro de cada partido
        QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(match.id)
            .collection('players')
            .get();

        print("Jugadores encontrados en el partido: ${playerSnapshot.docs.length}");

        // Acumular las estadísticas de los jugadores para el partido actual
        for (var player in playerSnapshot.docs) {
          Map<String, dynamic> playerData = player.data() as Map<String, dynamic>;

          print("Datos del jugador: $playerData");

          // Asegurarse de que las claves existen y no son nulas
          matchStats['goals'] += playerData['goals'] ?? 0;
          matchStats['assists'] += playerData['assists'] ?? 0;
          matchStats['saves'] += playerData['saves'] ?? 0;
          matchStats['shotsReceived'] += playerData['shotsReceived'] ?? 0;
          matchStats['goalsReceived'] += playerData['goalsReceived'] ?? 0;
          matchStats['shots'] += playerData['shots'] ?? 0;
          matchStats['shotsOnGoal'] += playerData['shotsOnGoal'] ?? 0;
          matchStats['yellowCards'] += playerData['yellowCards'] ?? 0;
          matchStats['redCards'] += playerData['redCards'] ?? 0;
          matchStats['foul'] += playerData['foul'] ?? 0;
        }

        // Acumular estadísticas generales
        statsAccumulated['goals'] += matchStats['goals'];
        statsAccumulated['assists'] += matchStats['assists'];
        statsAccumulated['saves'] += matchStats['saves'];
        statsAccumulated['shotsReceived'] += matchStats['shotsReceived'];
        statsAccumulated['goalsReceived'] += matchStats['goalsReceived'];
        statsAccumulated['shots'] += matchStats['shots'];
        statsAccumulated['shotsOnGoal'] += matchStats['shotsOnGoal'];
        statsAccumulated['yellowCards'] += matchStats['yellowCards'];
        statsAccumulated['redCards'] += matchStats['redCards'];
        statsAccumulated['foul'] += matchStats['foul'];

        // Añadir las estadísticas de este partido a la lista de partidos
        matchesStats.add(matchStats);
      }

      // Actualizar el estado con las estadísticas acumuladas
      setState(() {
        generalStats = statsAccumulated; // Actualizar estadísticas generales
        isLoading = false; // Finalizar estado de carga
      });

    } catch (e) {
      print("Error al obtener estadísticas: $e");
      setState(() {
        isLoading = false; // Finalizar estado de carga si hay error
      });
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

      // Función para obtener el rango de fechas según la temporada
    DateTimeRange _getDateRangeForSeason(String season) {
      final startDate = DateTime(int.parse(season.split('-')[0]), 8, 1); // Inicio: 1 de agosto
      final endDate = DateTime(int.parse(season.split('-')[1]), 7, 31); // Fin: 31 de julio del siguiente año
      return DateTimeRange(start: startDate, end: endDate);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Estadísticas Generales'),
            pinned: false, // El AppBar no se mantiene fijo
            floating: true, // Aparece al hacer scroll hacia arriba
            snap: true, // Permite que el AppBar aparezca rápidamente cuando se hace scroll hacia arriba
            actions: [
              IconButton(
                icon: const Icon(Icons.person_pin_circle_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IndividualStatsPlayerScreen()), // Navega a la InfoPage
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  setState(() {
                    _isInfoExpanded = !_isInfoExpanded; // Cambia el estado del infoExpanded
                    if (_isInfoExpanded) {
                      _isSearchingExpanded = false; // Cierra el filtro si se abre la info
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () {
                  setState(() {
                    _isSearchingExpanded = !_isSearchingExpanded; // Cambia el estado del isSearchingExpanded
                    if (_isSearchingExpanded) {
                      _isInfoExpanded = false; // Cierra la info si se abre el filtro
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
                                // Aquí estamos pasando también el dateRange
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
        width: 150, // Ancho del gráfico circular
        height: 150, // Alto del gráfico circular
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
  required List<BarChartGroupData> data, required String title, // Controlar si se muestran los títulos numéricos del eje X
}) {
  return SizedBox(
    height: 400,
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
              reservedSize: 10,
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

