import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FootballListPlayer extends StatefulWidget {
  const FootballListPlayer({super.key});

  @override
  _FootballListPlayerState createState() => _FootballListPlayerState();
}

class _FootballListPlayerState extends State<FootballListPlayer> {
  final _formKey = GlobalKey<FormState>();

  // Player data controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dorsalController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();  
  
  @override
  void dispose() {
    // Dispose the controllers to prevent memory leaks
    _nameController.dispose();
    _dorsalController.dispose();
    _positionController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitPlayer() async {
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
        await addPlayer(playerData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jugador añadido correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir jugador: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Jugador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
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
                  onPressed: _submitPlayer,
                  child: const Text('Añadir Jugador'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


Future<void> addPlayer(Map<String, dynamic> playerData) async {
  try {
    await FirebaseFirestore.instance.collection('teams').doc('teamID') // Replace with actual teamID
      .collection('players').add(playerData);
  } catch (e) {
    throw Exception('Error adding player: $e');
  }
}
