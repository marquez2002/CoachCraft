/*
 * Archivo: player_service.dart
 * Descripción: Este archivo contiene un servicio que permite realizar diferentes operaciones sobre
 *              la base de datos a nivel de jugadores, como añadir jugador, listar jugadores, etc.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 * Dependencias:
 * - cloud_firestore: Con el objetivo de realizar las operaciones en Firebase.
 * - provider: Para la gestión del estado del equipo seleccionado.
 */
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Inicializa una instancia de FirebaseFirestore
FirebaseFirestore db = FirebaseFirestore.instance;

  /// Función para obtener el teamId basado en el equipo seleccionado en el TeamProvider
  Future<String?> getTeamId(BuildContext context) async {
    try {
      // Accede al nombre del equipo seleccionado desde el TeamProvider
      String selectedTeam = Provider.of<TeamProvider>(context, listen: false).selectedTeamName;

      if (selectedTeam.isEmpty) {
        throw Exception('No hay equipo seleccionado');
      }

      // Busca en Firestore el documento cuyo nombre coincida con el equipo seleccionado
      QuerySnapshot teamSnapshot = await db
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

/// Función para obtener la lista de jugadores actuales de un equipo
Future<List<Map<String, dynamic>>> getCurrentPlayers(BuildContext context) async {
  try {
    String? teamId = await getTeamId(context); // Obtiene el ID del equipo

    // Obtiene la colección de jugadores del equipo actual
    QuerySnapshot snapshot = await db.collection('teams').doc(teamId).collection('players').get();

    // Mapea los documentos de los jugadores a una lista de mapas
    return snapshot.docs.map((doc) {
      return {
        'name': doc['nombre'],
        'dorsal': doc['dorsal'],
        'posicion': doc['posicion'],
      };
    }).toList();
  } catch (e) {
    throw Exception('Error al obtener jugadores: $e');
  }
}

/// Función para obtener todos los jugadores del equipo, ordenados por dorsal
Future<List<Map<String, dynamic>>> getPlayers(BuildContext context) async {
  try {
    List<Map<String, dynamic>> players = [];
    String? teamId = await getTeamId(context); // Obtiene el ID del equipo

    // Referencia a la colección de jugadores del equipo
    CollectionReference collectionReferencePlayers = db.collection('teams').doc(teamId).collection('players');

    // Obtener los documentos de los jugadores
    QuerySnapshot queryPlayers = await collectionReferencePlayers.get();

    // Agregar los jugadores a la lista
    for (var doc in queryPlayers.docs) {
      players.add(doc.data() as Map<String, dynamic>);
    }

    // Ordenar los jugadores por dorsal
    players.sort((a, b) {
      int dorsalA = int.tryParse(a['dorsal']?.toString() ?? '0') ?? 0;
      int dorsalB = int.tryParse(b['dorsal']?.toString() ?? '0') ?? 0;
      return dorsalA.compareTo(dorsalB);
    });

    return players;
  } catch (e) {
    throw Exception('Error al obtener jugadores: $e');
  }
}

/// Función para agregar un nuevo jugador a la colección
Future<void> addPlayer(BuildContext context, Map<String, dynamic> playerData) async {
  try {
    String? teamId = await getTeamId(context);
    if (teamId != null) {
      // Agregar el nuevo jugador a la colección de jugadores
      await db.collection('teams').doc(teamId).collection('players').add(playerData);
    } else {
      throw Exception('teamId no encontrado');
    }
  } catch (e) {
    throw Exception('Error al añadir jugador: $e');
  }
}

/// Verifica si el dorsal ya existe en la base de datos
Future<bool> isDorsalUnique(BuildContext context, int dorsal) async {
  String? teamId = await getTeamId(context);
  
  // Consulta para buscar jugadores con el mismo dorsal
  QuerySnapshot query = await db
      .collection('teams')
      .doc(teamId)
      .collection('players')
      .where('dorsal', isEqualTo: dorsal)
      .get();

  return query.docs.isEmpty;
}

  /// Función para eliminar un jugador basado en el dorsal
  Future<void> deletePlayerByDorsal(BuildContext context, int dorsal) async {
    try {
      String? teamId = await getTeamId(context);

      // Referencia a la colección de jugadores
      CollectionReference playersCollection = db.collection('teams').doc(teamId).collection('players');

      // Buscar al jugador con el dorsal especificado
      QuerySnapshot querySnapshot = await playersCollection.where('dorsal', isEqualTo: dorsal).get();

      // Verificar si se encontró algún jugador con ese dorsal
      if (querySnapshot.docs.isNotEmpty) {
        await playersCollection.doc(querySnapshot.docs.first.id).delete();
      }
    } catch (e) {
      print('Error al eliminar el jugador: $e');
    }
  }

 /// Clase que contiene servicios relacionados a los jugadores
 class PlayerServices {
   static Future<Map<String, dynamic>?> loadPlayerData(BuildContext context, int dorsal) async {
     String? teamId = await getTeamId(context);
     // Consulta para obtener datos del jugador basado en el dorsal
     QuerySnapshot querySnapshot = await db
         .collection('teams')
         .doc(teamId)
         .collection('players')
         .where('dorsal', isEqualTo: dorsal)
         .get();
     if (querySnapshot.docs.isNotEmpty) {
       return querySnapshot.docs.first.data() as Map<String, dynamic>;
     } else {
       return null;
     }
   }

  static Future<void> modifyPlayer(BuildContext context, int dorsal, Map<String, dynamic> playerData) async {
    String? teamId = await getTeamId(context);

    if (teamId == null) {
      throw Exception("ID de equipo no encontrado");
    }

    try {
      // Consulta para encontrar al jugador por dorsal
      QuerySnapshot querySnapshot = await db
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .where('dorsal', isEqualTo: dorsal)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;       

        // Actualizar el jugador con los nuevos datos
        await db
            .collection('teams')
            .doc(teamId)
            .collection('players')
            .doc(docId)
            .update(playerData);
      } else {
        print("Jugador con dorsal $dorsal no encontrado");
        throw Exception("Jugador con dorsal $dorsal no encontrado");
      }
    } catch (e) {
      print("Error al modificar jugador: $e");
      throw Exception('Error al modificar jugador: $e');
    }
  }
}

// Clase que contiene las validaciones para los datos de los jugadores
class PlayerValidations {
  // Lista de posiciones válidas
  static const List<String> validPositions = ['Portero', 'Ala', 'Pivot', 'Cierre'];

  // Valida el nombre del jugador
  static String? validateName(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Por favor ingrese un nombre';
    }
    return null;
  }

  // Valida el dorsal del jugador
  static String? validateDorsal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un dorsal';
    }
    int? dorsal = int.tryParse(value);
    if (dorsal == null || dorsal <= 0 || dorsal >=100) {
      return 'El dorsal debe ser un número entre 0 y 99.';
    }
    return null;
  }

  // Valida la posición del jugador
  static String? validatePosition(String? value) {
    if (value == null || !validPositions.contains(value)) {
      return 'Posición no válida. Debe ser: Portero, Ala, Pivot o Cierre';
    }
    return null;
  }

  // Valida la edad del jugador
  static String? validateAge(String? value) {
    int? age = int.tryParse(value ?? '');
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la edad';
    } else if (age == null || age <= 0 || age > 80) {
      return 'La edad debe estar entre 1 y 80';
    }
    return null;
  }

  // Valida la altura del jugador
  static String? validateHeight(String? value) {
    double? height = double.tryParse(value ?? '');
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la altura';
    } else if (height == null || height < 100 || height > 250) {
      return 'Altura no válida. Debe estar entre 100 y 250 cm';
    }
    return null;
  }

  // Valida el peso del jugador
  static String? validateWeight(String? value) {
    double? weight = double.tryParse(value ?? '');
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el peso';
    } else if (weight == null || weight < 30 || weight > 200) {
      return 'Peso no válido. Debe estar entre 30 y 200 kg';
    }
    return null;
  }

  // Verifica si el dorsal está en uso por otro jugador
  static Future<bool> isDorsalInUse(BuildContext context, int dorsal, int currentDorsal) async {
    String? teamId = await getTeamId(context);

    QuerySnapshot querySnapshot = await db
        .collection('teams')
        .doc(teamId)
        .collection('players')
        .where('dorsal', isEqualTo: dorsal)
        .get();

    // Verificar que el dorsal no esté en uso por otro jugador
    return querySnapshot.docs.isNotEmpty && querySnapshot.docs.first['dorsal'] != currentDorsal;
  }
}
