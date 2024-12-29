/*
 * Archivo: match.dart
 * Descripción: Este archivo contiene la definición de la clase Match, 
 *              con información detallada.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
class Match {
  final String id;
  final String rivalTeam;
  final DateTime matchDate;
  final String result;
  final String location;
  final String matchType;

  Match({
    required this.id,
    required this.rivalTeam,
    required this.matchDate,
    required this.result,
    required this.location,
    required this.matchType,
  });
}
