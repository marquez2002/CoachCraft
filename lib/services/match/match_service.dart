import 'package:CoachCraft/models/player_stats.dart';
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para obtener el teamId basado en el equipo seleccionado en el TeamProvider
  Future<String?> getTeamId(BuildContext context) async {
    try {
      // Accede al nombre del equipo seleccionado desde el TeamProvider
      String selectedTeam = Provider.of<TeamProvider>(context, listen: false).selectedTeamName;

      if (selectedTeam.isEmpty) {
        throw Exception('No hay equipo seleccionado');
      }

      // Busca en Firestore el documento cuyo nombre coincida con el equipo seleccionado
      QuerySnapshot teamSnapshot = await _firestore
          .collection('teams')
          .where('name', isEqualTo: selectedTeam) // Filtra por el nombre del equipo seleccionado
          .limit(1)
          .get();

      if (teamSnapshot.docs.isNotEmpty) {
        // Retorna el ID del equipo seleccionado
        return teamSnapshot.docs.first.id;
      } else {
        throw Exception('No se encontró el equipo seleccionado');
      }
    } catch (e) {
      throw Exception('Error al obtener el teamId: $e');
    }
  }

  Future<List<dynamic>> fetchPlayerStats(BuildContext context, String rival, String matchDate) async {
    List<dynamic> loadedPlayerStats = [];
    try {
      String? teamId = await getTeamId(context); // Obtén el teamId

      if (teamId == null) {
        throw Exception('No se pudo obtener el teamId');
      }

      // Obtén los partidos de la colección correspondiente al equipo
      final matchSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .where('rivalTeam', isEqualTo: rival)
          .where('matchDate', isEqualTo: matchDate)
          .get();

      if (matchSnapshot.docs.isNotEmpty) {
        String matchId = matchSnapshot.docs.first.id;
        final playersSnapshot = await _firestore
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(matchId)
            .collection('players')
            .get();

        for (var playerDoc in playersSnapshot.docs) {
          final statsSnapshot = await playerDoc.reference.collection('stadistics').get();
          for (var statDoc in statsSnapshot.docs) {
            var statData = statDoc.data();
            loadedPlayerStats.add(PlayerStats.fromJson(statData));
          }
        }
      } else {
        print('No se encontró ningún partido con ese rival y fecha.');
      }
    } catch (e) {
      print('Error al obtener estadísticas de los jugadores: $e');
    }
    return loadedPlayerStats;
  }

  Future<String> createMatch(BuildContext context, Map<String, dynamic> matchData) async {
    String? teamId = await getTeamId(context); // Obtén el teamId

    if (teamId == null) {
      throw Exception('No se pudo obtener el teamId para crear el partido');
    }

    // Añadir el partido a la colección del equipo
    DocumentReference docRef = await _firestore.collection('teams').doc(teamId).collection('matches').add(matchData);
    return docRef.id; // Retorna el ID del nuevo partido creado
  }

  Future<void> savePlayersForMatch(BuildContext context, String matchId, List<Map<String, dynamic>> players) async {
    String? teamId = await getTeamId(context); // Obtén el teamId

    if (teamId == null) {
      throw Exception('No se pudo obtener el teamId para guardar jugadores');
    }

    try {
      for (var playerData in players) {
        // Asegúrate de que los datos del jugador no sean nulos
        if (playerData['name'] == null || playerData['dorsal'] == null) {
          throw Exception('El nombre o dorsal del jugador no pueden ser nulos');
        }

        // Agregar el jugador a la subcolección 'players'
        var playerRef = await _firestore
            .collection('teams')
            .doc(teamId)
            .collection('matches')
            .doc(matchId)
            .collection('players')
            .add(playerData);

        // Crear estadísticas iniciales usando solo PlayerStats
        var playerStats = PlayerStats(
          nombre: playerData['name'],
          dorsal: playerData['dorsal'],
          posicion: playerData['posicion'],
        );

        // Convertir a JSON
        Map<String, dynamic> stadistics = playerStats.toJson();
        
        // Guardar las estadísticas en la subcolección 'stadistics'
        await playerRef.collection('stadistics').add(stadistics);
      }
    } catch (e) {
      print(e);
      throw Exception('Error al guardar jugadores para el partido: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMatches(BuildContext context) async {
    String? teamId = await getTeamId(context); // Obtén el teamId

    if (teamId == null) {
      throw Exception('No se pudo obtener el teamId para fetchMatches');
    }

    QuerySnapshot snapshot = await _firestore.collection('teams').doc(teamId).collection('matches').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'data': doc.data() as Map<String, dynamic>,
    }).toList();
  }

  Future<void> updateMatchByDetails(BuildContext context, Map<String, dynamic> updatedData) async {
    try {
      String? teamId = await getTeamId(context); // Obtén el teamId

      if (teamId == null) {
        throw Exception('No se pudo obtener el teamId para actualizar el partido');
      }

      // Asumiendo que deseas actualizar el primer partido que coincide con los detalles
      QuerySnapshot querySnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('matches')
          .where('rivalTeam', isEqualTo: updatedData['rivalTeam'])
          .where('matchDate', isEqualTo: updatedData['matchDate'])
          .limit(1) // Limitar a un solo partido
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Actualiza el primer partido encontrado
        await _firestore.collection('teams').doc(teamId).collection('matches').doc(querySnapshot.docs.first.id).update(updatedData);
      } else {
        throw Exception('No se encontró ningún partido con los datos proporcionados.');
      }
    } catch (e) {
      throw Exception('Error al actualizar el partido: $e');
    }
  }

  Future<void> deleteMatch(BuildContext context, String rivalTeam, String matchDate) async {
    String? teamId = await getTeamId(context); // Obtén el teamId

    if (teamId == null) {
      throw Exception('No se pudo obtener el teamId para eliminar el partido');
    }

    // Buscar los partidos que coinciden con el equipo rival y la fecha del partido
    final matches = await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('matches')
        .where('rivalTeam', isEqualTo: rivalTeam)
        .where('matchDate', isEqualTo: matchDate)
        .get();

    // Recorrer todos los partidos encontrados
    for (var match in matches.docs) {
      // Obtener la referencia del partido
      var matchRef = match.reference;

      // Eliminar la subcolección de jugadores y sus estadísticas
      await _deletePlayersWithStatistics(matchRef);

      // Eliminar el documento del partido
      await matchRef.delete();
    }
  }

  // Método para eliminar la subcolección de jugadores y sus estadísticas
  Future<void> _deletePlayersWithStatistics(DocumentReference matchRef) async {
    var playersRef = matchRef.collection('players');
    var playersDocs = await playersRef.get();

    // Recorrer cada documento de la subcolección de jugadores
    for (var playerDoc in playersDocs.docs) {
      // Eliminar la subcolección de estadísticas del jugador
      var statisticsRef = playerDoc.reference.collection('stadistics');
      var statisticsDocs = await statisticsRef.get();

      for (var statDoc in statisticsDocs.docs) {
        await statDoc.reference.delete(); // Eliminar cada documento de estadísticas
      }

      await playerDoc.reference.delete(); // Eliminar el documento del jugador
    }
  }
}
