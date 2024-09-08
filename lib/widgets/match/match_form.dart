import 'package:CoachCraft/services/match_service.dart';
import 'package:CoachCraft/services/player_service.dart'; // Asegúrate de que esta clase exista
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchForm extends StatefulWidget {
  final Function onMatchCreated;

  const MatchForm({Key? key, required this.onMatchCreated}) : super(key: key);

  @override
  _MatchFormState createState() => _MatchFormState();
}

class _MatchFormState extends State<MatchForm> {
  final TextEditingController _rivalTeamController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  DateTime? _selectedDate;
  String _location = 'Casa';
  String _matchType = 'Amistoso';
  bool _isExpanded = false; // Estado para controlar la expansión

  Future<void> _createMatch() async {
    if (_rivalTeamController.text.isEmpty || _selectedDate == null || _resultController.text.isEmpty) {
      return; // Validación básica
    }

    // Crea el partido y guarda el ID
    String matchId = await MatchService().createMatch({
      'rivalTeam': _rivalTeamController.text,
      'matchDate': _selectedDate!.toIso8601String(),
      'result': _resultController.text,
      'location': _location,
      'matchType': _matchType,
    });

    // Obtener los jugadores actuales de la plantilla
    List<Map<String, dynamic>> players = await PlayerService().getCurrentPlayers(); // Asegúrate de implementar este método

    // Guardar los jugadores en la colección raíz del partido
    await MatchService().savePlayersForMatch(matchId, players);

    _clearForm();
    widget.onMatchCreated();
  }

  void _clearForm() {
    _rivalTeamController.clear();
    _resultController.clear();
    _selectedDate = null;
    _location = 'Casa';
    _matchType = 'Amistoso'; // Reiniciar a "Amistoso" al limpiar el formulario
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con el botón de expansión
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // Cambia el estado de expansión
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Crear un nuevo partido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(_isExpanded ? Icons.expand_less : Icons.expand_more), // Ícono de expansión
            ],
          ),
        ),
        const SizedBox(height: 8.0),

        // Contenido del formulario que se expande o colapsa
        if (_isExpanded) ...[
          TextField(
            controller: _rivalTeamController,
            decoration: const InputDecoration(
              labelText: 'Equipo rival',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),

          TextField(
            controller: _resultController,
            decoration: const InputDecoration(
              labelText: 'Resultado (2-1)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),

          TextField(
            decoration: const InputDecoration(
              labelText: 'Fecha del Partido',
              border: OutlineInputBorder(),
            ),
            onTap: () async {
              DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            readOnly: true,
            controller: TextEditingController(
              text: _selectedDate != null ? DateFormat('dd-MM-yyyy').format(_selectedDate!) : '',
            ),
          ),
          const SizedBox(height: 8.0),

          DropdownButtonFormField<String>(
            value: _location,
            decoration: const InputDecoration(
              labelText: 'Lugar del partido',
              border: OutlineInputBorder(),
            ),
            onChanged: (String? newValue) {
              setState(() {
                _location = newValue!;
              });
            },
            items: <String>['Casa', 'Fuera'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
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
            items: <String>['Amistoso', 'Liga', 'Copa', 'Supercopa', 'Playoffs']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          const SizedBox(height: 16.0),

          Center(
            child: ElevatedButton(
              onPressed: _createMatch,
              child: const Text('Crear Partido'),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ],
    );
  }
}
