import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart';
import 'package:CoachCraft/services/firebase_service.dart';
import 'package:flutter/material.dart';


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
    var data = await PlayerServices.loadPlayerData(widget.dorsal);
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

  // Función para modificar el jugador
  Future<void> _modifyPlayer() async {
    if (_formKey.currentState!.validate()) {
      int newDorsal = int.tryParse(_dorsalController.text) ?? 0;

      if (await PlayerValidations.isDorsalInUse(newDorsal, widget.dorsal)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este dorsal ya está en uso')),
        );
        return;
      }

      Map<String, dynamic> playerData = {
        'nombre': _nameController.text,
        'dorsal': newDorsal,
        'posicion': _positionController.text,
        'edad': int.tryParse(_ageController.text) ?? 0,
        'altura': double.tryParse(_heightController.text) ?? 0.0,
        'peso': double.tryParse(_weightController.text) ?? 0.0,
      };

      try {
        await PlayerServices.modifyPlayer(widget.dorsal, playerData);
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
