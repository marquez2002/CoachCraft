import 'package:CoachCraft/screens/menu/menu_screen_futsal_team.dart';
import 'package:CoachCraft/services/player/player_service.dart';
import 'package:flutter/material.dart';
import '../../screens/team_management/team_modify_player_screen.dart';

// Campo de formulario reutilizable con validaciones personalizadas
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


class PlayerDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  const PlayerDataTable({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Dorsal')),
          DataColumn(label: Text('Posición')),
          DataColumn(label: Text('Edad')),
          DataColumn(label: Text('Altura')),
          DataColumn(label: Text('Peso')),
          DataColumn(label: Text('Modificar')),
          DataColumn(label: Text('Eliminar')),
        ],
        rows: players.map((player) {
          final dorsal = player['dorsal']; // Asegurarse de que el dorsal está presente
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
                      // Pasar el dorsal a la pantalla de modificación
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FootballModifyPlayer(
                            dorsal: dorsal, // Pasar el dorsal al widget FootballModifyPlayer
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
                                  Navigator.of(context).pop(false); // No eliminar
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // Confirmar eliminación
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete) {
                        // Llamar a la función para eliminar el jugador
                        await deletePlayerByDorsal(context, dorsal);

                        // Redirigir a MenuFutsalScreen tras eliminar el jugador
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuScreenFutsalTeam()), // Navegar a MenuFutsalScreen
                        );
                      }
                    } else {
                      // Mostrar SnackBar si no hay dorsal disponible
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

