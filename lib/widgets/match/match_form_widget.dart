/*
 * Archivo: match_form_widget.dart
 * Descripción: Este archivo contiene la clase correspondiente al formulario de los datos de los partidos.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/services/match/match_service.dart';
import 'package:CoachCraft/services/player/player_service.dart';
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

  /// Función que permite crear un partido.
  Future<void> _createMatch() async {
    // Validación básica: Asegurarse de que todos los campos están completos
    if (_rivalTeamController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese el equipo rival.')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione la fecha del partido.')),
      );
      return;
    }

    if (_resultController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese el resultado del partido.')),
      );
      return;
    }

    // Crea el partido y guarda el ID
    String matchId = await MatchService().createMatch(context, {
      'rivalTeam': _rivalTeamController.text,
      'matchDate': _selectedDate!.toIso8601String(),
      'result': _resultController.text,
      'location': _location,
      'matchType': _matchType,
    });

    // Obtener los jugadores actuales de la plantilla
    List<Map<String, dynamic>> players = await getCurrentPlayers(context);

    // Guardar los jugadores en la colección raíz del partido
    await MatchService().savePlayersForMatch(context, matchId, players);

    _clearForm(); 
    // Notificar que se ha creado el partido
    widget.onMatchCreated(); 
  }

  // Limpiar el formulario
  void _clearForm() {
    _rivalTeamController.clear();
    _resultController.clear();
    setState(() {
      _selectedDate = null;
      _location = 'Casa';
      _matchType = 'Amistoso';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(  
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crear un nuevo partido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // Campo para ingresar el equipo rival
            TextField(
              controller: _rivalTeamController,
              decoration: const InputDecoration(
                labelText: 'Equipo rival',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),

            // Campo para ingresar el resultado
            TextField(
              controller: _resultController,
              decoration: const InputDecoration(
                labelText: 'Resultado (ej: 2-1)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),

            // Campo para seleccionar la fecha del partido
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

            // Dropdown para la ubicación
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

            // Dropdown para el tipo de partido
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

            // Botón para crear el partido
            Center(
              child: ElevatedButton(
                onPressed: _createMatch,
                child: const Text('Crear Partido'),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
