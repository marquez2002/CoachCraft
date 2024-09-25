import 'package:CoachCraft/models/teams.dart';
import 'package:CoachCraft/provider/team_provider.dart'; 
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';
import 'package:CoachCraft/screens/sesion/login_screen.dart'; 
import 'package:CoachCraft/services/team/team_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';

class TeamListWidget extends StatefulWidget {
  const TeamListWidget({Key? key}) : super(key: key);

  @override
  _TeamListWidgetState createState() => _TeamListWidgetState();
}

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

  Future<void> _copyToClipboard(String teamId, String role) async {
    String code = _teamService.generateTeamCode(teamId, role); 
    await Clipboard.setData(ClipboardData(text: code)); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código copiado al portapapeles')), 
    );
  }

  // Nueva función para salir del equipo
  Future<void> _leaveTeam(String teamId) async {
    try {
      await _teamService.leaveTeam(teamId); 
      await _loadUserTeams(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Has salido del equipo.')), 
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al salir del equipo: $e')), 
      );
    }
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
                        if (team.role == 'Entrenador') // Solo mostrar los botones si el rol es "Entrenador"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                            children: [
                              // Botón para copiar el código del entrenador
                              ElevatedButton.icon(
                                icon: const Icon(Icons.copy),
                                label: const Text('Código Entrenador'),
                                onPressed: () => _copyToClipboard(team.id, '0'),
                              ),
                              const SizedBox(width: 8.0),
                              // Botón para copiar el código del jugador
                              ElevatedButton.icon(
                                icon: const Icon(Icons.copy),
                                label: const Text('Código Jugador'),
                                onPressed: () => _copyToClipboard(team.id, '1'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirmar salida"),
                              content: const Text("¿Estás seguro que quieres salir del equipo?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text("Salir"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete) {
                          await _leaveTeam(team.id); // Salir del equipo
                        }
                      },
                    ),
                    onTap: () {
                      Provider.of<TeamProvider>(context, listen: false).setSelectedTeamName(team.name);
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
