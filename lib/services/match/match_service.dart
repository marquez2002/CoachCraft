import 'package:CoachCraft/models/player_stats.dart';
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getTeamId(BuildContext context) async {
    try {
      String selectedTeam = Provider.of<TeamProvider>(context, listen: false).selectedTeamName;

      if (selectedTeam.isEmpty) {
        throw Exception('No hay equipo seleccionado');
      }

      QuerySnapshot teamSnapshot = await _firestore
          .collection('teams')
          .where('name', isEqualTo: selectedTeam)
          .limit(1)
          .get();

      if (teamSnapshot.docs.isNotEmpty) {
        return teamSnapshot.docs.first.id;
      } else {
        throw Exception('No se encontró el equipo seleccionado');
      }
    } catch (e) {
      throw Exception('Error al obtener el teamId: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMatches(
    BuildContext context,
  ) async {
    List<Map<String, dynamic>> loadedMatches = [];
    try {
      String? teamId = await getTeamId(context);

      if (teamId == null) {
        throw Exception('No se pudo obtener el teamId');
      }

      final matchSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .get();

      for (var matchDoc in matchSnapshot.docs) {
        loadedMatches.add({
          'id': matchDoc.id,
          'matchDate': matchDoc['matchDate'],
          'matchType': matchDoc['matchType'],
          'rivalTeam': matchDoc['rivalTeam'],
          'data': matchDoc.data() as Map<String, dynamic>
        });
      }
    } catch (e) {
      print('Error al obtener partidos: $e');
    }
    return loadedMatches;
  }

  Future<String> createMatch(BuildContext context, Map<String, dynamic> matchData) async {
    String? teamId = await getTeamId(context);

    if (teamId == null) {
      throw Exception('No se pudo obtener el teamId para crear el partido');
    }

    DocumentReference docRef = await _firestore.collection('teams').doc(teamId).collection('matches').add(matchData);
    return docRef.id;
  }

  Future<void> savePlayersForMatch(BuildContext context, String matchId, List<Map<String, dynamic>> players) async {
    String? teamId = await getTeamId(context);

    if (teamId == null) {
      throw Exception('No se pudo obtener el teamId para guardar jugadores');
    }

    try {
      for (var playerData in players) {
        if (playerData['name'] == null || playerData['dorsal'] == null) {
          throw Exception('El nombre o dorsal del jugador no pueden ser nulos');
        }

        var playerStats = PlayerStats(
          nombre: playerData['name'],
          dorsal: playerData['dorsal'],
          posicion: playerData['posicion'],
          goals: 0,
          assists: 0,
          yellowCards: 0,
          redCards: 0,
          shots: 0,
          shotsOnGoal: 0,
          foul: 0,
        );

        await _firestore
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(matchId)
            .collection('players')
            .add(playerStats.toJson());
      }
    } catch (e) {
      print(e);
      throw Exception('Error al guardar jugadores para el partido: $e');
    }
  }

  Future<void> updateMatchByDetails(BuildContext context, Map<String, dynamic> updatedData) async {
    try {
      String? teamId = await getTeamId(context);

      if (teamId == null) {
        throw Exception('No se pudo obtener el teamId para actualizar el partido');
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .where('rivalTeam', isEqualTo: updatedData['rivalTeam'])
          .where('matchDate', isEqualTo: updatedData['matchDate'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference matchRef = _firestore
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(querySnapshot.docs.first.id);

        await matchRef.update(updatedData);
      } else {
        throw Exception('No se encontró ningún partido con los datos proporcionados.');
      }
    } catch (e) {
      throw Exception('Error al actualizar el partido: $e');
    }
  }

  Future<void> deleteMatch(BuildContext context, String rivalTeam, String matchDate) async {
    String? teamId = await getTeamId(context);

    if (teamId == null) {
      throw Exception('No se pudo obtener el teamId para eliminar el partido');
    }

    final matches = await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('matches')
        .where('rivalTeam', isEqualTo: rivalTeam)
        .where('matchDate', isEqualTo: matchDate)
        .get();

    for (var match in matches.docs) {
      var matchRef = match.reference;

      await _deletePlayers(matchRef);

      await matchRef.delete();
    }
  }

  Future<void> _deletePlayers(DocumentReference matchRef) async {
    var playersRef = matchRef.collection('players');
    var playersDocs = await playersRef.get();

    for (var playerDoc in playersDocs.docs) {
      await playerDoc.reference.delete();
    }
  }
}
