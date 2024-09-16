/*
 * Archivo: main_widget.dart
 * Descripción: Este archivo contiene la definición de la clase MainWidget, 
 *              que representa la pantalla principal de bienvenida de la aplicación CoachCraft.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 * Dependencias: 
 * - login_screen.dart: Proporciona la pantalla de inicio de sesión (LoginScreen) 
 *   a la que se navega desde MainWidget.
 * - team_screen.dart: Pantalla a la que se navega si el usuario ya está autenticado.
 */
import 'package:CoachCraft/screens/sesion/login_screen.dart';
import 'package:CoachCraft/screens/teams/teams_screen.dart'; // Asegúrate de importar el TeamScreen
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'package:flutter/material.dart';

/// Clase que representa el widget principal de la pantalla de bienvenida.
class HomeWidget extends StatelessWidget {
  /// Constructor de la clase MainWidget.
  const HomeWidget({super.key});

  /// Método que construye el widget principal de la pantalla de bienvenida.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Se añade la imagen preseleccionada como fondo de pantalla.
        Image.asset(
          'assets/image/main_football.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        
        // Contenido principal centrado en la pantalla
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos verticalmente.
            children: [
              // Se añade el logo de la aplicación.
              Image.asset(
                'assets/image/coachcraft_logo.png', 
                width: 200, 
                height: 200,
              ),
              
              // Botón para acceder a la aplicación
              ElevatedButton(
                onPressed: () async {
                  User? user = await _checkUserLoggedIn(); // Verificamos el estado de autenticación
                  if (user != null) {
                    // Si el usuario está autenticado, navega a TeamScreen
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => const TeamsScreen()),
                    );
                  } else {
                    // Si el usuario no está autenticado, navega a LoginScreen
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                child: const Text('Acceder'), 
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Verifica si hay un usuario autenticado.
  Future<User?> _checkUserLoggedIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser; // Retorna el usuario actual, si existe
  }
}
