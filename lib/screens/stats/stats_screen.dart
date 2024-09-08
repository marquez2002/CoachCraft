import 'package:CoachCraft/models/player_stats.dart'; // Asegúrate de que el nombre del archivo sea correcto
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<PlayerStats> _playerStats = [];

  String? _rivalTeam;
  DateTime? _matchDate;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    QuerySnapshot snapshot = await _firestore.collection('team').get();
    setState(() {
      // Mapa de datos a PlayerStats
      _playerStats.addAll(snapshot.docs.map((doc) => PlayerStats.fromJson(doc.data() as Map<String, dynamic>)));

      // Ordenar jugadores por dorsal
      _playerStats.sort((a, b) => a.dorsal.compareTo(b.dorsal));
    });
  }

  void _incrementStat(PlayerStats playerStat, String stat) {
    setState(() {
      switch (stat) {
        case 'goals':
          playerStat.goals++;
          break;
        case 'assists':
          playerStat.assists++;
          break;
        case 'yellowCards':
          playerStat.yellowCards++;
          break;
        case 'redCards':
          playerStat.redCards++;
          break;
        case 'shots':
          playerStat.shots++;
          break;
        case 'shotsOnGoal':
          playerStat.shotsOnGoal++;
          break;
        case 'tackle':
          playerStat.tackle++;
          break;
        case 'foul':
          playerStat.foul++;
          break;
        case 'failedPasses':
          playerStat.failedPasses++;
          break;
        case 'failedDribbles':
          playerStat.failedDribbles++;
          break;
      }
    });
  }

  void _decrementStat(PlayerStats playerStat, String stat) {
    setState(() {
      switch (stat) {
        case 'goals':
          if (playerStat.goals > 0) playerStat.goals--;
          break;
        case 'assists':
          if (playerStat.assists > 0) playerStat.assists--;
          break;
        case 'yellowCards':
          if (playerStat.yellowCards > 0) playerStat.yellowCards--;
          break;
        case 'redCards':
          if (playerStat.redCards > 0) playerStat.redCards--;
          break;
        case 'shots':
          if (playerStat.shots > 0) playerStat.shots--;
          break;
        case 'shotsOnGoal':
          if (playerStat.shotsOnGoal > 0) playerStat.shotsOnGoal--;
          break;
        case 'tackle':
          if (playerStat.tackle > 0) playerStat.tackle--;
          break;
        case 'foul':
          if (playerStat.foul > 0) playerStat.foul--;
          break;
        case 'failedPasses':
          if (playerStat.failedPasses > 0) playerStat.failedPasses--;
          break;
        case 'failedDribbles':
          if (playerStat.failedDribbles > 0) playerStat.failedDribbles--;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Rival Team'),
              onChanged: (value) {
                _rivalTeam = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Match Date'),
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  setState(() {
                    _matchDate = date;
                  });
                }
              },
              readOnly: true,
              controller: TextEditingController(text: _matchDate != null ? _matchDate!.toLocal().toString().split(' ')[0] : ''),
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: SingleChildScrollView( // Permite el desplazamiento
                child: GridView.builder(
                  shrinkWrap: true, // Evita que la cuadrícula se expanda
                  physics: const NeverScrollableScrollPhysics(), // Deshabilita el desplazamiento de la cuadrícula
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Cambia el número de columnas
                    childAspectRatio: 1.5, // Ajustado para que se vean bien las tarjetas
                    crossAxisSpacing: 8.0, // Espacio horizontal entre tarjetas
                    mainAxisSpacing: 8.0, // Espacio vertical entre tarjetas
                  ),
                  itemCount: _playerStats.length,
                  itemBuilder: (context, index) {
                    final playerStat = _playerStats[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${playerStat.nombre} #${playerStat.dorsal}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0), // Espacio entre el nombre y las estadísticas
                            ..._buildStatRows(playerStat),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatRows(PlayerStats playerStat) {
    List<String> statLabels = [
      'Goals',
      'Assists',
      'Yellow Cards',
      'Red Cards',
      'Shots',
      'Shots on Goal',
      'Tackles',
      'Fouls',
      'Failed Passes',
      'Failed Dribbles'
    ];

    List<String> statKeys = [
      'goals',
      'assists',
      'yellowCards',
      'redCards',
      'shots',
      'shotsOnGoal',
      'tackle',
      'foul',
      'failedPasses',
      'failedDribbles'
    ];

    List<Widget> statWidgets = [];

    for (int i = 0; i < statLabels.length; i++) {
      statWidgets.add(_buildStatRow(statLabels[i], playerStat.toJson()[statKeys[i]], playerStat, statKeys[i]));
      statWidgets.add(const SizedBox(height: 2.0)); // Espacio entre las filas de estadísticas
    }

    return statWidgets;
  }

  Widget _buildStatRow(String label, int value, PlayerStats playerStat, String stat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text('$label: $value')),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _incrementStat(playerStat, stat),
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _decrementStat(playerStat, stat),
            ),
          ],
        ),
      ],
    );
  }
}
