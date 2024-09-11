// /screens/football/football_add_player.dart
import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart';
import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/firebase_service.dart';
import '../../widgets/player/player_widget.dart';

class FootballAddPlayer extends StatefulWidget {
  const FootballAddPlayer({super.key});

  @override
  _FootballAddPlayerState createState() => _FootballAddPlayerState();
}

class _FootballAddPlayerState extends State<FootballAddPlayer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dorsalController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

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

  Future<void> _submitPlayer() async {
    if (_formKey.currentState!.validate()) {
      Player player = Player(
        nombre: _nameController.text,
        dorsal: int.tryParse(_dorsalController.text) ?? 0,
        posicion: _positionController.text,
        edad: int.tryParse(_ageController.text) ?? 0,
        altura: double.tryParse(_heightController.text) ?? 0.0,
        peso: double.tryParse(_weightController.text) ?? 0.0,
      );

      // Verificar si el dorsal es único
      bool isUnique = await isDorsalUnique(player.dorsal);
      if (!isUnique) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El dorsal ya está en uso')),
        );
        return;
      }

      try {
        await addPlayer(player.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jugador añadido correctamente')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MenuScreenFutsalTeam(),
          ),
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
                buildPlayerFormField(_nameController, 'Nombre', 'Por favor ingrese un nombre'),
                buildPlayerFormField(_dorsalController, 'Dorsal', 'Por favor ingrese un dorsal', isNumber: true),
                buildPlayerFormField(_positionController, 'Posición', 'Por favor ingrese la posición'),
                buildPlayerFormField(_ageController, 'Edad', 'Por favor ingrese la edad', isNumber: true),
                buildPlayerFormField(_heightController, 'Altura (cm)', 'Por favor ingrese la altura', isNumber: true),
                buildPlayerFormField(_weightController, 'Peso (kg)', 'Por favor ingrese el peso', isNumber: true),
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
