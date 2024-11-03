/*
 * Archivo: player_stats.dart
 * Descripción: Este archivo contiene la definición de la clase PlayerStat, 
 *              con información detallada sobre las estadísticas de cada jugador.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
class PlayerStats {
  final String nombre;
  final String posicion;
  final int dorsal;
  int goals;
  int assists;
  int yellowCards;
  int redCards;
  int shots;
  int shotsOnGoal;
  int foul;
  int saves;
  int shotsReceived;
  int goalsReceived;  

  PlayerStats({
    required this.nombre,
    required this.posicion,
    required this.dorsal,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.shots = 0,
    this.shotsOnGoal = 0,
    this.foul = 0,
    this.saves = 0,
    this.shotsReceived = 0,  
    this.goalsReceived = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'posicion': posicion,
      'dorsal': dorsal,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'shots': shots,
      'shotsOnGoal': shotsOnGoal,
      'foul': foul,
      'saves': saves,
      'shotsReceived': shotsReceived,
      'goalsReceived': goalsReceived,
    };
  }

  // Permite crear una instancia de PlayerStats a partir de un Map, permitiendo convertir los datos en un objeto Match
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      nombre: json['nombre'] ?? '',
      posicion: json['posicion'] ?? '',
      dorsal: json['dorsal'] ?? 0,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      yellowCards: json['yellowCards'] ?? 0,
      redCards: json['redCards'] ?? 0,
      shots: json['shots'] ?? 0,
      shotsOnGoal: json['shotsOnGoal'] ?? 0,
      foul: json['foul'] ?? 0,
      saves: json['saves'] ?? 0,
      shotsReceived: json['shotsReceived'] ?? 0,
      goalsReceived: json['goalsReceived'] ?? 0,
    );
  }
}
