import 'package:CoachCraft/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Orientación horizontal
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la aplicación
      title: 'CoachCraft',

      // Tema de la aplicación
      theme: ThemeData(
        // Esquema de colores personalizado con un color de semilla negro
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        // Usar Material3 para el diseño de la aplicación
        useMaterial3: true,
      ),
      
      home: const HomeScreen(), // Cambia la pantalla principal a MainWidget
    );
  }
}
