import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CoachCraft/widgets/player/player_widget.dart'; // Asegúrate de importar correctamente

void main() {
 group('FootballListPlayer Widget Tests', () {
    testWidgets('Carga la lista de jugadores correctamente', (tester) async {
      // Datos estáticos que simulan el resultado de getPlayers
      final players = [
        {
          'nombre': 'Jugador 1',
          'dorsal': 10,
          'posicion': 'Portero',
          'edad': 30,
          'altura': 180,
          'peso': 75
        },
        {
          'nombre': 'Jugador 2',
          'dorsal': 9,
          'posicion': 'Ala',
          'edad': 25,
          'altura': 175,
          'peso': 70
        },
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerDataTable(players: players),
          ),
        ),
      );

      // Assert
      expect(find.text('Jugador 1'), findsOneWidget);
      expect(find.text('Portero'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      expect(find.text('Jugador 2'), findsOneWidget);
      expect(find.text('Ala'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('Visualización de la tabla de jugadores', (tester) async {
      // Datos estáticos para la prueba
      final players = [
        {
          'nombre': 'Jugador 1',
          'dorsal': 10,
          'posicion': 'Portero',
          'edad': 30,
          'altura': 180,
          'peso': 75
        },
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerDataTable(players: players),
          ),
        ),
      );

      // Assert
      expect(find.text('Jugador 1'), findsOneWidget);
      expect(find.text('Portero'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });
  });
}
