/*
 * Archivo: teams.dart
 * Descripción: Este archivo contiene la definición de la clase teams.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
class Teams {
  final String id; // Identificador único del equipo
  final String name; // Nombre del equipo
  final String role; // Rol del usuario dentro del equipo (ej. 'Entrenador', 'Jugador')
  final List<String> members; // Lista de identificadores de miembros que pertenecen al equipo

  /// Constructor de la clase Teams.
  ///
  /// [id] - Identificador único del equipo.
  /// [name] - Nombre del equipo.
  /// [role] - Rol del usuario en el equipo.
  /// [members] - Lista de miembros del equipo.
  Teams({
    required this.id, // Inicializa el ID del equipo
    required this.name, // Inicializa el nombre del equipo
    required this.role, // Inicializa el rol del usuario en el equipo
    required this.members, // Inicializa la lista de miembros del equipo
  });
}
