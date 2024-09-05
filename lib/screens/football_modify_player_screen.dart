import 'package:CoachCraft/screens/menu_screen_futsal_team.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FootballModifyPlayer extends StatefulWidget {
  final int dorsal; // Dorsal del jugador que se va a modificar

  const FootballModifyPlayer({super.key, required this.dorsal});

  @override
  _FootballModifyPlayerState createState() => _FootballModifyPlayerState();
}

class _FootballModifyPlayerState extends State<FootballModifyPlayer> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de datos del jugador
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dorsalController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayerData(); // Cargar los datos del jugador al inicio
  }

  @override
  void dispose() {
    // Liberar controladores
    _nameController.dispose();
    _dorsalController.dispose();
    _positionController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Función para cargar los datos del jugador desde Firestore en base al dorsal
  Future<void> _loadPlayerData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('team')
        .where('dorsal', isEqualTo: widget.dorsal) // Buscar por dorsal
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      _nameController.text = data['nombre'] ?? '';
      _dorsalController.text = data['dorsal']?.toString() ?? '';
      _positionController.text = data['posicion'] ?? '';
      _ageController.text = data['edad']?.toString() ?? '';
      _heightController.text = data['altura']?.toString() ?? '';
      _weightController.text = data['peso']?.toString() ?? '';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jugador no encontrado')),
      );
    }
  }

  // Función para modificar el jugador
  Future<void> _modifyPlayer() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> playerData = {
        'nombre': _nameController.text,
        'dorsal': int.tryParse(_dorsalController.text) ?? 0,
        'posicion': _positionController.text,
        'edad': int.tryParse(_ageController.text) ?? 0,
        'altura': double.tryParse(_heightController.text) ?? 0.0,
        'peso': double.tryParse(_weightController.text) ?? 0.0,
      };

      try {
        await modifyPlayer(widget.dorsal, playerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jugador modificado correctamente')),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al modificar jugador: $e')),
        );
      }
    }
  }

  // Función para modificar el jugador en Firestore en base al dorsal
  Future<void> modifyPlayer(int dorsal, Map<String, dynamic> playerData) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('team')
          .where('dorsal', isEqualTo: dorsal)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('team')
            .doc(docId) // Usar el ID del documento
            .update(playerData);
      } else {
        throw Exception("Jugador con dorsal $dorsal no encontrado");
      }
    } catch (e) {
      throw Exception('Error al modificar jugador: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Jugador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centramos el contenido verticalmente
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dorsalController,
                  decoration: const InputDecoration(labelText: 'Dorsal'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un dorsal';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(labelText: 'Posición'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la posición';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la edad';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Altura (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la altura';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el peso';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {                    
                    await _modifyPlayer();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuScreenFutsalTeam(), // La pantalla a la que quieres navegar
                      ),
                    );
                  },
                  child: const Text('Modificar Jugador'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
