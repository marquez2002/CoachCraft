import 'package:CoachCraft/screens/basket_field_screen.dart';
import 'package:CoachCraft/screens/home_screen.dart';
import 'package:CoachCraft/screens/mid_basket_field_screen.dart';
import 'package:flutter/material.dart';



class MenuWidgetBasket extends StatelessWidget {
  const MenuWidgetBasket({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de datos para los botones con las rutas determinada que deben seguir
    List<Map<String, dynamic>> buttonData = [
      //{'label': 'Gestor de Equipo', 'route': const MenuScreenBasketTeam()},
      {'label': 'Campo Completo', 'route': const BasketFieldScreen()},
      {'label': 'Media Pista', 'route': const MidBasketFieldScreen()},
      {'label': 'Volver', 'route': const HomeScreen()},
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Se añade la imagen preselecionada de fondo de pantalla
          Image.asset(
            'assets/image/basket_menu3.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),


          // Contenido de la pantalla principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttonData.map((data) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción al presionar el botón con navegacion a la pantalla correspondiente
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => data['route']),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                      minimumSize: const Size(300, 50), // Tamaño del botón
                    ),
                    child: Text(
                      data['label'],
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
