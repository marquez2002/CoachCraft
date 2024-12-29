/*
 * Archivo: team_add_player_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente con añadir un jugador
 *              a firebase.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/models/player.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart'; 
import 'package:CoachCraft/services/player/player_service.dart';
import 'package:CoachCraft/widgets/player/player_widget.dart'; 
import 'package:flutter/material.dart'; 

// Clase principal para añadir un jugador
class FootballAddPlayer extends StatefulWidget {
  const FootballAddPlayer({super.key}); 

  @override
  _FootballAddPlayerState createState() => _FootballAddPlayerState(); 
}

class _FootballAddPlayerState extends State<FootballAddPlayer> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto para cada campo del formulario
  final TextEditingController _nameController = TextEditingController(); 
  final TextEditingController _dorsalController = TextEditingController(); 
  final TextEditingController _positionController = TextEditingController(); 
  final TextEditingController _ageController = TextEditingController(); 
  final TextEditingController _heightController = TextEditingController(); 
  final TextEditingController _weightController = TextEditingController(); 

  // Método que se llama al eliminar el estado
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

  // Función correspondiente para enviar el formulario y añadir un jugador
  Future<void> _submitPlayer() async {
    if (_formKey.currentState!.validate()) {
      
      // Crear una instancia del jugador con los datos del formulario
      Player player = Player(
        nombre: _nameController.text,
        dorsal: int.tryParse(_dorsalController.text) ?? 0, 
        posicion: _positionController.text,
        edad: int.tryParse(_ageController.text) ?? 0, 
        altura: double.tryParse(_heightController.text) ?? 0.0,
        peso: double.tryParse(_weightController.text) ?? 0.0, 
      );

      // Verificar si el dorsal es único
      bool isUnique = await isDorsalUnique(context, player.dorsal);
      if (!isUnique) {
        // En caso de que ya este en uso, muestra un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El dorsal ya está en uso')),
        );
        return; 
      }

      try {
        // Añadir el jugador a la base de datos
        await addPlayer(context, player.toJson());
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
        // Muestra un mensaje de error si falla la operación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir jugador: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: const Text('Añadir Jugador'),
            floating: true,
            pinned: false,           
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campos a rellenar para los datos del equipo
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
        ],
      ),
    );
  }
}
