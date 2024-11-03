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

  // Permite crear una instancia de Player a partir de un Map, permitiendo convertir los datos en un objeto Match
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      nombre: json['nombre'] ?? '',
      dorsal: json['dorsal'] ?? 0,
      posicion: json['posicion'] ?? '',
      edad: json['edad'] ?? 0,
      altura: json['altura'] ?? 0.0,
      peso: json['peso'] ?? 0.0,
    );
  }
}
