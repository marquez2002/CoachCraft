import 'package:flutter/material.dart';

class FilterSection extends StatefulWidget {
  final String season;
  final Function(String, String, String) onFilterChanged;

  const FilterSection({Key? key, required this.season, required this.onFilterChanged}) : super(key: key);

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  String _matchType = 'Todos'; // Inicializar con el tipo de partido por defecto
  String _rival = '';
  bool _isExpanded = false; // Estado para controlar la expansión

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con el botón de expansión
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // Cambia el estado de expansión
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filtrar Partidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(_isExpanded ? Icons.expand_less : Icons.expand_more), // Ícono de expansión
            ],
          ),
        ),
        const SizedBox(height: 8.0),

        // Contenido del filtro que se expande o colapsa
        if (_isExpanded) ...[
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar por Rival',
              border: OutlineInputBorder(),
            ),
            onChanged: (String value) {
              setState(() {
                _rival = value;
                // Actualiza el filtrado cuando el campo de rival cambia
                widget.onFilterChanged(widget.season, _matchType, _rival);
              });
            },
          ),
          const SizedBox(height: 8.0),

          // Dropdown para seleccionar la temporada
          DropdownButtonFormField<String>(
            value: widget.season,
            decoration: const InputDecoration(
              labelText: 'Temporada',
              border: OutlineInputBorder(),
            ),
            onChanged: (String? newValue) {
              setState(() {
                widget.onFilterChanged(newValue!, _matchType, _rival);
              });
            },
            items: <String>['2024', '2023', '2022', 'Todos'].map<DropdownMenuItem<String>>((String value) {
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
              setState(() {
                _matchType = newValue!;
                // Actualiza el filtrado al cambiar el tipo de partido
                widget.onFilterChanged(widget.season, _matchType, _rival);
              });
            },
            items: <String>[
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
          const SizedBox(height: 16.0), // Espaciado adicional
        ],
      ],
    );
  }
}
