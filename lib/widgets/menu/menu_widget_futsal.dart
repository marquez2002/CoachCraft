
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:CoachCraft/screens/board/football_field_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart';
import 'package:CoachCraft/screens/stats/matches_screen.dart';
import 'package:CoachCraft/screens/stats/general_stats_screen.dart';
import 'package:CoachCraft/screens/teams/teams_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    _resetUserData(); // Limpia y reinicia los datos cada vez que se inicia el widget
    _getUserData(); // Obtén los datos del usuario
  }

  /// Método para obtener el rol del usuario utilizando el nombre del equipo desde el Provider
  Future<void> _getUserData() async {
    try {
      // Obtener el usuario autenticado actual
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        print('Usuario autenticado: ${_currentUser!.uid}');

        // Obtener el nombre del equipo seleccionado desde el Provider
        final teamProvider = Provider.of<TeamProvider>(context, listen: false);
        String teamName = teamProvider.selectedTeamName;

        if (teamName.isEmpty) {
          print('No se ha seleccionado un equipo.');
          setState(() {
            _userRole = 'Jugador'; // Rol por defecto
          });
          return;
        }

        print('Equipo seleccionado: $teamName');

        // Buscar el equipo en Firestore utilizando el nombre
        QuerySnapshot teamQuery = await FirebaseFirestore.instance
            .collection('teams')
            .where('name', isEqualTo: teamName)
            .get();

        if (teamQuery.docs.isEmpty) {
          print('No se encontró ningún equipo con el nombre: $teamName');
          setState(() {
            _userRole = 'Jugador'; // Rol por defecto si no se encuentra el equipo
          });
          return;
        }

        // Asumimos que el nombre del equipo es único y tomamos el primer resultado
        DocumentSnapshot teamDoc = teamQuery.docs.first;

        // Obtener los miembros del equipo
        List<dynamic> members = teamDoc['members'];
        print('Miembros del equipo ${teamDoc.id}: $members');

        String userRole = 'Jugador'; // Valor por defecto

        for (var member in members) {
          if (member is Map<String, dynamic> && member['uid'] == _currentUser!.uid) {
            print('Rol encontrado para el usuario ${_currentUser!.uid}: ${member['role']}');
            userRole = member['role'] ?? 'Jugador';
            break;
          } else if (member is String && member == _currentUser!.uid) {
            print('Usuario ${_currentUser!.uid} encontrado sin rol explícito, asignando "Jugador"');
            userRole = 'Jugador';
            break;
          }
        }

        print('Rol final asignado al usuario: $userRole');

        setState(() {
          _userRole = userRole;
        });
      } else {
        print('No hay usuario autenticado.');
        setState(() {
          _userRole = 'Jugador'; // Rol por defecto si no hay usuario autenticado
        });
      }
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
      setState(() {
        _userRole = 'error';
      });
    }
  }

  void _resetUserData() {
    setState(() {
      _userRole = 'loading';
      _currentUser = null;
    });
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
                        // Column to hold the buttons vertically
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: buttonData.map((data) {
                            // Determina si el botón está habilitado para el rol actual
                            bool isEnabled = data['enabledFor'].contains(_userRole);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: screenSize.width * 0.7, // Ancho del botón (70% del ancho de pantalla)
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
                                    foregroundColor: isEnabled ? Colors.black : Colors.grey,
                                    backgroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.white, // Fondo al estar deshabilitado
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenSize.height * 0.02, // Ajustar el padding vertical
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data['label'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: isEnabled ? Colors.black : Colors.grey, // Color dinámico
                                        ),
                                      ),
                                      if (!isEnabled) // Mostrar candado si está deshabilitado
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0), // Espaciado entre texto e icono
                                          child: Icon(
                                            Icons.lock, // Icono de candado
                                            color: Colors.black, // Color del candado
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