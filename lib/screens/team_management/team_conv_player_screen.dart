/*
 * Archivo: team_conv_player_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente a la creación de la convocatoria del equipo.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Para imprimir y guardar PDFs
import 'package:CoachCraft/services/player/player_service.dart';

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

  // Función que genera un pdf con la lista de convocados.
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> selectedPlayersData) async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CONVOCATORIA',
                style: pw.TextStyle(fontSize: 24, font: fontBold),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Center(child: pw.Text('Dorsal', style: pw.TextStyle(font: fontBold))),
                      pw.Center(child: pw.Text('Nombre', style: pw.TextStyle(font: fontBold))),
                      pw.Center(child: pw.Text('Posición', style: pw.TextStyle(font: fontBold))),
                    ],
                  ),
                  ...selectedPlayersData.map((player) {
                    return pw.TableRow(
                      children: [
                        pw.Center(child: pw.Text(player['dorsal']?.toString() ?? 'No disponible', style: pw.TextStyle(font: fontRegular))),
                        pw.Center(child: pw.Text(player['nombre'] ?? 'No disponible', style: pw.TextStyle(font: fontRegular))),
                        pw.Center(child: pw.Text(player['posicion'] ?? 'No disponible', style: pw.TextStyle(font: fontRegular))),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Convocatoria'),
            floating: true,
            pinned: false, 
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getPlayers(context),
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
                      SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Seleccionar')),
                            DataColumn(label: Text('Dorsal')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Posición')),
                          ],
                          rows: players.map((player) {
                            String playerDorsal = player['dorsal']?.toString() ?? 'Dorsal no disponible';
                            String playerName = player['nombre'] ?? 'Nombre no disponible';
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
                              DataCell(Text(playerDorsal)),
                              DataCell(Text(playerName)),
                              DataCell(Text(playerPosition)),
                            ]);
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final selectedPlayersData = players.where((player) => selectedPlayers[player['nombre']] == true).toList();
                            if (selectedPlayersData.isNotEmpty) {
                              final pdfData = await generatePdf(selectedPlayersData);
                              
                              // Para imprimir o mostrar el PDF en móvil y web
                              await Printing.layoutPdf(
                                onLayout: (PdfPageFormat format) async => pdfData,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No players selected.')),
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
          ),
        ],
      ),
    );
  }
}
