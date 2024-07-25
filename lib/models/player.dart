
class Player {
  final String id;
  final String name;
  final int dorsal;
  final String position;
  final double height;
  final double weight;
  final int age;

  Player({
    required this.id,
    required this.name,
    required this.dorsal,
    required this.position,
    required this.height,
    required this.weight,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dorsal': dorsal,
      'position': position,
      'height': height,
      'weight': weight,
      'age': age,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      dorsal: map['dorsal'] as int,
      position: map['position'] as String,
      height: map['height'] as double,
      weight: map['weight'] as double,
      age: map['age'] as int,
    );
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, dorsal: $dorsal, position: $position, height: $height, weight: $weight, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Player &&
        other.id == id &&
        other.name == name &&
        other.dorsal == dorsal &&
        other.position == position &&
        other.height == height &&
        other.weight == weight &&
        other.age == age;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        dorsal.hashCode ^
        position.hashCode ^
        height.hashCode ^
        weight.hashCode ^
        age.hashCode;
  }
}
