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

  // Nuevas variables
  String currentFilterType = 'completa'; // Tipo de filtro actual
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
      currentFilterType = period;
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

      // Iterar a través de los partidos
      for (var match in matchesSnapshot.docs) {
        print("Procesando partido con ID: ${match.id}");

        // Acceder a la colección de jugadores dentro de cada partido
        QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(match.id)
            .collection('players')
            .get();

        print("Jugadores encontrados en el partido: ${playerSnapshot.docs.length}");

        // Acumular las estadísticas de los jugadores
        for (var player in playerSnapshot.docs) {
          Map<String, dynamic> playerData = player.data() as Map<String, dynamic>;

          print("Datos del jugador: $playerData");

          // Asegurarse de que las claves existen y no son nulas
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
                  // Mostrar el filtro y el número de partidos
                  Text(
                    'Filtro: $currentFilterType (${matchesCount} partidos)',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center, // Cambiado a center para centrar el texto
                  ),
                  const SizedBox(height: 20),
                  // Centro la tabla
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container( // Contenedor para ajustar el ancho
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.95), // Ajustar el ancho
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
                  ),
                ],
              ),
            ),
    );
  }
}
