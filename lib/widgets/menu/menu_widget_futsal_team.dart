/*
 * Archivo: menu_widget_futsal_team.dart
 * Descripción: Este archivo contiene la definición de la clase del menú del equipo de fútbol sala.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/team_management/team_add_player_screen.dart';
import 'package:CoachCraft/screens/team_management/team_data_team_screen.dart';
import 'package:CoachCraft/screens/team_management/team_list_player_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:flutter/material.dart';

class MenuWidgetFutsalTeam extends StatelessWidget {
  const MenuWidgetFutsalTeam({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Column to hold the buttons vertically
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: buttonData.map((data) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          width: screenSize.width * 0.7, 
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
                              padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.02, 
                              ),
                            ),
                            child: Text(
                              data['label'],
                              style: const TextStyle(
                                fontSize: 20, 
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
