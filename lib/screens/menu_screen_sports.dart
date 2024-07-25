import 'package:flutter/material.dart';
import '../widgets/menu_widget_sports.dart';

class MenuScreenSports extends StatelessWidget {
  const MenuScreenSports({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la screen
      title: 'CoachCraft Sports',

      theme: ThemeData(
        // Esquema de colores personalizado con un color de semilla negro
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),    
        // Usar Material3 para el diseño de la aplicación
        useMaterial3: true,
      ),

      home: const Scaffold(
        // El cuerpo de MenuScreen se encontrará en MenuWidget
        body: MenuWidgetSports(),
      ),
    );
  }
}
