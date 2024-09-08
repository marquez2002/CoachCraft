import 'package:CoachCraft/services/match_service.dart';
import 'package:CoachCraft/widgets/match/filter_section.dart';
import 'package:CoachCraft/widgets/match/match_form.dart';
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
  String _matchType = 'Todos'; // Agregar tipo de partido

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    _matches = await _matchService.fetchMatches();
    setState(() {
      // Ordenar los partidos por fecha (más recientes primero)
      _matches.sort((a, b) {
        DateTime dateA = DateTime.parse(a['data']['matchDate']);
        DateTime dateB = DateTime.parse(b['data']['matchDate']);
        return dateB.compareTo(dateA);
      });
      _filteredMatches = List.from(_matches); // Inicializar la lista filtrada
    });
  }

  void _filterMatches(String matchType, String season, String rival) {
    setState(() {
      _filteredMatches = _matches.where((match) {
        final matchData = match['data'];
        final matchDate = DateTime.parse(matchData['matchDate']);
        final matchYear = DateFormat('yyyy').format(matchDate);
        
        // Lógica de filtrado
        final matchMatchesType = matchType == 'Todos' || matchData['matchType'] == matchType;
        final matchMatchesSeason = season == 'Todos' || matchYear == season;
        final matchMatchesRival = rival.isEmpty || matchData['rivalTeam'].toLowerCase().contains(rival.toLowerCase());

        return matchMatchesType && matchMatchesSeason && matchMatchesRival;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de Partidos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MatchForm(onMatchCreated: _fetchMatches),
            const SizedBox(height: 16.0),
            FilterSection(
              season: _season,
              onFilterChanged: (String season, String matchType, String rival) {
                _season = season; // Actualizar la temporada seleccionada
                _matchType = matchType; // Actualizar el tipo de partido
                _filterMatches(matchType, season, rival);
              },
            ),
            const SizedBox(height: 16.0),
            MatchList(filteredMatches: _filteredMatches),
          ],
        ),
      ),
    );
  }
}
