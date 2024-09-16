/*
 * Archivo: home_screen.dart
 * Descripción: Este archivo contiene la definición de la clase TeamsScreen, 
 *              que visualiza los equipos asociados a un usuario.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 * Notas adicionales:
 * - Este archivo usa Material 3 para el diseño de la interfaz.
 */
import 'package:CoachCraft/widgets/menu/teams_widget.dart';
import 'package:flutter/material.dart';

// Clase que representa la pantalla de equipos en la aplicación
class TeamsScreen extends StatelessWidget {
  // Constructor de la clase TeamScreen
  const TeamsScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la pantalla
      title: 'CoachCraft Menu',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),    
        useMaterial3: true,
      ),

      home: const Scaffold(
        // El cuerpo de la pantalla será el widget TeamListWidget
        body: TeamListWidget(),
      ),
    );
  }
}
