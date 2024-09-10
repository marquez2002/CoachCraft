import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerStatCard extends StatefulWidget {
  final dynamic playerStat;

  const PlayerStatCard({Key? key, required this.playerStat}) : super(key: key);

  @override
  _PlayerStatCardState createState() => _PlayerStatCardState();
}

class _PlayerStatCardState extends State<PlayerStatCard> {
  late int goals;
  late int assists;
  late int yellowCards;
  late int redCards;
  late int shots;
  late int shotsOnGoal;
  late int tackle;
  late int succesfulTackle;
  late int foul;
  late int passes;
  late int failedPasses;
  late int dribbles;
  late int failedDribbles;
  late int saves;
  late int shotsReceived;

  @override
  void initState() {
    super.initState();
    // Inicializa los valores con los del jugador
    goals = widget.playerStat.goals;
    assists = widget.playerStat.assists;
    yellowCards = widget.playerStat.yellowCards;
    redCards = widget.playerStat.redCards;
    saves = widget.playerStat.saves;
    shotsReceived = widget.playerStat.shotsReceived;
    shots = widget.playerStat.shots;
    shotsOnGoal = widget.playerStat.shotsOnGoal;
    tackle = widget.playerStat.tackle;
    succesfulTackle = widget.playerStat.succesfulTackle;
    foul = widget.playerStat.foul;
    passes = widget.playerStat.passes;
    failedPasses = widget.playerStat.failedPasses;
    dribbles = widget.playerStat.dribbles;
    failedDribbles = widget.playerStat.failedDribbles;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.all(8.0), // Padding interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.playerStat.nombre} (#${widget.playerStat.dorsal})', // Mostrar el nombre y el dorsal
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Recorta el texto si es muy largo
                  ),
                ),
                if (widget.playerStat.posicion == "Portero") ...[
                  const Icon(Icons.sports_handball, size: 24.0),
                  const SizedBox(width: 8.0),
                ],
              ],
            ),
            const SizedBox(height: 4.0),
            ..._buildStatRows(), // Añadir estadísticas
          ],
        ),
      ),
    );
  }
  

  List<Widget> _buildStatRows() {
    List<Map<String, dynamic>> stats = [
      {'label': 'Goles', 'value': goals},
      {'label': 'Asistencias', 'value': assists},
      {'label': 'Tarjetas Amarillas', 'value': yellowCards},
      {'label': 'Tarjetas Rojas', 'value': redCards},
      {'label': 'Tiros', 'value': shots},
      {'label': 'Tiros a Puerta', 'value': shotsOnGoal},
      {'label': 'Entradas', 'value': tackle},
      {'label': 'Entradas Exitosas', 'value': succesfulTackle},
      {'label': 'Faltas', 'value': foul},
      {'label': 'Pases', 'value': passes},
      {'label': 'Pases Fallidos', 'value': failedPasses},
      {'label': 'Dribles', 'value': dribbles},
      {'label': 'Dribles Fallidos', 'value': failedDribbles},
    ];

    // Ajuste específico para porteros
    if (widget.playerStat.posicion == "Portero") {
      stats = [
        {'label': 'Goles', 'value': goals},
        {'label': 'Asistencias', 'value': assists},
        {'label': 'Tarjetas Amarillas', 'value': yellowCards},
        {'label': 'Tarjetas Rojas', 'value': redCards},
        {'label': 'Paradas', 'value': saves},
        {'label': 'Tiros a Puerta Recibidos', 'value': shotsReceived},
        {'label': 'Entradas', 'value': tackle},
        {'label': 'Entradas Exitosas', 'value': succesfulTackle},
        {'label': 'Faltas', 'value': foul},
        {'label': 'Pases', 'value': passes},
        {'label': 'Pases Fallidos', 'value': failedPasses},
        {'label': 'Dribles', 'value': dribbles},
        {'label': 'Dribles Fallidos', 'value': failedDribbles},
      ];
    }

    return stats.map((stat) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${stat['label']}: ${stat['value']}'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateStat(stat['label'], -1),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateStat(stat['label'], 1),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  void _updateStat(String label, int change) {
    setState(() {
      switch (label) {
        case 'Goles':
          goals += change;
          break;
        case 'Asistencias':
          assists += change;
          break;
        case 'Tarjetas Amarillas':
          yellowCards += change;
          break;
        case 'Tarjetas Rojas':
          redCards += change;
          break;
        case 'Tiros':
          shots += change;
          break;
        case 'Tiros a Puerta':
          shotsOnGoal += change;
          break;
        case 'Entradas':
          tackle += change;
          break;
        case 'Entradas Exitosas':
          succesfulTackle += change;
          break;
        case 'Faltas':
          foul += change;
          break;
        case 'Pases':
          passes += change;
          break;
        case 'Pases Fallidos':
          failedPasses += change;
          break;
        case 'Dribles':
          dribbles += change;
          break;
        case 'Dribles Fallidos':
          failedDribbles += change;
          break;
      }
    });

    _updateStatInDB(label, change);
  }

  Future<void> _updateStatInDB(String label, int change) async {
    DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc(widget.playerStat.id);

    switch (label) {
      case 'Goles':
        await playerRef.update({'goals': FieldValue.increment(change)});
        break;
      case 'Asistencias':
        await playerRef.update({'assists': FieldValue.increment(change)});
        break;
      case 'Tarjetas Amarillas':
        await playerRef.update({'yellowCards': FieldValue.increment(change)});
        break;
      case 'Tarjetas Rojas':
        await playerRef.update({'redCards': FieldValue.increment(change)});
        break;
      case 'Tiros':
        await playerRef.update({'shots': FieldValue.increment(change)});
        break;
      case 'Tiros a Puerta':
        await playerRef.update({'shotsOnGoal': FieldValue.increment(change)});
        break;
      case 'Entradas':
        await playerRef.update({'tackle': FieldValue.increment(change)});
        break;
      case 'Entradas Exitosas':
        await playerRef.update({'succesfulTackle': FieldValue.increment(change)});
        break;
      case 'Faltas':
        await playerRef.update({'foul': FieldValue.increment(change)});
        break;
      case 'Pases':
        await playerRef.update({'passes': FieldValue.increment(change)});
        break;
      case 'Pases Fallidos':
        await playerRef.update({'failedPasses': FieldValue.increment(change)});
        break;
      case 'Dribles':
        await playerRef.update({'dribbles': FieldValue.increment(change)});
        break;
      case 'Dribles Fallidos':
        await playerRef.update({'failedDribbles': FieldValue.increment(change)});
        break;
    }
  }
}
