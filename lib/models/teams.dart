/*
 * Archivo: teams.dart
 * Descripción: Este archivo contiene la definición de la clase Teams 
 *              con la información relativa a los equipos.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
class Teams {
  final String id; 
  final String name;
  final String role; 
  final List<String> members; 

  /// Constructor de la clase Teams.
  Teams({
    required this.id, // Inicializa el ID del equipo
    required this.name, // Inicializa el nombre del equipo
    required this.role, // Inicializa el rol del usuario en el equipo
    required this.members, // Inicializa la lista de miembros del equipo
  });
}
