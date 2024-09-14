// login_widget.dart
import 'package:CoachCraft/screens/menu/menu_screen.dart'; // Importa la pantalla de menú
import 'package:CoachCraft/services/login/login_service.dart';
import 'package:CoachCraft/widgets/menu/register_widget.dart';
import 'package:flutter/material.dart';

/// Clase principal que representa el widget de inicio de sesión.
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
                    
                    const SizedBox(height: 15),

                    // Botón de inicio de sesión
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // Llamar al método de inicio de sesión
                            await _loginService.login(
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
                      child: const Text('Iniciar Sesión'),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Botón de "Registrar nueva cuenta"
                    TextButton(
                      onPressed: () {
                        // Navegar a la pantalla de registro
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterWidget()),
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
