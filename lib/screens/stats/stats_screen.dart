import 'package:CoachCraft/widgets/match/player_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:CoachCraft/services/match/match_service.dart';

class StatsScreen extends StatefulWidget {
  final String matchDate;
  final String rivalTeam;
  final String result;
  final String matchType;
  final String location;
  final String matchId; // Añadir matchId como propiedad

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
  late TextEditingController _dateController;
  late TextEditingController _rivalController;
  late TextEditingController _resultController;
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
    _matchType = widget.matchType;
    _location = widget.location;
    _fetchPlayerStats();
  }

  Future<void> _fetchPlayerStats() async {
    final fetchedStats = await MatchService().fetchMatches(context);
    setState(() {
      playerStats = fetchedStats; // Actualiza la lista de estadísticas
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _rivalController.dispose();
    _resultController.dispose();
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
        Navigator.pop(context); // Regresar a la pantalla anterior
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
                _isInfoExpanded = !_isInfoExpanded; // Cambia el estado del infoExpanded
                if (_isInfoExpanded) {
                  _isModifyExpanded = false; // Cierra el filtro si se abre la info
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {
                _isModifyExpanded = !_isModifyExpanded; // Cambia el estado del isSearchingExpanded
                if (_isModifyExpanded) {
                  _isInfoExpanded = false; // Cierra la info si se abre el filtro
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isModifyExpanded) ...[
              // Campos de edición
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rivalController,
                      decoration: const InputDecoration(
                        labelText: 'Rival',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
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
                      enabled: false,
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
                      await _deleteMatch();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MenuScreenFutsal()),
                      );
                    },
                    child: const Text('Borrar Partido'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
            if (_isInfoExpanded) ...[
              Wrap(
                spacing: 20.0, // Espacio entre los íconos
                runSpacing: 20.0, // Espacio entre las filas
                alignment: WrapAlignment.center, // Centrar los íconos
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_soccer),
                      Text('Gol'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_add_sharp),
                      Text('Asistencia'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_handball_sharp),
                      Text('Tiros Recibidos'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_handball_sharp, color: Colors.green),
                      Text('Paradas'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_soccer, color: Colors.red),
                      Text('Gol Recibido'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gps_not_fixed),
                      Text('Tiros'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gps_fixed_rounded),
                      Text('Tiros a Puerta'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.square, color: Colors.yellow),
                      Text('Tarjeta Amarilla'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.square, color: Colors.red),
                      Text('Tarjeta Roja'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports),
                      Text('Faltas'),
                    ],
                  ),
                ],
              ),
            ],
              const SizedBox(height: 8.0),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: 140,
                      child: PlayerStatTable(),
                    );
                  },
                ),
              ),            
            ],          
          ),
        ),
      );
  }
}
