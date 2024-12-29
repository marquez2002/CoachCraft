/*
 * Archivo: match_provider.dart
 * Descripción: Este archivo contiene la definición de la clase MatchProvider 
 *              que permite conocer el partido que estamos visualizando.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
import 'package:flutter/material.dart';

class MatchProvider with ChangeNotifier {
  String _selectedMatchId = ''; 
  String get selectedMatchId => _selectedMatchId;

  /// Función que permite seleccionar el partido del que queremos visualizar los datos relativos a este.
  void setSelectedMatchId(String matchId) { 
    _selectedMatchId = matchId;
    notifyListeners(); 
  }
}
