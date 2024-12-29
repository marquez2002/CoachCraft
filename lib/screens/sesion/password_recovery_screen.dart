/*
 * Archivo: password_recovery_screen.dart
 * Descripción: Este archivo contiene la definición de la clase PasswordRecoveryScreen, 
 *              que representa la pantalla de información de recuperación de la contraseña.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 * Dependencias: 
 * - password_recovery_widget.dart: Proporciona el widget correspondiente a la pantalla de información de recuperación de contraseña.
 * 
 * Notas adicionales:
 * - Este archivo usa Material 3 para el diseño de la interfaz.
 */
import 'package:CoachCraft/widgets/sesion/password_recovery_widget.dart';
import 'package:flutter/material.dart';

/// Clase principal que representa la pantalla de información de recuperación de contraseña.
class PasswordRecoveryScreen extends StatelessWidget {
  /// Constructor de la clase PasswordRecoveryScreen.
  const PasswordRecoveryScreen({super.key});

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
        body: PasswordRecoveryWidget(),
      ),
    );
  }
}
