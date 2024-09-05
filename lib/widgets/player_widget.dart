import 'package:flutter/material.dart';
import '../screens/football_modify_player_screen.dart';


// Función auxiliar para construir un TextFormField
Widget buildPlayerFormField(TextEditingController controller, String label, String errorMessage, {bool isNumber = false}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return errorMessage;
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
          ]);
        }).toList(),
      ),
    );
  }
}

