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
    required this.id, 
    required this.name,
    required this.role,
    required this.members, 
  });
}
