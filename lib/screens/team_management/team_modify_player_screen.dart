/*
 * Archivo: team_modify_player_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente para modificar un jugador
 *              en Firebase.
 * 
 * Autor: Gonzalo Márquez de Torres
 */

import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart'; 
import 'package:CoachCraft/services/player/player_service.dart'; 
import 'package:flutter/material.dart'; 

// Widget principal que permite modificar la información de un jugador de fútbol.
class FootballModifyPlayer extends StatefulWidget {
  final int dorsal; 

  const FootballModifyPlayer({super.key, required this.dorsal});

  @override
  _FootballModifyPlayerState createState() => _FootballModifyPlayerState();
}

/// Estado del widget FootballModifyPlayer que maneja la lógica de la interfaz.
class _FootballModifyPlayerState extends State<FootballModifyPlayer> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dorsalController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayerData(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dorsalController.dispose();
    _positionController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Función para cargar los datos del jugador desde Firestore utilizando el dorsal
  Future<void> _loadPlayerData() async {
    var data = await PlayerServices.loadPlayerData(context, widget.dorsal); 
    if (data != null) {
      setState(() {
        _nameController.text = data['nombre'] ?? '';
        _dorsalController.text = data['dorsal']?.toString() ?? '';
        _positionController.text = data['posicion'] ?? '';
        _ageController.text = data['edad']?.toString() ?? '';
        _heightController.text = data['altura']?.toString() ?? '';
        _weightController.text = data['peso']?.toString() ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jugador no encontrado')),
      );
    }
  }

  /// Función para modificar la información del jugador
  Future<void> _modifyPlayer() async {
    if (_formKey.currentState!.validate()) {  
      int newDorsal = int.tryParse(_dorsalController.text) ?? 0;

      // Verifica si el dorsal ya está en uso
      bool isDorsalInUse = await PlayerValidations.isDorsalInUse(context, newDorsal, widget.dorsal);

      if (isDorsalInUse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este dorsal ya está en uso')),
        );
        return; 
      }

      // Crear un mapa con los datos actualizados del jugador
      Map<String, dynamic> playerData = {
        'nombre': _nameController.text.trim(),
        'dorsal': newDorsal,
        'posicion': _positionController.text.trim(),
        'edad': int.tryParse(_ageController.text) ?? 0,
        'altura': double.tryParse(_heightController.text) ?? 0.0,
        'peso': double.tryParse(_weightController.text) ?? 0.0,
      };

      try {
        // Llama al servicio para modificar el jugador en Firestore
        await PlayerServices.modifyPlayer(context, widget.dorsal, playerData);

        print("Jugador modificado correctamente"); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jugador modificado correctamente')),
        );

        Navigator.pop(context); 
        
      } catch (e, stackTrace) {    
        print("Stack trace: $stackTrace"); // Imprimir stack trace
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al modificar jugador: $e')),
        );
      }
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
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                // Campos del formulario para ingresar o modificar datos del jugador
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'), 
                  validator: (value) => PlayerValidations.validateName(value),
                ),
                TextFormField(
                  controller: _dorsalController,
                  decoration: const InputDecoration(labelText: 'Dorsal'), 
                  keyboardType: TextInputType.number, 
                  validator: (value) => PlayerValidations.validateDorsal(value), 
                ),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(labelText: 'Posición'), 
                  validator: (value) => PlayerValidations.validatePosition(value),
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Edad'), 
                  keyboardType: TextInputType.number, 
                  validator: (value) => PlayerValidations.validateAge(value), 
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Altura (cm)'), 
                  keyboardType: TextInputType.number, 
                  validator: (value) => PlayerValidations.validateHeight(value), 
                ),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'), 
                  keyboardType: TextInputType.number, 
                  validator: (value) => PlayerValidations.validateWeight(value), 
                ),
                const SizedBox(height: 20), 
                ElevatedButton(
                  onPressed: () async {
                    // Solo procede si el formulario es válido
                    if (_formKey.currentState!.validate()) {
                      await _modifyPlayer(); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreenFutsalTeam(), 
                        ),
                      );
                    } 
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
