/*
 * Archivo: player_service.dart
 * Descripción: Este archivo contiene un servicio que permite realizar diferentes operaciones sobre
 *              la base de datos a nivel de jugadores, como añadir jugador, listar jugadores, etc.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart';
import 'package:CoachCraft/screens/team_management/team_conv_player_screen.dart';
import 'package:CoachCraft/services/player/player_service.dart';
import 'package:flutter/material.dart';
import '../../screens/team_management/team_modify_player_screen.dart';

/// Campo de formulario reutilizable con validaciones personalizadas
Widget buildPlayerFormField(
  TextEditingController controller,
  String label,
  String validationMessage, {
  bool isNumber = false,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(labelText: label),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return validationMessage;
      }

      // Validación de dorsal
      if (label == 'Dorsal') {
        int? dorsal = int.tryParse(value);
        if (dorsal == null) {
          return 'Dorsal debe ser un número';
        }
      }

      // Validación de posición
      if (label == 'Posición') {
        const allowedPositions = ['Portero', 'Ala', 'Pívot', 'Cierre'];
        if (!allowedPositions.contains(value)) {
          return 'Posición no válida. Elige Portero, Ala, Pívot o Cierre';
        }
      }

      // Validación de edad
      if (label == 'Edad') {
        int? age = int.tryParse(value);
        if (age == null || age <= 0 || age > 70) {
          return 'Edad debe estar entre 1 y 70 años';
        }
      }

      // Validación de peso
      if (label == 'Peso (kg)') {
        double? weight = double.tryParse(value);
        if (weight == null || weight < 30 || weight > 150) {
          return 'Peso debe estar entre 30 kg y 150 kg';
        }
      }

      return null;
    },
  );
}

/// Clase correspondiente a los datos del jugador
class PlayerDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  const PlayerDataTable({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      child: DataTable(
        // ignore: deprecated_member_use
        dataRowHeight: 40, 
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Dorsal')),
          DataColumn(label: Text('Posición')),
          DataColumn(label: Text('Edad')),
          DataColumn(label: Text('Altura')),
          DataColumn(label: Text('Peso')),
          DataColumn(label: Text(' ')),
          DataColumn(label: Text(' ')),
        ],
        rows: players.map((player) {
          final dorsal = player['dorsal'];
          return DataRow(cells: [
            DataCell(Text(player['nombre'] ?? 'Nombre no disponible')),
            DataCell(Text(player['dorsal']?.toString() ?? 'Dorsal no disponible')),
            DataCell(Text(player['posicion'] ?? 'Posición no disponible')),
            DataCell(Text(player['edad']?.toString() ?? 'Edad no disponible')),
            DataCell(Text(player['altura']?.toString() ?? 'Altura no disponible')),
            DataCell(Text(player['peso']?.toString() ?? 'Peso no disponible')),
            DataCell(
              Center(
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    if (dorsal != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FootballModifyPlayer(
                            dorsal: dorsal,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dorsal del jugador no disponible'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            DataCell(
              Center(
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (dorsal != null) {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás seguro de que deseas eliminar este jugador?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete) {
                        await deletePlayerByDorsal(context, dorsal);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuScreenFutsalTeam()),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dorsal del jugador no disponible'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

class FootballListPlayer extends StatefulWidget {
  const FootballListPlayer({super.key});

  @override
  _FootballListPlayerState createState() => _FootballListPlayerState();
}

class _FootballListPlayerState extends State<FootballListPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jugadores'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getPlayers(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Jugador No Encontrado.'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView( 
                    child: PlayerDataTable(players: snapshot.data!), 
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity, 
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FootballConvPlayer()),
                        );
                      },
                      child: const Text('Convocatoria'),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
