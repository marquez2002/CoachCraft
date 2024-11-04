/*
 * Archivo: password_recovery_widget.dart
 * Descripción: Este archivo contiene la definición del widget de recuperación de contraseña 
 *              que permite a los usuarios contactar a soporte o redirigirse a redes sociales 
 *              para solicitar asistencia. Además, incluye la opción de navegación a la pantalla
 *              de inicio de sesión.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/sesion/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart'; 

/// Widget principal que representa la pantalla de recuperación de contraseña.
class PasswordRecoveryWidget extends StatelessWidget {
  const PasswordRecoveryWidget({super.key});

  /// Función para abrir una URL en el navegador externo
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir $url'; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/image/football_menu6.png', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Contenido centrado en el medio de la pantalla
          Center(
            child: Container(
              width: 400, 
              padding: const EdgeInsets.all(20.0), 
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), 
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              
              // Contenido principal
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Información para la recuperación de la cuenta
                  const Text(
                    'Para recuperar tu contraseña, ponte en contacto a través de correo:',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10), 

                  const Text(
                    'soporte@coachcraft.com',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue, 
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), 

                  const Text(
                    'O contáctanos a través de:',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10), 

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enlace a Instagram
                      GestureDetector(
                        onTap: () {
                          _launchURL('https://www.instagram.com/');
                        },
                        child: const Text(
                          'Instagram',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20), 

                      GestureDetector(
                        onTap: () {
                          _launchURL('https://www.x.com/');
                        },
                        child: const Text(
                          'Twitter',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20), 
                  // Botón para redirigir al usuario a la pantalla de inicio de sesión
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Iniciar Sesión',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
