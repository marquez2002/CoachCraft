import 'package:CoachCraft/screens/menu/menu_screen.dart';
//import 'package:CoachCraft/services/loginGoogleUtil.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Se añade la imagen preseleccionada de fondo de pantalla
        Image.asset(
          'assets/image/main_football.png', // Ruta del archivo de imagen ajustada
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        
        // Contenido de la pantalla principal
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Se añade el logo de la aplicación
              Image.asset(
                'assets/image/coachcraft_logo.png', // Ruta del archivo de imagen ajustada
                width: 200,
                height: 200,
              ),
              
              // Botón para pasar a la siguiente pantalla
              ElevatedButton(
                onPressed: () {
                  // Acción al presionar el botón (navegar a la pantalla del menú)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MenuScreen()),
                  );
                },
                child: const Text('Acceder'),
              ),              
            ],
          ),
        ),
      ],
    );
  }
}
