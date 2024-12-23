/*
 * Archivo: player.dart
 * Descripción: Este archivo contiene la definición de la clase Player, 
 *              con información detallada sobre los datos de cada jugador.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
class Player {
  final String nombre;
  final int dorsal;
  final String posicion;
  final int edad;
  final double altura;
  final double peso;

  Player({
    required this.nombre,
    required this.dorsal,
    required this.posicion,
    required this.edad,
    required this.altura,
    required this.peso,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dorsal': dorsal,
      'posicion': posicion,
      'edad': edad,
      'altura': altura,
      'peso': peso,
    };
  }
}
