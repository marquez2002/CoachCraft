/*
 * Archivo: menu_screen_futsal_team.dart
 * Descripción: Este archivo contiene la pantalla correspondiente al menu de un equipo concreto.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/widgets/menu/menu_widget_futsal_team.dart';
import 'package:flutter/material.dart';

class MenuScreenFutsalTeam extends StatelessWidget {
  const MenuScreenFutsalTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Enunciamos el título de la screen
      title: 'CoachCraft',

      theme: ThemeData(
        // Esquema de colores basado en un color principal
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),       
        // Usar Material3 para el diseño de la aplicación
        useMaterial3: true,  
      ),

      home: const Scaffold(
        // El cuerpo de HomeScreen se encontrará en MainWidget
        body: MenuWidgetFutsalTeam(),
      ),
    );
  }
}
