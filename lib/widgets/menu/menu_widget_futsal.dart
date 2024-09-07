import 'package:CoachCraft/screens/board/football_field_screen.dart';
import 'package:CoachCraft/screens/menu/home_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart';
import 'package:CoachCraft/screens/board/mid_football_field_screen.dart';
import 'package:flutter/material.dart';



class MenuWidgetFutsal extends StatelessWidget {
  const MenuWidgetFutsal({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de datos para los botones con las rutas determinada que deben seguir
    List<Map<String, dynamic>> buttonData = [
      {'label': 'Gestor de Equipo', 'route': const MenuScreenFutsalTeam()},
      {'label': 'Campo Completo', 'route': const FootballFieldScreen()},
      {'label': 'Media Pista', 'route': const MidFootballFieldScreen()},
      {'label': 'Volver', 'route': const HomeScreen()},
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Se añade la imagen preselecionada de fondo de pantalla
          Image.asset(
            'assets/image/football_menu2.png',
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
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción al presionar el botón con navegacion a la pantalla correspondiente
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => data['route']),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                      minimumSize: const Size(300, 50), // Tamaño del botón
                    ),
                    child: Text(
                      data['label'],
                      style: const TextStyle(
                        fontSize: 22,
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
