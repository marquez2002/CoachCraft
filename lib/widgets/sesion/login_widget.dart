/*
 * Archivo: login_widget.dart
 * Descripción: Este archivo contiene la definición del widget para realizar el logueo 
 *              en el sistema, para acceder al mismo.
 * 
 * Autor: Gonzalo Márquez de Torres
 * 
 * Notas adicionales:
 * - El widget permite redirigir a sitios externos (Instagram y Twitter) y mostrar contacto por correo.
 * - También incluye un botón para navegar a la pantalla de inicio de sesión.
 */
import 'package:CoachCraft/screens/sesion/password_recovery_screen.dart';
import 'package:CoachCraft/screens/sesion/register_screen.dart';
import 'package:CoachCraft/screens/teams/teams_screen.dart';
import 'package:CoachCraft/services/login/login_service.dart';
import 'package:flutter/material.dart';

/// Clase principal que representa el widget de inicio de sesión.
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

/// Estado asociado al LoginWidget, que maneja el estado del formulario de inicio de sesión.
class _LoginWidgetState extends State<LoginWidget> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Llave global para validar el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Instancia del servicio de autenticación
  final LoginService _loginService = LoginService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Image.asset(
            'assets/image/football_menu4.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Center(
              // Contenedor principal para el formulario de inicio de sesión
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 60), 
                width: 350,
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
                // Formulario que contiene los campos de entrada y botones
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo de la aplicación en la parte superior del formulario
                      Image.asset(
                        'assets/image/coachcraft_logo.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      // Campo de texto para ingresar el correo electrónico
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Campo de texto para ingresar la contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Botón para iniciar sesión
                      ElevatedButton(
                        onPressed: () async {
                          // Valida el formulario antes de intentar iniciar sesión
                          if (_formKey.currentState!.validate()) {
                            try {
                              await _loginService.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                              // Si el inicio de sesión es exitoso, navegar a la pantalla de equipos
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TeamsScreen()),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: const Text('Iniciar Sesión'),
                      ),
                      const SizedBox(height: 10),
                      // Botón para navegar a la pantalla de registro
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Registrar nueva cuenta',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      // Botón para recuperar la contraseña
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PasswordRecoveryScreen()),
                          );
                        },
                        child: const Text(
                          '¿Has olvidado la contraseña?',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
