class PlayerStats {
  final String nombre;
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
  int percentSuccesfulTackle;
  int foul;
  int failedPasses;
  int failedDribbles;

  PlayerStats({
    required this.nombre,
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
    this.percentSuccesfulTackle = 0,
    this.foul = 0,
    this.failedPasses = 0,
    this.failedDribbles = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
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
      'percentSuccesfulTackle': percentSuccesfulTackle,
      'foul': foul,
      'failedPasses': failedPasses,
      'failedDribbles': failedDribbles,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      nombre: json['nombre'] ?? '',
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
      percentSuccesfulTackle: json['percentSuccesfulTackle'] ?? 0,
      foul: json['foul'] ?? 0,
      failedPasses: json['failedPasses'] ?? 0,
      failedDribbles: json['failedDribbles'] ?? 0,
    );
  }
}