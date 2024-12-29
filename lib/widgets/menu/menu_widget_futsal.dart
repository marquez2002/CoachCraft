/*
 * Archivo: menu_widget_futsal.dart
 * Descripción: Este archivo contiene la definición de la clase del menú de la aplicación.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/board/football_field_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart';
import 'package:CoachCraft/screens/stats/matches_screen.dart';
import 'package:CoachCraft/screens/stats/general_stats_screen.dart';
import 'package:CoachCraft/screens/teams/teams_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuWidgetFutsal extends StatefulWidget {
  const MenuWidgetFutsal({super.key});

  @override
  _MenuWidgetFutsalState createState() => _MenuWidgetFutsalState();
}

class _MenuWidgetFutsalState extends State<MenuWidgetFutsal> {
  String _userRole = 'loading'; 
  User? _currentUser; 

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  /// Función para obtener el tipo de usuario desde Firestore
  Future<void> _getUserData() async {
    try {
      // Obtener el usuario autenticado actual
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        // Obtener todos los equipos
        QuerySnapshot teamsSnapshot = await FirebaseFirestore.instance.collection('teams').get();

        // Buscar el rol del usuario en los miembros de los equipos
        for (var teamDoc in teamsSnapshot.docs) {
          List<dynamic> members = teamDoc['members'];

          for (var member in members) {
            // Si member es un mapa con 'uid' y 'role'
            if (member is Map<String, dynamic>) {
              if (member['uid'] == _currentUser!.uid) {
                setState(() {
                  _userRole = member['role'] ?? 'Jugador';
                });
                return;
              }
            } else if (member is String) {               
              if (member == _currentUser!.uid) {
                setState(() {
                  _userRole = 'Jugador';
                });
                return;
              }
            }
          }
        }

        // Si no se encuentra el rol, establecerlo por defecto
        setState(() {
          _userRole = 'Jugador';
        });
      } else {
        setState(() {
          _userRole = 'Jugador';
        });
      }
    } catch (e) {
      setState(() {
        _userRole = 'error';
      });
      print('Error al obtener el rol del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenSize = MediaQuery.of(context).size;

    // Lista de datos para los botones con las rutas determinadas que deben seguir
    List<Map<String, dynamic>> buttonData = [
      {
        'label': 'Gestor de Equipo',
        'route': const MenuScreenFutsalTeam(),
        'enabledFor': ['Entrenador']
      },
      {
        'label': 'Pizarra',
        'route': const FootballFieldScreen(),
        'enabledFor': ['Entrenador']
      },
      {
        'label': 'Partidos',
        'route': const MatchesScreen(),
        'enabledFor': ['Entrenador', 'Jugador']
      },
      {
        'label': 'Estadísticas',
        'route': const GeneralStatsScreen(),
        'enabledFor': ['Entrenador', 'Jugador']
      },
      {
        'label': 'Volver',
        'route': const TeamsScreen(),
        'enabledFor': ['Entrenador', 'Jugador']
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Se añade la imagen preseleccionada de fondo de pantalla
          Image.asset(
            'assets/image/football_menu2.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: _userRole == 'loading'
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: buttonData.map((data) {
                            // Determina si el botón está habilitado para el rol actual
                            bool isEnabled = data['enabledFor'].contains(_userRole);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: screenSize.width * 0.7, 
                                child: ElevatedButton(
                                  onPressed: isEnabled
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => data['route']),
                                          );
                                        }
                                      : null, 
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white, 
                                    disabledBackgroundColor: Colors.white, 
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenSize.height * 0.02, 
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data['label'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (!isEnabled) // Muestra el icono de candado si el botón está deshabilitado
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0), 
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.black, 
                                          ),
                                        ),
                                    ],
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
