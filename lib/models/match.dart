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

  factory Match.fromMap(Map<String, dynamic> data, String id) {
    return Match(
      id: id,
      rivalTeam: data['rivalTeam'],
      matchDate: DateTime.parse(data['matchDate']),
      result: data['result'],
      location: data['location'],
      matchType: data['matchType'],
    );
  }
}
