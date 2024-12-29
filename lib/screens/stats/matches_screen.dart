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
  // ignore: unused_field
  String _matchType = 'Todos';


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
        _matches.sort((a, b) {
          DateTime dateA = DateTime.parse(a['matchDate']);
          DateTime dateB = DateTime.parse(b['matchDate']);
          return dateB.compareTo(dateA);
        });
        _filteredMatches = List.from(_matches);
      });
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los partidos: $e')),
      );
    }
  }

  void _filterMatches(String matchType, String season, String rival) {
    setState(() {
      _filteredMatches = _matches.where((match) {
        final matchDate = DateTime.parse(match['matchDate']);
        final matchYear = DateFormat('yyyy').format(matchDate);
        final matchMatchesType = matchType == 'Todos' || match['matchType'] == matchType;
        final matchMatchesSeason = season == 'Todos' || matchYear == season;
        final matchMatchesRival = rival.isEmpty || match['rivalTeam'].toLowerCase().contains(rival.toLowerCase());
        return matchMatchesType && matchMatchesSeason && matchMatchesRival;
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
                        MatchForm(onMatchCreated: _fetchMatches),
                        const SizedBox(height: 8.0),
                      ],
                      // Formulario para buscar partidos
                      if (_isSearchingMatchExpanded) ...[
                        FilterSection(
                          season: _season,
                          onFilterChanged: (String season, String matchType, String rival) {
                            setState(() {
                              _season = season;
                              _matchType = matchType;
                              _filterMatches(matchType, season, rival);
                            });
                          },
                        ),
                        const SizedBox(height: 8.0),
                      ],
                      // Lista de Partidos Filtrados
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7, // Ajuste dinámico del tamaño
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
