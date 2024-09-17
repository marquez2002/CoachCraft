/*
 * Archivo: menu_screen_futsal.dart
 * Descripción: Este archivo contiene la pantalla correspondiente al menu de futsal.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/widgets/menu/menu_widget_futsal.dart'; // Importa el widget del menú de futsal.
import 'package:flutter/material.dart'; // Importa el paquete Flutter para usar widgets y Material Design.

/// Clase que representa la pantalla del menú de Futsal.
class MenuScreenFutsal extends StatelessWidget {
  const MenuScreenFutsal({super.key}); // Constructor del widget, que permite pasar una clave.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Enunciamos el título de la aplicación
      title: 'CoachCraft',

      theme: ThemeData(
        // Define un esquema de colores basado en un color semilla
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),       
        // Habilita el uso de Material3 para el diseño de la aplicación
        useMaterial3: true,  
      ),

      home: const Scaffold(
        // El cuerpo de HomeScreen se encontrará en el widget MenuWidgetFutsal
        body: MenuWidgetFutsal(),
      ),
    );
  }
}
