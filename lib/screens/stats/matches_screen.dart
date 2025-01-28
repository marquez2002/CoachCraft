/*
 * Archivo: matches_screen.dart
 * Descripción: Este archivo contiene la pantalla de los partidos de un equipo
 * 
 * Autor: Gonzalo Márquez de Torres
 */
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
  String _season = 'Todos';
  // ignore: unused_field
  String _matchType = 'Todos';
  // ignore: unused_field
  String _rival = '';
  // ignore: unused_field
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
        final matchDate = DateTime.parse(match['matchDate']);
        // ignore: unused_local_variable
        final matchYear = DateFormat('yyyy').format(matchDate);

        final matchMatchesType = matchType == 'Todos' || match['matchType'] == matchType;
        final matchMatchesSeason = season == 'Todos' || (matchDate.isAfter(seasonDateRange.start) && matchDate.isBefore(seasonDateRange.end));
        final matchMatchesRival = rival.isEmpty || match['rivalTeam'].toLowerCase().contains(rival.toLowerCase());
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
            floating: true,
            snap: true, 
            title: const Text('Resultados de Partidos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _isCreatingMatchExpanded = !_isCreatingMatchExpanded;
                    _isSearchingMatchExpanded = false; 
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () {
                  setState(() {
                    _isSearchingMatchExpanded = !_isSearchingMatchExpanded;
                    _isCreatingMatchExpanded = false; 
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
                        MatchForm(onMatchCreated: _fetchMatches), 
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
                              _dateRange = dateRange; 
                              _filterMatches(matchType, season, rival, dateRange);
                            });
                          },
                        ),
                        const SizedBox(height: 8.0),
                      ],
                      // Lista de partidos filtrados
                      SizedBox(
                        height: MediaQuery.of(context).size.height, 
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