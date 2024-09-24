import 'package:flutter/material.dart';

class MatchProvider with ChangeNotifier {
  String _selectedMatchId = ''; 

  String get selectedMatchId => _selectedMatchId;

  void setSelectedMatchId(String matchId) { 
    _selectedMatchId = matchId;
    notifyListeners(); 
  }
}
