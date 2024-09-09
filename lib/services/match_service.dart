import 'package:CoachCraft/models/player_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<dynamic>> fetchPlayerStats(String rival, String matchDate) async {
    List<dynamic> loadedPlayerStats = [];
    try {
      final matchSnapshot = await _firestore.collection('matches')
          .where('rivalTeam', isEqualTo: rival)
          .where('matchDate', isEqualTo: matchDate)
          .get();

      if (matchSnapshot.docs.isNotEmpty) {
        String matchId = matchSnapshot.docs.first.id;
        final playersSnapshot = await _firestore.collection('matches')
            .doc(matchId)
            .collection('players')
            .get();

        for (var playerDoc in playersSnapshot.docs) {
          var playerData = playerDoc.data();
          final statsSnapshot = await playerDoc.reference.collection('stadistics').get();
          for (var statDoc in statsSnapshot.docs) {
            var statData = statDoc.data();
            if (playerData['position'] == 'Portero') {
              loadedPlayerStats.add(GoalkeeperStats.fromJson(statData));
            } else {
              loadedPlayerStats.add(PlayerStats.fromJson(statData));
            }
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


  Future<String> createMatch(Map<String, dynamic> matchData) async {
    DocumentReference docRef = await _firestore.collection('matches').add(matchData);
    return docRef.id; // Retorna el ID del nuevo partido creado
  }

  Future<void> savePlayersForMatch(String matchId, List<Map<String, dynamic>> players) async {
    try {
      for (var player in players) {
        print('Nombre: ${player['name']}, Dorsal: ${player['dorsal']}');
      }

      for (var playerData in players) {
        // Asegúrate de que los datos del jugador no sean nulos
        if (playerData['name'] == null || playerData['dorsal'] == null) {
          throw Exception('El nombre o dorsal del jugador no pueden ser nulos');
        }

        // Agregar el jugador a la subcolección 'players'
        var playerRef = await FirebaseFirestore.instance
            .collection('matches')
            .doc(matchId)
            .collection('players')
            .add(playerData);

        // Crear estadísticas iniciales
        Map<String, dynamic> stadistics;
        if (playerData['position'] == 'portero') {
          var goalkeeperStats = GoalkeeperStats(
            nombre: playerData['name'],
            dorsal: playerData['dorsal'],
            posicion: playerData['posicion'],
          );
          stadistics = goalkeeperStats.toJson();
        } else {
          var playerStats = PlayerStats(
            nombre: playerData['name'],
            dorsal: playerData['dorsal'],
            posicion: playerData['posicion'],
          );
          stadistics = playerStats.toJson();
        }
        
        await playerRef.collection('stadistics').add(stadistics);
      }
    } catch (e) {
      print(e); // Imprimir el error para más información
      throw Exception('Error al guardar jugadores para el partido: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMatches() async {
    QuerySnapshot snapshot = await _firestore.collection('matches').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'data': doc.data() as Map<String, dynamic>,
    }).toList();
  }
  

  Future<void> updateMatchByDetails(Map<String, dynamic> updatedData) async {
    try {   
      // Asumiendo que deseas actualizar el primer partido que coincide con los detalles
      QuerySnapshot querySnapshot = await _firestore
          .collection('matches')
          .where('rivalTeam', isEqualTo: updatedData['rivalTeam'])
          .where('matchDate', isEqualTo: updatedData['matchDate'])
          .limit(1) // Limitar a un solo partido
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Actualiza el primer partido encontrado
        await _firestore.collection('matches').doc(querySnapshot.docs.first.id).update(updatedData);
      } else {
        throw Exception('No se encontró ningún partido con los datos proporcionados.');
      }
    } catch (e) {
      throw Exception('Error al actualizar el partido: $e');
    }
  }



  // Método para eliminar un partido basado en el nombre del rival y la fecha
  Future<void> deleteMatch(String rivalTeam, String matchDate) async {    
    final matches = await _firestore
      .collection('matches')
      .where('rivalTeam', isEqualTo: rivalTeam)
      .where('matchDate', isEqualTo: matchDate)
      .get();

    for (var match in matches.docs) {
      await match.reference.delete();
    }
  }
}

