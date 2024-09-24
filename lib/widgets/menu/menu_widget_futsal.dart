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
  String _userRole = 'loading'; // Estado para el tipo de usuario
  User? _currentUser; // Estado para almacenar el usuario autenticado

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Método para obtener el tipo de usuario desde Firestore
  Future<void> _getUserData() async {
    try {
      // Obtener el usuario autenticado actual
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        // Obtener todos los equipos
        QuerySnapshot teamsSnapshot =
            await FirebaseFirestore.instance.collection('teams').get();

        // Buscar el rol del usuario en los miembros de los equipos
        for (var teamDoc in teamsSnapshot.docs) {
          List<dynamic> members = teamDoc['members'];
          for (var member in members) {
            if (member['uid'] == _currentUser!.uid) {
              setState(() {
                _userRole = member['role'] ?? 'Jugador'; 
              });
              return; 
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
                      children: buttonData.map((data) {
                        // Determina si el botón está habilitado para el rol actual
                        bool isEnabled = data['enabledFor'].contains(_userRole);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: FractionallySizedBox(
                            widthFactor: 0.4, // El botón ocupará el 40% del ancho disponible
                            child: ElevatedButton(
                              onPressed: isEnabled
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => data['route']),
                                      );
                                    }
                                  : null, // Deshabilita el botón si no está permitido
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white , 
                                padding: const EdgeInsets.symmetric(vertical: 15.0), // Ajusta el padding para controlar la altura del botón
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    data['label'],
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.black, // Texto gris si el botón está deshabilitado
                                    ),
                                  ),
                                  if (!isEnabled) // Muestra el candado solo si el botón está deshabilitado
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0), // Espacio entre el texto y el icono
                                      child: Icon(
                                        Icons.lock,
                                        color: Colors.black, // Color del icono de candado
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),

        ],
      ),
    );
  }
}