
import 'package:cloud_firestore/cloud_firestore.dart';


FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getPlayers() async {
  List<Map<String, dynamic>> players = [];
  CollectionReference collectionReferencePlayers = FirebaseFirestore.instance.collection('team');
  QuerySnapshot queryPlayers = await collectionReferencePlayers.get();
  queryPlayers.docs.forEach((doc) {
    players.add(doc.data() as Map<String, dynamic>);
  });

  players.sort((a, b) {
    int dorsalA = int.tryParse(a['dorsal']?.toString() ?? '0') ?? 0;
    int dorsalB = int.tryParse(b['dorsal']?.toString() ?? '0') ?? 0;
    return dorsalA.compareTo(dorsalB);
  });

  return players;
}

// Función para añadir un jugador a Firestore
Future<void> addPlayer(Map<String, dynamic> playerData) async {
  try {
    await FirebaseFirestore.instance.collection('team').add(playerData);
  } catch (e) {
    throw Exception('Error al añadir jugador: $e');
  }
}

// Verifica si el dorsal ya existe en la base de datos
Future<bool> isDorsalUnique(int dorsal) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('team')
      .where('dorsal', isEqualTo: dorsal)
      .get();
  
  return query.docs.isEmpty;
}

class PlayerServices {
  // Carga Datos de Jugador
  static Future<Map<String, dynamic>?> loadPlayerData(int dorsal) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('team')
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
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('team')
          .where('dorsal', isEqualTo: dorsal)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('team')
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

class PlayerValidations {
  static const List<String> validPositions = ['Portero', 'Ala', 'Pivot', 'Cierre'];

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un nombre';
    }
    return null;
  }

  static String? validateDorsal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un dorsal';
    }
    int? dorsal = int.tryParse(value);
    if (dorsal == null || dorsal <= 0) {
      return 'El dorsal debe ser un número positivo';
    }
    return null;
  }

  static String? validatePosition(String? value) {
    if (value == null || !validPositions.contains(value)) {
      return 'Posición no válida. Debe ser: Portero, Ala, Pivot o Cierre';
    }
    return null;
  }

  static String? validateAge(String? value) {
    int? age = int.tryParse(value ?? '');
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la edad';
    } else if (age == null || age <= 0 || age > 70) {
      return 'La edad debe estar entre 1 y 70';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    double? height = double.tryParse(value ?? '');
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la altura';
    } else if (height == null || height < 100 || height > 250) {
      return 'Altura no válida. Debe estar entre 100 y 250 cm';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    double? weight = double.tryParse(value ?? '');
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el peso';
    } else if (weight == null || weight < 30 || weight > 150) {
      return 'Peso no válido. Debe estar entre 30 y 150 kg';
    }
    return null;
  }

  static Future<bool> isDorsalInUse(int dorsal, int currentDorsal) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('team')
        .where('dorsal', isEqualTo: dorsal)
        .get();

    // Verificar que el dorsal no esté en uso por otro jugador
    return querySnapshot.docs.isNotEmpty && querySnapshot.docs.first['dorsal'] != currentDorsal;
  }
}

