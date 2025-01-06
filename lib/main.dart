import 'package:CoachCraft/provider/match_provider.dart';
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:CoachCraft/screens/menu/home_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart'; 
import 'package:provider/provider.dart'; 

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
    
  // Pantalla completa inmersiva  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeamProvider()), 
        ChangeNotifierProvider(create: (_) => MatchProvider()), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Título de la aplicación
        title: 'CoachCraft',

        // Tema de la aplicación
        theme: ThemeData(
          // Esquema de colores personalizado con un color de semilla negro
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          // Usar Material3 para el diseño de la aplicación
          useMaterial3: true,
        ),
        
        home: const HomeScreen(), // Pantalla principal de la aplicación
      ),
    );
  }
}
