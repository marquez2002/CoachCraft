import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:CoachCraft/services/match_service.dart';
import 'package:flutter/material.dart';

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
    required this.location,
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

  final List<String> matchTypes = ['Amistoso', 'Liga', 'Copa', 'Supercopa', 'Playoffs'];
  final List<String> locations = ['Casa', 'Fuera'];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: _formatDate(widget.matchDate)); // Formato correcto
    _rivalController = TextEditingController(text: widget.rivalTeam);
    _resultController = TextEditingController(text: widget.result);
    _matchType = widget.matchType; 
    _location = widget.location; 
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
                const Text('Modificar Estadísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          if (_isExpanded) ...[
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
                const SizedBox(width: 8.0), // Espacio entre Rival y Fecha
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
            // Modificación en el Row de los botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centrado
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _updateMatch(); // Llama a la función de actualización
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MenuScreenFutsal()), // Navegar a MenuScreenFutsal
                    );
                  },
                  child: const Text('Guardar'),
                ),
                const SizedBox(width: 16.0), // Espacio entre los botones
                ElevatedButton(
                  onPressed: () async {
                    await _deleteMatch(); // Llama a la función de eliminación
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MenuScreenFutsal()), // Navegar a MenuScreenFutsal
                    );
                  },
                  child: const Text('Borrar Partido'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ],
      ),
    ),
  );
  }
}