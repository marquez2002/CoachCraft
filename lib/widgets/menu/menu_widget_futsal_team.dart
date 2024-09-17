import 'package:CoachCraft/screens/team_management/team_add_player_screen.dart';
import 'package:CoachCraft/screens/team_management/team_data_team_screen.dart';
import 'package:CoachCraft/screens/team_management/team_list_player_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:flutter/material.dart';

class MenuWidgetFutsalTeam extends StatelessWidget {
  const MenuWidgetFutsalTeam({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de datos para los botones con las rutas determinada que deben seguir
    List<Map<String, dynamic>> buttonData = [
      {'label': 'Añadir Jugador', 'route': FootballAddPlayer()},
      {'label': 'Datos Equipo', 'route': TeamDataScreen()},
      {'label': 'Listar Jugadores', 'route': FootballListPlayer()},
      {'label': 'Volver', 'route': const MenuScreenFutsal()},
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Se añade la imagen preseleccionada de fondo de pantalla
          Image.asset(
            'assets/image/football_menu.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Contenido de la pantalla principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttonData.map((data) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.4, // El botón ocupará el 40% del ancho disponible
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción al presionar el botón con navegación a la pantalla correspondiente
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => data['route']),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15.0), // Ajusta la altura del botón
                      ),
                      child: Text(
                        data['label'],
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
