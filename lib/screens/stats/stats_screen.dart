import 'package:flutter/material.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:CoachCraft/services/match_service.dart';
import 'package:CoachCraft/widgets/match/player_stat_card.dart';

class StatsScreen extends StatefulWidget {
  final String matchDate;
  final String rivalTeam;
  final String result;
  final String matchType;
  final String location;

  const StatsScreen({
    Key? key,
    required this.matchDate,
    required this.rivalTeam,
    required this.result,
    required this.matchType,
    required this.location, required List playerStats,
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
  bool _isExpanded = false;
  List<dynamic> playerStats = []; // Lista para almacenar las estadísticas de jugadores

  final List<String> matchTypes = ['Amistoso', 'Liga', 'Copa', 'Supercopa', 'Playoffs'];
  final List<String> locations = ['Casa', 'Fuera'];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: _formatDate(widget.matchDate));
    _rivalController = TextEditingController(text: widget.rivalTeam);
    _resultController = TextEditingController(text: widget.result);
    _matchType = widget.matchType;
    _location = widget.location;
    _fetchPlayerStats(); // Llama a la función para cargar estadísticas de jugadores
  }

  Future<void> _fetchPlayerStats() async {
    final fetchedStats = await MatchService().fetchPlayerStats(widget.rivalTeam, widget.matchDate);
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

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
  }

  Future<void> _deleteMatch() async {
    // Confirmación antes de eliminar
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
        await MatchService().deleteMatch(widget.rivalTeam, widget.matchDate);
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
      await MatchService().updateMatchByDetails(updatedData);
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Modificar Estadísticas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            if (_isExpanded) ...[
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
                        MaterialPageRoute(builder: (context) => MenuScreenFutsal(teamId: '',)),
                      );
                    },
                    child: const Text('Guardar'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      await _deleteMatch();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MenuScreenFutsal(teamId: '',)),
                      );
                    },
                    child: const Text('Borrar Partido'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
            const SizedBox(height: 8.0),
             
            Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcula el ancho total disponible
                double availableWidth = constraints.maxWidth;

                // Determina cuántas tarjetas caben en una fila, basadas en un ancho deseado
                int count = (availableWidth / 800).floor(); // Ajusta 650 según el ancho deseado de la tarjeta

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count > 0 ? count : 1,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                  itemCount: playerStats.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 1400, // Altura fija de la tarjeta (ajusta según tus necesidades)
                      width: 800, // Ancho fijo de la tarjeta
                      child: PlayerStatCard(playerStat: playerStats[index]),
                    );
                  },
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