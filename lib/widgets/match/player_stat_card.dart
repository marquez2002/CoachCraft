import 'package:CoachCraft/provider/match_provider.dart';
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerStatTable extends StatefulWidget {
  const PlayerStatTable({Key? key}) : super(key: key);

  @override
  _PlayerStatTableState createState() => _PlayerStatTableState();
}

class _PlayerStatTableState extends State<PlayerStatTable> {
  List<Map<String, dynamic>> playerStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlayerStats();
  }

  Future<void> fetchPlayerStats() async {
    setState(() => isLoading = true);

    try {
      String? teamId = await getTeamId(context);
      String? matchId = Provider.of<MatchProvider>(context, listen: false).selectedMatchId;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .doc(matchId)
          .collection('players')
          .get();

      playerStats = snapshot.docs.map((doc) => {
          'id': doc.id, // Asegúrate de incluir el ID del documento
          ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener estadísticas: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showStatDialog(BuildContext context, String playerId, String statKey, int currentValue) {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Actualizar $statKey'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Valor actual: $currentValue'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      int newValue = int.parse(controller.text) > 0 ? int.parse(controller.text) - 1 : 0;
                      controller.text = newValue.toString();
                    },
                  ),
                  Container(
                    width: 50,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '',
                        isDense: true,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      int newValue = int.parse(controller.text) + 1;
                      controller.text = newValue.toString();
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                int? newValue = int.tryParse(controller.text);
                if (newValue == null || newValue < 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text("Ingrese un número válido mayor o igual a 0")),
                  );
                } else {
                  int change = newValue - currentValue;
                  await _updateStatInDB(dialogContext, playerId, statKey, change);
                  Navigator.of(dialogContext).pop(); // Cerrar el diálogo
                  _showSnackBar("Estadística actualizada exitosamente");
                }
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateStatInDB(BuildContext context, String playerId, String statKey, int change) async {
    try {
      String? teamId = await getTeamId(context);
      String? matchId = Provider.of<MatchProvider>(context, listen: false).selectedMatchId;
      
      DocumentReference playerRef = FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .doc(matchId)
          .collection('players')
          .doc(playerId);

      // Obtener el valor actual del statKey
      DocumentSnapshot playerDoc = await playerRef.get();
      
      if (playerDoc.exists) {
        // Actualizar el campo específico con el cambio
        await playerRef.update({statKey: FieldValue.increment(change)});
        await fetchPlayerStats(); // Refrescar estadísticas después de la actualización
      } else {
        throw Exception('El documento del jugador no existe.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error actualizando la estadística: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Tabla para porteros
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Estadísticas Porteros',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(
                              height: 150, // Altura limitada para hacer scroll vertical
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Scroll horizontal
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Center(child: Icon(Icons.person))), // Nombre
                                    DataColumn(label: Center(child: Icon(Icons.tag))), // Dorsal
                                    DataColumn(label: Center(child: Icon(Icons.switch_access_shortcut_add_outlined))), // Posición
                                    DataColumn(label: Center(child: Icon(Icons.sports_soccer, color: Colors.red))), // Goles recibidos
                                    DataColumn(label: Center(child: Icon(Icons.sports_handball_sharp, color: Colors.green))), // Tiros A Puerta Recibidos
                                    DataColumn(label: Center(child: Icon(Icons.sports_handball_sharp))), // Tiros A Puerta Recibidos
                                    DataColumn(label: Center(child: Icon(Icons.sports_soccer))), // Goles
                                    DataColumn(label: Center(child: Icon(Icons.group_add_sharp))), // Asistencias
                                    DataColumn(label: Center(child: Icon(Icons.square, color: Colors.yellow))), // Tarjetas Amarillas
                                    DataColumn(label: Center(child: Icon(Icons.square, color: Colors.red))), // Tarjetas Rojas
                                    DataColumn(label: Center(child: Icon(Icons.sports))), // Faltas
                                  ],
                                  rows: playerStats.where((playerStat) => playerStat['posicion'] == 'Portero').map((playerStat) {
                                    return DataRow(cells: [
                                      DataCell(Center(child: Text(playerStat['nombre'] ?? 'Sin Nombre'))),
                                      DataCell(Center(child: Text(playerStat['dorsal']?.toString() ?? 'Sin Dorsal'))),
                                      DataCell(Center(child: Text(playerStat['posicion'] ?? 'Sin Posición'))),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'goalsReceived', playerStat['goalsReceived'] ?? 0),
                                          child: Center(child: Text(playerStat['goalsReceived']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'saves', playerStat['saves'] ?? 0),
                                          child: Center(child: Text(playerStat['saves']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'shotsReceived', playerStat['shotsReceived'] ?? 0),
                                          child: Center(child: Text(playerStat['shotsReceived']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'goals', playerStat['goals'] ?? 0),
                                          child: Center(child: Text(playerStat['goals']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'assists', playerStat['assists'] ?? 0),
                                          child: Center(child: Text(playerStat['assists']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'yellowCards', playerStat['yellowCards'] ?? 0),
                                          child: Center(child: Text(playerStat['yellowCards']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'redCards', playerStat['redCards'] ?? 0),
                                          child: Center(child: Text(playerStat['redCards']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'foul', playerStat['foul'] ?? 0),
                                          child: Center(child: Text(playerStat['foul']?.toString() ?? '0')),
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8), // Espaciador entre tablas
                      // Tabla para el resto de los jugadores
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Jugadores de Campo',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(
                              height: 400, // Altura limitada para hacer scroll vertical
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Scroll horizontal
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Center(child: Icon(Icons.person))), // Nombre
                                    DataColumn(label: Center(child: Icon(Icons.tag))), // Dorsal
                                    DataColumn(label: Center(child: Icon(Icons.switch_access_shortcut_add_outlined))), // Posición
                                    DataColumn(label: Center(child: Icon(Icons.sports_soccer))), // Goles
                                    DataColumn(label: Center(child: Icon(Icons.group_add_sharp))), // Asistencias
                                    DataColumn(label: Center(child: Icon(Icons.square, color: Colors.yellow))), // Tarjetas Amarillas
                                    DataColumn(label: Center(child: Icon(Icons.square, color: Colors.red))), // Tarjetas Rojas
                                    DataColumn(label: Center(child: Icon(Icons.gps_not_fixed))), // Tiros
                                    DataColumn(label: Center(child: Icon(Icons.gps_fixed_rounded))), // Tiros a Puerta
                                    DataColumn(label: Center(child: Icon(Icons.sports))), // Faltas
                                  ],
                                  rows: playerStats.where((playerStat) => playerStat['posicion'] != 'Portero').map((playerStat) {
                                    return DataRow(cells: [
                                      DataCell(Center(child: Text(playerStat['nombre'] ?? 'Sin Nombre'))),
                                      DataCell(Center(child: Text(playerStat['dorsal']?.toString() ?? 'Sin Dorsal'))),
                                      DataCell(Center(child: Text(playerStat['posicion'] ?? 'Sin Posición'))),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'goals', playerStat['goals'] ?? 0),
                                          child: Center(child: Text(playerStat['goals']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'assists', playerStat['assists'] ?? 0),
                                          child: Center(child: Text(playerStat['assists']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'yellowCards', playerStat['yellowCards'] ?? 0),
                                          child: Center(child: Text(playerStat['yellowCards']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'redCards', playerStat['redCards'] ?? 0),
                                          child: Center(child: Text(playerStat['redCards']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'shots', playerStat['shots'] ?? 0),
                                          child: Center(child: Text(playerStat['shots']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'shotsOnGoal', playerStat['shotsOnGoal'] ?? 0),
                                          child: Center(child: Text(playerStat['shotsOnGoal']?.toString() ?? '0')),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTap: () => _showStatDialog(context, playerStat['id'] ?? '', 'foul', playerStat['foul'] ?? 0),
                                          child: Center(child: Text(playerStat['foul']?.toString() ?? '0')),
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
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
}