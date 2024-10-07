import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filtros de Partidos',
      home: ParentWidget(),
    );
  }
}

class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  String _season = '2024'; // Valor inicial para la temporada
  String _matchType = 'Todos'; // Valor inicial para el tipo de partido
  bool _isSearchingExpanded = false; // Para controlar la expansión de los filtros

  void _onFilterChanged(String season, String matchType) {
    setState(() {
      _season = season; // Actualizamos la temporada
      _matchType = matchType; // Actualizamos el tipo de partido
      fetchGeneralStats(_season, _matchType); // Aquí se llamaría a tu función de estadísticas
    });
  }

  void fetchGeneralStats(String season, String matchType) {
    // Lógica para obtener las estadísticas generales según la temporada y el tipo de partido
    print('Fetching stats for season: $season and match type: $matchType');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros de Partidos'),
        actions: [
          IconButton(
            icon: Icon(_isSearchingExpanded ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _isSearchingExpanded = !_isSearchingExpanded; // Alternar la expansión
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
                season: _season, // Pasas el valor de la temporada actual
                matchType: _matchType, // Pasas el valor de tipo de partido actual
                onFilterChanged: _onFilterChanged, // Callback para cambios en los filtros
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

class FilterSectionStats extends StatefulWidget {
  final String season; // Temporada actual
  final String matchType; // Tipo de partido actual
  final Function(String, String) onFilterChanged; // Callback para cambiar filtros

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

  @override
  void initState() {
    super.initState();
    // Inicializamos el estado con los valores del widget padre
    _season = widget.season;
    _matchType = widget.matchType;
  }

  @override
  void didUpdateWidget(FilterSectionStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizamos el estado cuando el widget padre cambia
    if (oldWidget.season != widget.season || oldWidget.matchType != widget.matchType) {
      setState(() {
        _season = widget.season;
        _matchType = widget.matchType;
      });
    }
  }

  void _onSeasonChanged(String? newSeason) {
    if (newSeason != null) {
      setState(() {
        _season = newSeason; // Actualizamos el estado de la temporada
        widget.onFilterChanged(_season, _matchType); // Aplicamos el filtro
      });
    }
  }

  void _onMatchTypeChanged(String? newMatchType) {
    if (newMatchType != null) {
      setState(() {
        _matchType = newMatchType; // Actualizamos el estado del tipo de partido
        widget.onFilterChanged(_season, _matchType); // Aplicamos el filtro
      });
    }
  }

@override
Widget build(BuildContext context) {
  return SingleChildScrollView(  // Envuelve todo en SingleChildScrollView para hacer scroll si es necesario
    child: Padding(
      padding: const EdgeInsets.all(16.0),  // Añade padding alrededor del contenido
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
            value: _season, // Usamos la variable local de temporada
            decoration: const InputDecoration(
              labelText: 'Temporada',
              border: OutlineInputBorder(),
            ),
            onChanged: _onSeasonChanged, // Usamos el método para manejar el cambio de temporada
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
            value: _matchType, // Usamos la variable local del tipo de partido
            decoration: const InputDecoration(
              labelText: 'Tipo de Partido',
              border: OutlineInputBorder(),
            ),
            onChanged: _onMatchTypeChanged, // Usamos el método para manejar el cambio de tipo de partido
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
