import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Importar la biblioteca printing
import '../services/firebase_service.dart';

class FootballConvPlayer extends StatefulWidget {
  const FootballConvPlayer({super.key});

  @override
    _FootballConvPlayerState createState() => _FootballConvPlayerState();
  }

class _FootballConvPlayerState extends State<FootballConvPlayer> {
  Map<String, bool> selectedPlayers = {}; // Para mantener el estado de selección

  @override
  void initState() {
    super.initState();
  }

  Future<void> generatePdf(List<Map<String, dynamic>> selectedPlayersData) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CONVOCATORIA',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder(
                top: pw.BorderSide.none, // Sin bordes visibles
              ),
              children: [
                // Títulos de las columnas
                pw.TableRow(
                  children: [
                    pw.Center(child: pw.Text('Nombre', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Center(child: pw.Text('Dorsal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Center(child: pw.Text('Posición', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                // Filas de datos
                ...selectedPlayersData.map((player) {
                  return pw.TableRow(
                    children: [
                      pw.Center(child: pw.Text(player['nombre'] ?? 'No disponible')),
                      pw.Center(child: pw.Text(player['dorsal']?.toString() ?? 'No disponible')),
                      pw.Center(child: pw.Text(player['posicion'] ?? 'No disponible')),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        );
      },
    ));

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Convocatoria'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No players found.'));
          } else {
            final players = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Seleccionar')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Dorsal')),
                          DataColumn(label: Text('Posición')),
                        ],
                        rows: players.map((player) {
                          String playerName = player['nombre'] ?? 'Nombre no disponible';
                          String playerDorsal = player['dorsal']?.toString() ?? 'Dorsal no disponible';
                          String playerPosition = player['posicion'] ?? 'Posición no disponible';
                          
                          bool isSelected = selectedPlayers[player['nombre']] ?? false;

                          return DataRow(cells: [
                            DataCell(
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedPlayers[player['nombre']] = value ?? false;
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(playerName)),
                            DataCell(Text(playerDorsal)),
                            DataCell(Text(playerPosition)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedPlayersData = players.where((player) {
                        return selectedPlayers[player['nombre']] == true;
                      }).toList();

                      if (selectedPlayersData.isNotEmpty) {
                        generatePdf(selectedPlayersData);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No players selected.')),
                        );
                      }
                    },
                    child: Text('Generar PDF'),
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
