/*
 * Archivo: login_screen.dart
 * Descripción: Este archivo contiene la definición de la clase LoginScreen, 
 *              que representa la pantalla de inicio de sesión de la aplicación CoachCraft.
 * 
 * Autor: : Gonzalo Márquez de Torres
 * 
 * Dependencias: 
 * - login_widget.dart: Proporciona el widget que contiene el formulario y la lógica para el inicio de sesión.
 * 
 * Notas adicionales:
 * - Este archivo utiliza Material 3 para el diseño de la interfaz.
 */

import 'package:CoachCraft/widgets/sesion/login_widget.dart'; // Importa el widget de inicio de sesión.
import 'package:flutter/material.dart';

/// Clase que representa la pantalla de inicio de sesión de la aplicación.
class LoginScreen extends StatelessWidget {
  /// Constructor de la clase LoginScreen.
  const LoginScreen({super.key});

  /// Método que construye el widget principal de la pantalla de inicio de sesión.
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
        body: LoginWidget(),
      ),
    );
  }
}
