/*
 * Archivo: filter_section_stats.dart
 * Descripción: Este archivo contiene las distintas funciones para el filtro de estadísticas generales
 *              en función de distintos parámetros.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';

class FilterSectionStats extends StatefulWidget {
  final String season;
  final Function(String, String, DateTimeRange?) onFilterChanged;

  const FilterSectionStats({
    Key? key,
    required this.season,
    required this.onFilterChanged, required String matchType,
  }) : super(key: key);

  @override
  _FilterSectionStatsState createState() => _FilterSectionStatsState();
}

class _FilterSectionStatsState extends State<FilterSectionStats> {
  String _matchType = 'Todos'; 
  // ignore: unused_field
  String _rival = ''; 

  /// Mapa de temporadas a rangos de fechas.
  final Map<String, DateTimeRange> _seasonDateRanges = {
    '2025-26': DateTimeRange(
      start: DateTime(2025, 8, 1),
      end: DateTime(2026, 7, 31),
    ),
    '2024-25': DateTimeRange(
      start: DateTime(2024, 8, 1),
      end: DateTime(2025, 7, 31),
    ),
    '2023-24': DateTimeRange(
      start: DateTime(2023, 8, 1),
      end: DateTime(2024, 7, 31),
    ),
    '2022-23': DateTimeRange(
      start: DateTime(2022, 8, 1),
      end: DateTime(2023, 7, 31),
    ),
    'Todos': DateTimeRange(
      start: DateTime(2000, 1, 1),
      end: DateTime(2100, 12, 31),
    ),
  };

  /// Obtiene el rango de fechas para la temporada seleccionada.
  DateTimeRange? _getDateRangeForSeason(String season) {
    return _seasonDateRanges[season];
  }

  /// Notifica a través del callback los cambios en los filtros.
  void _notifyFilterChange() {
    widget.onFilterChanged(
      widget.season,
      _matchType,
      _getDateRangeForSeason(widget.season)
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar Partidos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // Dropdown para seleccionar la temporada
            DropdownButtonFormField<String>(
              value: widget.season, // Debe coincidir con las claves de _seasonDateRanges
              decoration: const InputDecoration(
                labelText: 'Temporada',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != widget.season) {
                  widget.onFilterChanged(
                    newValue,
                    _matchType,
                    _getDateRangeForSeason(newValue),
                  );
                }
              },
              items: _seasonDateRanges.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 8.0),

            // Dropdown para seleccionar el tipo de partido
            DropdownButtonFormField<String>(
              value: _matchType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Partido',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != _matchType) {
                  setState(() {
                    _matchType = newValue;
                  });
                  _notifyFilterChange();
                }
              },
              items: const [
                'Todos',
                'Liga',
                'Copa',
                'Supercopa',
                'Playoffs',
                'Amistoso',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
