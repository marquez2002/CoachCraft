/*
 * Archivo: teams_widget.dart
 * Descripción: Este archivo contiene la definición de la clase teamsWidget, que representa
 *              la pantalla donde se encuentran los equipos del usuario.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
import 'package:CoachCraft/models/teams.dart'; 
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart'; 
import 'package:CoachCraft/screens/sesion/login_screen.dart'; 
import 'package:CoachCraft/services/team_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart'; 

// Widget principal que muestra la lista de equipos del usuario
class TeamListWidget extends StatefulWidget {
  const TeamListWidget({Key? key}) : super(key: key);

  @override
  _TeamListWidgetState createState() => _TeamListWidgetState();
}

// Estado del widget TeamListWidget
class _TeamListWidgetState extends State<TeamListWidget> {
  final TeamService _teamService = TeamService(); 
  List<Teams> userTeams = []; 
  final TextEditingController _teamNameController = TextEditingController(); 
  final TextEditingController _teamCodeController = TextEditingController(); 
  bool _isAddingTeam = false; 

  @override
  void initState() {
    super.initState();
    _loadUserTeams(); 
  }

  // Método para cargar equipos del usuario desde Firestore
  Future<void> _loadUserTeams() async {
    try {
      final teams = await _teamService.loadUserTeams(); 
      setState(() {
        userTeams = teams; 
      });
    } catch (e) {
      print('Error al cargar equipos: $e'); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar equipos: $e')), 
      );
    }
  }

  // Método para agregar un nuevo equipo
  Future<void> _addTeam() async {
    String teamName = _teamNameController.text.trim(); 

    if (teamName.isNotEmpty) {
      try {
        await _teamService.addTeam(teamName); 
        await _loadUserTeams(); 
        _teamNameController.clear();
        setState(() {
          _isAddingTeam = false; 
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el equipo: $e')), 
        );
      }
    }
  }

  // Método para unirse a un equipo existente
  Future<void> _joinTeam() async {
    String teamCode = _teamCodeController.text.trim(); 

    if (teamCode.isNotEmpty) {
      String teamId = teamCode.substring(0, teamCode.length - 1); 
      String role = teamCode.endsWith('0') ? 'Entrenador' : 'Jugador';

      try {
        await _teamService.joinTeam(teamId, role); 
        await _loadUserTeams(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te has unido al equipo exitosamente.')), 
        );
        _teamCodeController.clear(); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al unirte al equipo: $e')), 
        );
      }
    }
  }

  // Método para copiar el código del equipo al portapapeles
  Future<void> _copyToClipboard(String teamId, String role) async {
    String code = _teamService.generateTeamCode(teamId, role); 
    await Clipboard.setData(ClipboardData(text: code)); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código copiado al portapapeles')), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Equipos'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.add), 
            onPressed: () {
              setState(() {
                _isAddingTeam = !_isAddingTeam;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Formulario para agregar un nuevo equipo
          if (_isAddingTeam) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _teamNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Equipo', 
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_outlined),
                    onPressed: _addTeam, 
                  ),
                ],
              ),
            ),

            // Formulario para unirse a un equipo existente
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _teamCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código del Equipo', 
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search), 
                    onPressed: _joinTeam, 
                  ),
                ],
              ),
            ),
          ],

          // Lista de equipos del usuario
          Expanded(
            child: ListView.builder(
              itemCount: userTeams.length,
              itemBuilder: (context, index) {
                Teams team = userTeams[index]; 

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0), 
                    title: Row(
                      children: [
                        Text(team.name), 
                        const SizedBox(width: 2.0), 
                        Icon(
                          team.role == 'Entrenador' ? Icons.sports : Icons.sports_soccer_outlined, 
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text('Rol: ${team.role}'), 
                        Text('Número de miembros: ${team.members.length}'),                                             
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Row(
                              children: [
                                const Text('Código Entrenador: ******'), 
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    _copyToClipboard(team.id, '0'); 
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 20), 
                            Row(
                              children: [
                                const Text('Código Jugador: ******'), 
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    _copyToClipboard(team.id, '1'); 
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navegar al menú Futsal pasando el ID del equipo
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreenFutsal(), 
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
