import 'package:flutter/material.dart';

class TeamProvider with ChangeNotifier {
  String _selectedTeamName = '';

  String get selectedTeamName => _selectedTeamName;

  void setSelectedTeamName(String teamName) {
    _selectedTeamName = teamName;
    notifyListeners(); 
  }
}
