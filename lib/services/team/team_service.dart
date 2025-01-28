/*
 * Archivo: team_service.dart
 * Descripción: Este archivo contiene la definición de la clase teamService, que representa
 *              las funciones que necesitamos en el widget TeamsWidget.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
import 'package:CoachCraft/models/teams.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

// Clase de servicio para manejar operaciones relacionadas con equipos
class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  /// Cargar equipos del usuario desde Firestore
  Future<List<Teams>> loadUserTeams() async {    
    if (user == null) return [];

    try {
      // Obtiene todos los documentos de la colección 'teams'
      QuerySnapshot teamSnapshot = await _firestore.collection('teams').get();
      List<Teams> teams = []; 

      // Iterar sobre cada documento de equipo
      for (var teamDoc in teamSnapshot.docs) {
        List<dynamic> members = teamDoc['members'] ?? []; 

        // Verificar si el usuario es miembro del equipo
        bool userIsMember = members.any((member) {
          if (member is Map<String, dynamic> && member.containsKey('uid')) {
            return member['uid'] == user!.uid; 
          }
          return false;
        });

        // Si el usuario es miembro, obtener su rol
        if (userIsMember) {
          String userRole = members
              .firstWhere(
                (member) => member is Map<String, dynamic> && member['uid'] == user!.uid,
                orElse: () => {'role': 'No Role'}, 
              )['role'];

          // Añadir el equipo a la lista de equipos
          teams.add(Teams(
            id: teamDoc.id,
            name: teamDoc['name'], 
            role: userRole, 
            members: members.map((member) {
              if (member is Map<String, dynamic>) {
                return member['uid'] as String;
              }
              return '';
            }).toList(),
          ));
        }
      }
      return teams; 
    } catch (e) {
      print('Error al cargar equipos: $e'); 
      rethrow; 
    }
  }

  /// Agregar un nuevo equipo
  Future<void> addTeam(String teamName) async {
    final String? uid = user?.uid; 
    if (uid == null) throw Exception('Usuario no autenticado');

    // Verifica que el nombre del equipo no esté vacío
    if (teamName.isNotEmpty) {
      try {
        await _firestore.collection('teams').add({
          'name': teamName, 
          'members': [
            {
              'uid': uid, 
              'role': 'Entrenador',
            }
          ],
        });
      } catch (e) {        
        throw Exception('Error al agregar el equipo: $e');
      }
    }
  }

  /// Unirse a un equipo existente
  Future<void> joinTeam(String teamId, String role) async {
    final String? uid = user?.uid; 
    if (uid == null) throw Exception('Usuario no autenticado');

    try {
      // Obtiene el documento del equipo correspondiente al teamId
      DocumentSnapshot teamDoc = await _firestore.collection('teams').doc(teamId).get();
      if (!teamDoc.exists) throw Exception('Equipo no encontrado.');
      List<dynamic> members = teamDoc['members'] ?? []; 
      bool userIsMember = members.any((member) {
        if (member is Map<String, dynamic> && member.containsKey('uid')) {
          return member['uid'] == uid; 
        }
        return false;
      });

      // Lanza una excepción si el usuario ya es miembro del equipo
      if (userIsMember) {
        throw Exception('Ya eres miembro de este equipo.');
      } else {
        await _firestore.collection('teams').doc(teamId).update({
          'members': FieldValue.arrayUnion([
            {
              'uid': uid, 
              'role': role, 
            }
          ]),
        });
      }
    } catch (e) {
      throw Exception('Error al unirte al equipo: $e');
    }
  }

  // Copiar el código del equipo al portapapeles
  String generateTeamCode(String teamId, String role) {
    return '$teamId$role'; 
  }

  /// Funcion para salir de un equipo concreto
  Future<void> leaveTeam(String teamId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Verificar si hay un usuario autenticado
      if (currentUser == null) {
        throw Exception('No se ha encontrado un usuario autenticado.');
      }

      String userId = currentUser.uid;

      // Referencia al equipo en Firestore
      DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);

      // Obtener los datos del equipo
      DocumentSnapshot teamSnapshot = await teamRef.get();

      if (!teamSnapshot.exists) {
        throw Exception('El equipo no existe.');
      }

      Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
      List<dynamic> members = teamData['members'] ?? [];

      // Buscar el miembro correspondiente al usuario
      final memberToRemove = members.firstWhere(
        (member) => member['uid'] == userId,
        orElse: () => null, 
      );

      // Verificar si el usuario es miembro del equipo
      if (memberToRemove == null) {
        throw Exception('El usuario no es miembro de este equipo.');
      }

      // Eliminar al usuario de la lista de miembros
      await teamRef.update({
        'members': FieldValue.arrayRemove([memberToRemove])
      });

      // Volver a obtener el equipo actualizado
      DocumentSnapshot updatedTeamSnapshot = await teamRef.get();
      Map<String, dynamic> updatedTeamData = updatedTeamSnapshot.data() as Map<String, dynamic>;
      List<dynamic> updatedMembers = updatedTeamData['members'] ?? [];

      // Si después de salir, el equipo ya no tiene miembros, lo eliminamos
      if (updatedMembers.isEmpty) {
        await teamRef.delete();
        print('El equipo ha sido eliminado porque no quedan miembros.');
      } else {
        print('El usuario ha salido del equipo correctamente.');
      }
    } catch (e) {
      print('Error al salir del equipo: $e');
      rethrow;
    }
  }
}

