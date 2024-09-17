/*
 * Archivo: menu_screen.dart
 * Descripción: Este archivo contiene la pantalla correspondiente al menu genérico de la aplicación.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:flutter/material.dart';
import '../../widgets/menu/menu_widget_futsal.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la screen
      title: 'CoachCraft Menu',

      theme: ThemeData(
        // Esquema de colores personalizado con un color de semilla negro
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),    
        // Usar Material3 para el diseño de la aplicación
        useMaterial3: true,
      ),

      home: const Scaffold(
        // El cuerpo de MenuScreen se encontrará en MenuWidget
        body: MenuWidgetFutsal(),
      ),
    );
  }
}
