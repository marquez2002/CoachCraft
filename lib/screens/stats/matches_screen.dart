import 'package:CoachCraft/services/match/match_service.dart';
import 'package:CoachCraft/widgets/match/filter_section.dart';
import 'package:CoachCraft/widgets/match/match_form_widget.dart';
import 'package:CoachCraft/widgets/match/match_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final MatchService _matchService = MatchService();
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _filteredMatches = [];
  String _season = '2024';
  String _matchType = 'Todos';
  String _rival = '';
  DateTimeRange? _dateRange;

  // Controladores de expansión
  bool _isCreatingMatchExpanded = false;
  bool _isSearchingMatchExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    try {
      _matches = await _matchService.fetchMatches(context);
      setState(() {
        // Ordena los partidos por fecha (de más reciente a más antiguo)
        _matches.sort((a, b) {
          DateTime dateA = DateTime.parse(a['matchDate']);
          DateTime dateB = DateTime.parse(b['matchDate']);
          return dateB.compareTo(dateA);
        });
        _filteredMatches = List.from(_matches);  // Inicializa con todos los partidos
      });
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los partidos: $e')),
      );
    }
  }

  // Función para obtener el rango de fechas según la temporada
  DateTimeRange _getDateRangeForSeason(String season) {
    final startDate = DateTime(int.parse(season.split('-')[0]), 8, 1); // Inicio: 1 de agosto
    final endDate = DateTime(int.parse(season.split('-')[1]), 7, 31); // Fin: 31 de julio del siguiente año
    return DateTimeRange(start: startDate, end: endDate);
  }

  // Función de filtrado de partidos
  void _filterMatches(String matchType, String season, String rival, DateTimeRange? dateRange) {
    setState(() {
      // Si no hay un rango de fechas, lo calculamos con la temporada seleccionada
      final seasonDateRange = dateRange ?? _getDateRangeForSeason(season);

      _filteredMatches = _matches.where((match) {
        // Convierte la fecha del partido
        final matchDate = DateTime.parse(match['matchDate']);
        final matchYear = DateFormat('yyyy').format(matchDate);

        // Filtros
        final matchMatchesType = matchType == 'Todos' || match['matchType'] == matchType;
        final matchMatchesSeason = season == 'Todos' || (matchDate.isAfter(seasonDateRange.start) && matchDate.isBefore(seasonDateRange.end));
        final matchMatchesRival = rival.isEmpty || match['rivalTeam'].toLowerCase().contains(rival.toLowerCase());
        
        // Filtro de fechas (este ya está implícito con seasonDateRange)
        final matchMatchesDate = dateRange == null || (matchDate.isAfter(seasonDateRange.start) && matchDate.isBefore(seasonDateRange.end));

        // Devuelve true si el partido cumple con todos los filtros
        return matchMatchesType && matchMatchesSeason && matchMatchesRival && matchMatchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true, // Desaparece al hacer scroll hacia abajo
            snap: true, // Reaparece rápidamente al hacer scroll hacia arriba
            title: const Text('Resultados de Partidos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _isCreatingMatchExpanded = !_isCreatingMatchExpanded;
                    _isSearchingMatchExpanded = false; // Colapsa el filtro si expandes la creación
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () {
                  setState(() {
                    _isSearchingMatchExpanded = !_isSearchingMatchExpanded;
                    _isCreatingMatchExpanded = false; // Colapsa la creación si expandes el filtro
                  });
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Formulario para crear un nuevo partido
                      if (_isCreatingMatchExpanded) ...[
                        MatchForm(onMatchCreated: _fetchMatches), // Llama _fetchMatches después de la creación
                        const SizedBox(height: 8.0),
                      ],
                      // Formulario para buscar partidos
                      if (_isSearchingMatchExpanded) ...[
                        FilterSection(
                          season: _season,
                          onFilterChanged: (String season, String matchType, String rival, DateTimeRange? dateRange) {
                            setState(() {
                              _season = season;
                              _matchType = matchType;
                              _rival = rival;
                              _dateRange = dateRange; // Asigna el rango de fechas
                              _filterMatches(matchType, season, rival, dateRange); // Aplica los filtros
                            });
                          },
                        ),
                        const SizedBox(height: 8.0),
                      ],
                      // Lista de partidos filtrados
                      SizedBox(
                        height: MediaQuery.of(context).size.height, // Ajuste dinámico del tamaño
                        child: MatchList(filteredMatches: _filteredMatches),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
