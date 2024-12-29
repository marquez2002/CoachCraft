/*
 * Archivo: filter_section_widget.dart
 * Descripción: Este archivo contiene la clase correspondiente al filtro de las estadisticas de los jugadores.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filtrado de Partidos',
      home: ParentWidget(),
    );
  }
}

class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  String _season = '2024'; 
  String _matchType = 'Todos';
  bool _isSearchingExpanded = false;

  /// Función que permite actualizar los filtros correspondientes.
  void _onFilterChanged(String season, String matchType) {
    setState(() {
      _season = season; 
      _matchType = matchType;
      fetchGeneralStats(_season, _matchType);
    });
  }

  /// Función que permite buscar una serie determinada de partidos.
  void fetchGeneralStats(String season, String matchType) {
    print('Fetching stats for season: $season and match type: $matchType');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrado de Partidos'),
        actions: [
          IconButton(
            icon: Icon(_isSearchingExpanded ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _isSearchingExpanded = !_isSearchingExpanded; 
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSearchingExpanded) ...[
              FilterSectionStats(
                season: _season, 
                matchType: _matchType,
                onFilterChanged: _onFilterChanged, 
              ),
              const SizedBox(height: 16.0),
            ],
            // Muestra el estado actual de los filtros
            Text('Temporada seleccionada: $_season'),
            Text('Tipo de partido seleccionado: $_matchType'),
          ],
        ),
      ),
    );
  }
}

/// Clase para filtrar las estadisticas de los jugadores.
class FilterSectionStats extends StatefulWidget {
  final String season; 
  final String matchType;
  final Function(String, String) onFilterChanged;

  const FilterSectionStats({
    Key? key,
    required this.season,
    required this.matchType,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  _FilterSectionStatsState createState() => _FilterSectionStatsState();
}

class _FilterSectionStatsState extends State<FilterSectionStats> {
  late String _season;
  late String _matchType;

  /// Función para inicializar el widget padre.
  @override
  void initState() {
    super.initState();
    _season = widget.season;
    _matchType = widget.matchType;
  }

  /// Función para actualizar el estado del widget padre
  @override
  void didUpdateWidget(FilterSectionStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.season != widget.season || oldWidget.matchType != widget.matchType) {
      setState(() {
        _season = widget.season;
        _matchType = widget.matchType;
      });
    }
  }

  /// Función para cambiar la temporada buscada.
  void _onSeasonChanged(String? newSeason) {
    if (newSeason != null) {
      setState(() {
        _season = newSeason; 
        widget.onFilterChanged(_season, _matchType); 
      });
    }
  }

  /// Función para cambiar el tipo de partido buscado.
  void _onMatchTypeChanged(String? newMatchType) {
    if (newMatchType != null) {
      setState(() {
        _matchType = newMatchType; 
        widget.onFilterChanged(_season, _matchType); 
      });
    }
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
              'Filtrar Partidos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // Dropdown para seleccionar la temporada
            DropdownButtonFormField<String>(
              value: _season, 
              decoration: const InputDecoration(
                labelText: 'Temporada',
                border: OutlineInputBorder(),
              ),
              onChanged: _onSeasonChanged, 
              items: <String>['2024', '2023', '2022', 'Todos']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 8.0),

            // Dropdown para seleccionar el tipo de partido
            DropdownButtonFormField<String>(
              value: _matchType, 
              decoration: const InputDecoration(
                labelText: 'Tipo de Partido',
                border: OutlineInputBorder(),
              ),
              onChanged: _onMatchTypeChanged, 
              items: <String>[
                'Todos',
                'Liga',
                'Copa',
                'Supercopa',
                'Playoffs',
                'Amistoso',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
