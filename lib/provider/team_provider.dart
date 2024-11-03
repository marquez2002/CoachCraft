/*
 * Archivo: match_provider.dart
 * Descripción: Este archivo contiene la definición de la clase TeamNameProvider 
 *              que permite conocer los datos del equipo que estamos visualizando.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 */
import 'package:flutter/material.dart';

class TeamProvider with ChangeNotifier {
  String _selectedTeamName = '';
  String get selectedTeamName => _selectedTeamName;

  /// Función que permite seleccionar el equipo del que queremos visualizar los datos relativos a este.
  void setSelectedTeamName(String teamName) {
    _selectedTeamName = teamName;
    notifyListeners(); 
  }
}
