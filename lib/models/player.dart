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

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      nombre: map['nombre'] ?? 'Nombre no disponible',
      dorsal: int.tryParse(map['dorsal']?.toString() ?? '0') ?? 0,
      posicion: map['posicion'] ?? 'Posición no disponible',
      edad: int.tryParse(map['edad']?.toString() ?? '0') ?? 0,
      altura: double.tryParse(map['altura']?.toString() ?? '0.0') ?? 0.0,
      peso: double.tryParse(map['peso']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}
