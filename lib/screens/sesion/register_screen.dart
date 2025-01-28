/*
 * Archivo: home_screen.dart
 * Descripción: Este archivo contiene la definición de la clase HomeScreen, 
 *              que representa la pantalla principal de la aplicación CoachCraft.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/widgets/sesion/register_widget.dart';
import 'package:flutter/material.dart';

/// Clase principal que representa la pantalla de inicio de la aplicación.
class RegisterScreen extends StatelessWidget {
  /// Constructor de la clase HomeScreen.
  const RegisterScreen({super.key});

  /// Método que construye el widget principal de la pantalla.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la aplicación que aparecerá en el administrador de tareas.
      title: 'CoachCraft',

      // Definición del tema de la aplicación.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),

      // Definimos la pantalla principal de la aplicación.
      home: const Scaffold(
        body: RegisterWidget(),
      ),
    );
  }
}
