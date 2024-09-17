/*
 * Archivo: player_service.dart
 * Descripción: Este archivo contiene un servicio que permite realizar diferentes operacioens sobre
 *              la base de datos a nivel de jugadores, como, por ejemplo, añadir jugador, listar 
 *              jugadores...
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 * Dependencias:
 * - cloud_firebase: con el objetivo de realizar las operaciones en firebase.
 */
import 'package:cloud_firestore/cloud_firestore.dart';

// Inicializa una instancia de FirebaseFirestore
FirebaseFirestore db = FirebaseFirestore.instance;

// Función para obtener el teamId basado en un criterio (por ejemplo, el primer equipo)
Future<String?> getTeamId() async {
  try {
    // Obtener el primer documento de la colección 'teams'
    QuerySnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').limit(1).get();
    
    if (teamSnapshot.docs.isNotEmpty) {
      // Retornar el ID del primer equipo encontrado
      return teamSnapshot.docs.first.id;
    } else {
      throw Exception('No se encontraron equipos'); 
    }
  } catch (e) {
    throw Exception('Error al obtener el teamId: $e'); 
  }
}

// Función para obtener la lista de jugadores actuales de un equipo
Future<List<Map<String, dynamic>>> getCurrentPlayers() async {
  try {
    String? teamId = await getTeamId(); // Obtiene el ID del equipo
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

// Función para obtener todos los jugadores del equipo
Future<List<Map<String, dynamic>>> getPlayers() async {
  List<Map<String, dynamic>> players = [];
  String? teamId = await getTeamId(); 

  // Referencia a la colección de jugadores del equipo
  CollectionReference collectionReferencePlayers = FirebaseFirestore.instance
      .collection('teams')
      .doc(teamId)
      .collection('players');

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
}

// Función para agregar un nuevo jugador a la colección
Future<void> addPlayer(Map<String, dynamic> playerData) async {
  try {
    // Obtener el teamId
    String? teamId = await getTeamId();
    if (teamId != null) {
      // Agregar el nuevo jugador a la colección de jugadores
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .add(playerData);
    } else {
      throw Exception('teamId no encontrado'); 
    }
  } catch (e) {
    throw Exception('Error al añadir jugador: $e');
  }
}

// Verifica si el dorsal ya existe en la base de datos
Future<bool> isDorsalUnique(int dorsal) async {
  String? teamId = await getTeamId(); 
  // Consulta para buscar jugadores con el mismo dorsal
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('teams') 
      .doc(teamId)
      .collection('players')
      .where('dorsal', isEqualTo: dorsal)
      .get();
  
  return query.docs.isEmpty;
}

// Función para eliminar un jugador basado en el dorsal
Future<void> deletePlayerByDorsal(int dorsal) async {
  try {
    String? teamId = await getTeamId(); 
    // Referencia a la colección de jugadores
    CollectionReference playersCollection = db.collection('teams').doc(teamId).collection('players');

    // Buscar al jugador con el dorsal especificado
    QuerySnapshot querySnapshot = await playersCollection.where('dorsal', isEqualTo: dorsal).get();

    // Verificar si se encontró algún jugador con ese dorsal
    if (querySnapshot.docs.isNotEmpty) {
      // Eliminar el primer jugador encontrado (asume que solo hay un jugador con ese dorsal)
      await playersCollection.doc(querySnapshot.docs.first.id).delete();
      print('Jugador con dorsal $dorsal eliminado exitosamente.');
    } else {
      print('No se encontró ningún jugador con dorsal $dorsal.'); 
    }
  } catch (e) {
    print('Error al eliminar el jugador: $e');
  }
}

// Clase que contiene servicios relacionados a los jugadores
class PlayerServices {
  // Carga Datos de Jugador  
  static Future<Map<String, dynamic>?> loadPlayerData(int dorsal) async {
    String? teamId = await getTeamId(); 
    // Consulta para obtener datos del jugador basado en el dorsal
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
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
  
  // Función para modificar el jugador
  static Future<void> modifyPlayer(int dorsal, Map<String, dynamic> playerData) async {
    String? teamId = await getTeamId(); 
    try {
      // Consulta para encontrar al jugador por dorsal
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .where('dorsal', isEqualTo: dorsal)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Obtener el ID del documento del jugador que se quiere modificar
        var docId = querySnapshot.docs.first.id;
        // Actualizar el jugador con los nuevos datos
        await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .collection('players')
            .doc(docId) 
            .update(playerData);
      } else {
        throw Exception("Jugador con dorsal $dorsal no encontrado"); 
      }
    } catch (e) {
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
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un nombre'; 
    }
    return null; // Retorna null si es válido
  }

  // Valida el dorsal del jugador
  static String? validateDorsal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un dorsal'; 
    }
    int? dorsal = int.tryParse(value); 
    if (dorsal == null || dorsal <= 0) {
      return 'El dorsal debe ser un número positivo';
    }
    return null; // Retorna null si es válido
  }

  // Valida la posición del jugador
  static String? validatePosition(String? value) {
    if (value == null || !validPositions.contains(value)) {
      return 'Posición no válida. Debe ser: Portero, Ala, Pivot o Cierre'; 
    }
    return null; // Retorna null si es válido
  }

  // Valida la edad del jugador
  static String? validateAge(String? value) {
    int? age = int.tryParse(value ?? ''); 
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la edad'; 
    } else if (age == null || age <= 0 || age > 70) {
      return 'La edad debe estar entre 1 y 70'; 
    }
    return null; // Retorna null si es válido
  }

  // Valida la altura del jugador
  static String? validateHeight(String? value) {
    double? height = double.tryParse(value ?? ''); 
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la altura'; 
    } else if (height == null || height < 100 || height > 250) {
      return 'Altura no válida. Debe estar entre 100 y 250 cm'; 
    }
    return null; // Retorna null si es válido
  }

  // Valida el peso del jugador
  static String? validateWeight(String? value) {
    double? weight = double.tryParse(value ?? ''); 
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el peso'; 
    } else if (weight == null || weight < 30 || weight > 150) {
      return 'Peso no válido. Debe estar entre 30 y 150 kg'; 
    }
    return null; // Retorna null si es válido
  }

  // Verifica si el dorsal está en uso por otro jugador
  static Future<bool> isDorsalInUse(int dorsal, int currentDorsal) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('teams') 
        .where('dorsal', isEqualTo: dorsal)
        .get();

    // Verificar que el dorsal no esté en uso por otro jugador
    return querySnapshot.docs.isNotEmpty && querySnapshot.docs.first['dorsal'] != currentDorsal;
  }
}
