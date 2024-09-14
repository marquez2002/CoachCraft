/*
 * Archivo: password_recovery_widget.dart
 * Descripción: Este archivo contiene la definición del widget de recuperación de contraseña 
 *              que permite a los usuarios enviar un correo electrónico para recuperar su contraseña.
 * 
 * Autor: [Tu Nombre]
 * Fecha: [Fecha de Creación]
 * 
 * Notas adicionales:
 * - Este widget muestra un mensaje explicativo y métodos de contacto.
 */

import 'package:flutter/material.dart';

/// Clase principal que representa el widget de recuperación de contraseña.
class PasswordRecoveryWidget extends StatelessWidget {
  const PasswordRecoveryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'), // Título de la pantalla
      ),
      body: Center(
        child: Container(
          width: 350, // Ancho del contenedor
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Color del fondo con opacidad
            borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Sombra del contenedor
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del contenedor
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mensaje explicativo sobre la recuperación de contraseña
              const Text(
                'Para recuperar tu contraseña, envía un correo a:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'soporte@coachcraft.com',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue, // Color destacado para el correo
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
              // Enlaces a Instagram y Twitter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Aquí puedes implementar la función para abrir Instagram
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ir a Instagram')),
                      );
                    },
                    child: const Text(
                      'Instagram',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Espacio entre los enlaces
                  GestureDetector(
                    onTap: () {
                      // Aquí puedes implementar la función para abrir Twitter
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ir a Twitter')),
                      );
                    },
                    child: const Text(
                      'Twitter',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
