/*
 * Archivo: home_widget.dart
 * Descripción: Este archivo contiene la definición de la clase MainWidget, 
 *              que representa la pantalla principal de bienvenida de la aplicación CoachCraft.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/sesion/login_screen.dart';
import 'package:CoachCraft/screens/teams/teams_screen.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
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
            mainAxisAlignment: MainAxisAlignment.center, 
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
                  User? user = await _checkUserLoggedIn(); 
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
    return auth.currentUser; 
  }
}
