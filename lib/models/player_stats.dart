// player_stats.dart

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
  int percentShots;
  int tackle;
  int succesfulTackle;
  int foul;
  int passes;
  int failedPasses;
  int dribbles;
  int failedDribbles;

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
    this.percentShots = 0,
    this.tackle = 0,
    this.succesfulTackle = 0,
    this.foul = 0,
    this.passes = 0,
    this.failedPasses = 0,
    this.dribbles = 0,
    this.failedDribbles = 0,
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
      'percentShots': percentShots,
      'tackle': tackle,
      'succesfulTackle': succesfulTackle,
      'foul': foul,
      'passes': passes,
      'failedPasses': failedPasses,
      'dribbles': dribbles,
      'failedDribbles': failedDribbles,
    };
  }

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
      percentShots: json['percentShots'] ?? 0,
      tackle: json['tackle'] ?? 0,
      succesfulTackle: json['succesfulTackle'] ?? 0,
      foul: json['foul'] ?? 0,
      passes: json['passes'] ?? 0,
      failedPasses: json['failedPasses'] ?? 0,
      dribbles: json['dribbles'] ?? 0,
      failedDribbles: json['failedDribbles'] ?? 0,
    );
  }
}

class GoalkeeperStats {
  final String nombre;
  final String posicion;
  final int dorsal;
  int goals;  
  int assists;
  int yellowCards;
  int redCards;
  int saves;
  int shotsReceived;  
  int percentSaves;
  int tackle;
  int succesfulTackle;
  int foul;
  int passes;
  int failedPasses;
  int dribbles;
  int failedDribbles;

  GoalkeeperStats({
    required this.nombre,
    required this.posicion,
    required this.dorsal,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.saves = 0,
    this.shotsReceived = 0,  
    this.percentSaves = 0,
    this.tackle = 0,
    this.succesfulTackle = 0,
    this.foul = 0,
    this.passes = 0,
    this.failedPasses = 0,
    this.dribbles = 0,
    this.failedDribbles = 0,
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
      'saves': saves,
      'shotsReceived': shotsReceived,
      'percentSaves': percentSaves,
      'tackle': tackle,
      'succesfulTackle': succesfulTackle,
      'foul': foul,
      'passes': passes,
      'failedPasses': failedPasses,
      'dribbles': dribbles,
      'failedDribbles': failedDribbles,
    };
  }

  factory GoalkeeperStats.fromJson(Map<String, dynamic> json) {
    return GoalkeeperStats(
      nombre: json['nombre'] ?? '',
      posicion: json['posicion'] ?? '',
      dorsal: json['dorsal'] ?? 0,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      yellowCards: json['yellowCards'] ?? 0,
      redCards: json['redCards'] ?? 0,
      saves: json['saves'] ?? 0,
      shotsReceived: json['shotsReceived'] ?? 0,
      percentSaves: json['percentSaves'] ?? 0,
      tackle: json['tackle'] ?? 0,
      succesfulTackle: json['succesfulTackle'] ?? 0,
      foul: json['foul'] ?? 0,
      passes: json['passes'] ?? 0,
      failedPasses: json['failedPasses'] ?? 0,
      dribbles: json['dribbles'] ?? 0,
      failedDribbles: json['failedDribbles'] ?? 0,
    );
  }
}
