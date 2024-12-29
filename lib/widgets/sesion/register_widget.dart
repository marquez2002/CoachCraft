/*
 * Archivo: register_widget.dart
 * Descripción: Este archivo contiene la definición del widget para realizar el registro 
 *              en el sistema, para acceder al mismo.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/screens/teams/teams_screen.dart';
import 'package:CoachCraft/services/login/login_service.dart';
import 'package:CoachCraft/widgets/sesion/login_widget.dart';
import 'package:flutter/material.dart';

/// Clase principal que representa el widget de registro.
class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  _RegisterWidgetState createState() => _RegisterWidgetState();
}

/// Estado asociado al RegisterWidget, que maneja el estado del formulario de registro.
class _RegisterWidgetState extends State<RegisterWidget> {
  // Controladores para los campos de texto del formulario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
          Center( 
            child: SingleChildScrollView(
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
                        key: const Key('emailField'), // Agregamos la clave aquí
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
                        key: const Key('passwordField'), // Agregamos la clave aquí
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
                      const SizedBox(height: 20),
                      // Campo de texto para confirmar la contraseña
                      TextFormField(
                        key: const Key('confirmPasswordField'), // Agregamos la clave aquí
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirma tu contraseña';
                          } else if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      // Botón para registrar un nuevo usuario
                      ElevatedButton(
                        key: const Key('registerButton'), // Agregamos la clave aquí
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              // Llamar al servicio de registro con el correo y la contraseña
                              await _loginService.register(
                                _emailController.text,
                                _passwordController.text,
                              );
                              // Si el registro es exitoso, navegar a la pantalla de menú
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
                        child: const Text('Registrar'),
                      ),
                      const SizedBox(height: 20),
                      // Botón para navegar a la pantalla de inicio de sesión
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginWidget()),
                          );
                        },
                        child: const Text(
                          '¡Ya tengo una cuenta!',
                          style: TextStyle(
                            color: Colors.blue,
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
