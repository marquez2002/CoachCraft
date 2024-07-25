import 'package:CoachCraft/widgets/menu_widget%20_basket.dart';
import 'package:flutter/material.dart';

class MenuScreenBasket extends StatelessWidget {
  const MenuScreenBasket({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Enunciamos el título de la screen
      title: 'CoachCraft',

      theme: ThemeData(
        // Esquema de colores basado en un color principal
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),       
        // Usar Material3 para el diseño de la aplicación
        useMaterial3: true,  
      ),

      home: const Scaffold(
        // El cuerpo de HomeScreen se encontrará en MainWidget
        body: MenuWidgetBasket(),
      ),
    );
  }
}
