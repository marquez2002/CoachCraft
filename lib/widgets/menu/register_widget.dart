// register_widget.dart
import 'package:CoachCraft/services/login/login_service.dart';
import 'package:CoachCraft/screens/menu/menu_screen.dart'; // Asegúrate de ajustar la ruta según tu estructura
import 'package:CoachCraft/widgets/menu/login_widget.dart';
import 'package:flutter/material.dart';

/// Clase principal que representa el widget de registro.
class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  _RegisterWidgetState createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginService _loginService = LoginService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla
          Image.asset(
            'assets/image/football_menu4.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Container(
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo de la aplicación
                    Image.asset(
                      'assets/image/coachcraft_logo.png',
                      width: 120,
                      height: 120,
                    ),
                    
                    const SizedBox(height: 20),

                    // Campo de correo electrónico
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

                    // Campo de contraseña
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

                    const SizedBox(height: 20),

                    // Campo para confirmar contraseña
                    TextFormField(
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

                    // Botón de registro
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // Llamar al método de registro
                            await _loginService.register(
                              _emailController.text,
                              _passwordController.text,
                            );
                            // Navegar a la pantalla de menú si es exitoso
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MenuScreen()),
                            );
                          } catch (e) {
                            // Mostrar mensaje de error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      child: const Text('Registrar'),
                    ),
                    
                    const SizedBox(height: 20),

                    // Botón de "Ya tengo una cuenta"
                    TextButton(
                      onPressed: () {
                        // Navegar a la pantalla de inicio de sesión
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginWidget()),
                        );
                      },
                      child: const Text(
                        'Ya tengo una cuenta',
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
        ],
      ),
    );
  }
}
