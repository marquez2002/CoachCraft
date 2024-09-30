import 'package:CoachCraft/provider/team_provider.dart';
import 'package:CoachCraft/widgets/match/filter_section_stats.dart';
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
    'shots': 0,
    'shotsOnGoal': 0,
    'yellowCards': 0,
    'redCards': 0,
    'foul': 0,
    'tackle': 0,
    'succesfulTackle': 0,
  };

  List<Map<String, dynamic>> matchesStats = [];
  bool isLoading = true;
  bool _isSearchingExpanded = false;

  // Nuevas variables
  String _season = 'Todos'; // Almacenar la temporada seleccionada
  String _matchType = 'Todos'; // Almacenar el tipo 
  int matchesCount = 0; // Contador de partidos

  @override
  void initState() {
    super.initState();
    fetchGeneralStats(); // Carga inicial de estadísticas
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

  // Fetch general stats from Firestore
  Future<void> fetchGeneralStats({String period = 'completa'}) async {
    setState(() => isLoading = true);
    try {
      // Obtener ID del equipo seleccionado
      String? teamId = await getTeamId(context);
      if (teamId == null) {
        throw Exception('El ID del equipo es null');
      }

      // Obtener la fecha de inicio según el periodo seleccionado
      DateTime startDate = getStartDate(period);
      print("Buscando partidos desde: $startDate para el equipo: $teamId");

      // Convertir la fecha a String para Firestore
      String startDateAsString = startDate.toIso8601String();
      print("startDate as String: $startDateAsString");

      // Consultar partidos a partir de la fecha de inicio
      QuerySnapshot matchesSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .where('matchDate', isGreaterThanOrEqualTo: startDateAsString)
          .get();

      print("Partidos encontrados: ${matchesSnapshot.docs.length}");
      matchesCount = matchesSnapshot.docs.length;

      // Inicializar un mapa para acumular estadísticas
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

      // Limpiar las estadísticas de cada partido
      matchesStats.clear();

      // Iterar a través de los partidos
      for (var match in matchesSnapshot.docs) {
        print("Procesando partido con ID: ${match.id}");

        // Obtener el nombre y la fecha del partido
        String matchName = match['rivalTeam'] ?? 'Partido sin nombre';
        DateTime matchDate = DateTime.parse(match['matchDate']);
        String formattedDate = DateFormat('dd-MM-yyyy').format(matchDate);

        // Inicializar las estadísticas para el partido actual
        Map<String, dynamic> matchStats = {
          'matchName': matchName,
          'matchDate': formattedDate,
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
          matchStats['shots'] += playerData['shots'] ?? 0;
          matchStats['shotsOnGoal'] += playerData['shotsOnGoal'] ?? 0;
          matchStats['yellowCards'] += playerData['yellowCards'] ?? 0;
          matchStats['redCards'] += playerData['redCards'] ?? 0;
          matchStats['foul'] += playerData['foul'] ?? 0;
          matchStats['tackle'] += playerData['tackle'] ?? 0;
          matchStats['succesfulTackle'] += playerData['succesfulTackle'] ?? 0;
        }

        // Acumular las estadísticas generales
        statsAccumulated['goals'] += matchStats['goals'];
        statsAccumulated['assists'] += matchStats['assists'];
        statsAccumulated['saves'] += matchStats['saves'];
        statsAccumulated['shotsReceived'] += matchStats['shotsReceived'];
        statsAccumulated['shots'] += matchStats['shots'];
        statsAccumulated['shotsOnGoal'] += matchStats['shotsOnGoal'];
        statsAccumulated['yellowCards'] += matchStats['yellowCards'];
        statsAccumulated['redCards'] += matchStats['redCards'];
        statsAccumulated['foul'] += matchStats['foul'];
        statsAccumulated['tackle'] += matchStats['tackle'];
        statsAccumulated['succesfulTackle'] += matchStats['succesfulTackle'];

        // Añadir las estadísticas de este partido a la lista de partidos
        matchesStats.add(matchStats);
      }

      // Actualizar las estadísticas generales con las estadísticas acumuladas
      setState(() {
        generalStats = statsAccumulated;
      });

      print("Estadísticas acumuladas: $generalStats");
    } catch (e) {
      print("Error al obtener las estadísticas: $e");
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
    appBar: AppBar(
      title: const Text('Estadísticas Generales'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_alt_outlined),
          onPressed: () {
            setState(() {
              _isSearchingExpanded = !_isSearchingExpanded;
            });
          },
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
                // Formulario para buscar partidos
                if (_isSearchingExpanded) ...[
                  FilterSection(
                    season: _season,
                    onFilterChanged: (String season, String matchType) {
                      setState(() {
                        _season = season;
                        _matchType = matchType;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                ],
                const SizedBox(height: 20),
                // Mostrar las estadísticas de cada partido
                Text(
                  'Estadísticas por Partido',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center( // Aquí centramos la tabla en el eje horizontal
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
                        DataColumn(label: Icon(Icons.gps_not_fixed)),
                        DataColumn(label: Icon(Icons.gps_fixed_rounded)),
                        DataColumn(label: Icon(Icons.square, color: Colors.yellow)),
                        DataColumn(label: Icon(Icons.square, color: Colors.red)),
                        DataColumn(label: Icon(Icons.sports)),
                        DataColumn(label: Center(child: Icon(Icons.shield))), // Entradas
                        DataColumn(label: Center(child: Icon(Icons.shield, color: Colors.green))),
                      ],
                      rows: matchesStats.map((match) {
                        return DataRow(cells: [
                          DataCell(Text(match['matchName'].toString())),
                          DataCell(Text(match['matchDate'].toString())),
                          DataCell(Text(match['goals'].toString())),
                          DataCell(Text(match['assists'].toString())),
                          DataCell(Text(match['shotsReceived'].toString())),
                          DataCell(Text(match['saves'].toString())),
                          DataCell(Text(match['shots'].toString())),
                          DataCell(Text(match['shotsOnGoal'].toString())),
                          DataCell(Text(match['yellowCards'].toString())),
                          DataCell(Text(match['redCards'].toString())),
                          DataCell(Text(match['foul'].toString())),
                          DataCell(Text(match['tackle'].toString())),
                          DataCell(Text(match['succesfulTackle'].toString())),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Estadísticas Generales',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Aquí viene el sumatorio general
                _buildGeneralStatsTable(),
                const SizedBox(height: 20),
                // Agregar el gráfico
                Wrap(
                  spacing: 20.0,
                  runSpacing: 20.0,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildPieChart(
                      title: 'Paradas Vs Tiros Recibidos',
                      sectionData: [
                        PieChartSectionData(
                          value: generalStats['shotsReceived']?.toDouble() ?? 0,
                          title: '${generalStats['shotsReceived']?.toString() ?? 0}',
                          color: Colors.grey,
                        ),
                        PieChartSectionData(
                          value: generalStats['saves']?.toDouble() ?? 0,
                          title: '${generalStats['saves']?.toString() ?? 0}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    _buildPieChart(
                      title: 'Tiros vs Tiros a Puerta',
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
                    _buildPieChart(
                      title: 'Goles vs Tiros',
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
                    _buildPieChart(
                      title: 'Tarjetas Amarilla vs Rojas',
                      sectionData: [
                        PieChartSectionData(
                          value: generalStats['yellowCards']?.toDouble() ?? 0,
                          title: '${generalStats['yellowCards']?.toString() ?? 0}',
                          color: Colors.yellow,
                        ),
                        PieChartSectionData(
                          value: generalStats['redCards']?.toDouble() ?? 0,
                          title: '${generalStats['redCards']?.toString() ?? 0}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                    _buildPieChart(
                      title: 'Faltas vs Tarjetas Amarilla',
                      sectionData: [
                        PieChartSectionData(
                          value: generalStats['yellowCards']?.toDouble() ?? 0,
                          title: '${generalStats['yellowCards']?.toString() ?? 0}',
                          color: Colors.yellow,
                        ),
                        PieChartSectionData(
                          value: generalStats['foul']?.toDouble() ?? 0,
                          title: '${generalStats['foul']?.toString() ?? 0}',
                          color: Colors.teal,
                        ),
                      ],
                    ),
                    _buildPieChart(
                      title: 'Tackles vs Tackles Exitosos',
                      sectionData: [
                        PieChartSectionData(
                          value: generalStats['tackle']?.toDouble() ?? 0,
                          title: '${generalStats['tackle']?.toString() ?? 0}',
                          color: Colors.pinkAccent,
                        ),
                        PieChartSectionData(
                          value: generalStats['succesfulTackle']?.toDouble() ?? 0,
                          title: '${generalStats['succesfulTackle']?.toString() ?? 0}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
          DataColumn(label: Icon(Icons.gps_not_fixed)),
          DataColumn(label: Icon(Icons.gps_fixed_rounded)),
          DataColumn(label: Icon(Icons.square, color: Colors.yellow)),
          DataColumn(label: Icon(Icons.square, color: Colors.red)),
          DataColumn(label: Icon(Icons.sports)),
          DataColumn(label: Center(child: Icon(Icons.shield))), // Entradas
          DataColumn(label: Center(child: Icon(Icons.shield, color: Colors.green))),
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
    );
  }
}

Widget _buildPieChart({required String title, required List<PieChartSectionData> sectionData}) {
  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      Container(
        width: 150, // Width of the pie chart
        height: 150, // Height of the pie chart
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