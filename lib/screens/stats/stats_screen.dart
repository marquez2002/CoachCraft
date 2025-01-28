/*
 * Archivo: stats_screen.dart
 * Descripción: Este archivo contiene la pantalla de estadísticas de un partido concreto.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/widgets/match/player_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:CoachCraft/services/match/match_service.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  final String matchDate;
  final String rivalTeam;
  final String result;
  final String matchType;
  final String location;
  final String matchId;

  const StatsScreen({
    Key? key,
    required this.matchDate,
    required this.rivalTeam,
    required this.result,
    required this.matchType,
    required this.location,
    required this.matchId,
  }) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late TextEditingController _rivalController;
  late TextEditingController _resultController;
  late TextEditingController _dateController;
  String _matchType = '';
  String _location = '';
  bool _isModifyExpanded = false;
  bool _isInfoExpanded = false;
  List<dynamic> playerStats = [];

  final List<String> matchTypes = ['Amistoso', 'Liga', 'Copa', 'Supercopa', 'Playoffs'];
  final List<String> locations = ['Casa', 'Fuera'];

  @override
  void initState() {
    super.initState();
    _rivalController = TextEditingController(text: widget.rivalTeam);
    _resultController = TextEditingController(text: widget.result);
    _dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.matchDate)),
    );
    _matchType = widget.matchType;
    _location = widget.location;
    _fetchPlayerStats();
  }

  Future<void> _fetchPlayerStats() async {
    final fetchedStats = await MatchService().fetchMatches(context);
    setState(() {
      playerStats = fetchedStats;
    });
  }

  @override
  void dispose() {
    _rivalController.dispose();
    _resultController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _deleteMatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este partido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await MatchService().deleteMatch(context, widget.rivalTeam, widget.matchDate);
        Navigator.pop(context); // Volver a la pantalla anterior
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partido eliminado exitosamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el partido: $e')),
        );
      }
    }
  }

  Future<void> _updateMatch() async {
    final updatedData = {
      'rivalTeam': widget.rivalTeam,
      'matchDate': widget.matchDate,
      'result': _resultController.text,
      'matchType': _matchType,
      'location': _location,
    };

    try {
      await MatchService().updateMatchByDetails(context, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partido actualizado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el partido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas del Partido: ${_rivalController.text}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              setState(() {
                _isInfoExpanded = !_isInfoExpanded;
                _isModifyExpanded = false; // Cierra modificación al abrir info
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isModifyExpanded = !_isModifyExpanded;
                _isInfoExpanded = false; // Cierra info al abrir modificación
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isModifyExpanded) ...[
              SingleChildScrollView( // Agrega SingleChildScrollView para hacer que el contenido sea desplazable
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinea los elementos a la izquierda si es necesario
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rivalController,
                            decoration: const InputDecoration(
                              labelText: 'Rival',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false, // Mantiene el campo fijo
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              labelText: 'Fecha',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false, // Mantiene el campo fijo
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _resultController,
                      decoration: const InputDecoration(
                        labelText: 'Resultado',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: _matchType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Partido',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _matchType = newValue!;
                        });
                      },
                      items: matchTypes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: _location,
                      decoration: const InputDecoration(
                        labelText: 'Lugar del Partido',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _location = newValue!;
                        });
                      },
                      items: locations.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await _updateMatch();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => MenuScreenFutsal()),
                            );
                          },
                          child: const Text('Guardar'),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar Borrado'),
                                  content: const Text('¿Está seguro de que desea borrar este partido?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Borrar'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete == true) {
                              await _deleteMatch();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => MenuScreenFutsal()),
                              );
                            }
                          },
                          child: const Text('Borrar Partido'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (_isInfoExpanded) ...[
              Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.center,
                children: [
                  IconInfoColumn(icon: Icons.sports_soccer, label: 'Gol'),
                  IconInfoColumn(icon: Icons.group_add_sharp, label: 'Asistencia'),
                  IconInfoColumn(icon: Icons.sports_handball_sharp, label: 'Tiros Recibidos'),
                  IconInfoColumn(icon: Icons.sports_handball_sharp, label: 'Paradas', iconColor: Colors.green),
                  IconInfoColumn(icon: Icons.sports_soccer, label: 'Gol Recibido', iconColor: Colors.red),
                  IconInfoColumn(icon: Icons.gps_not_fixed, label: 'Tiros'),
                  IconInfoColumn(icon: Icons.gps_fixed_rounded, label: 'Tiros a Puerta'),
                  IconInfoColumn(icon: Icons.square, label: 'Tarjeta Amarilla', iconColor: Colors.yellow),
                  IconInfoColumn(icon: Icons.square, label: 'Tarjeta Roja', iconColor: Colors.red),
                  IconInfoColumn(icon: Icons.sports, label: 'Faltas'),
                ],
              ),
            ],
            const SizedBox(height: 8.0),
              Expanded(
                child: PlayerStatTable(),
              ),
          ],
        ),
      ),
    );
  }
}

class IconInfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const IconInfoColumn({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor),
        Text(label),
      ],
    );
  }
}
