
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
