import 'package:CoachCraft/widgets/match/filter_section_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CoachCraft/widgets/match/player_stat_card.dart';
import 'package:CoachCraft/provider/match_provider.dart';
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:provider/provider.dart';
import 'package:CoachCraft/widgets/match/match_list.dart';

void main() {
  group('Match Widget Tests', () {
    testWidgets('Displays initial state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ParentWidget(),
        ),
      );

      // Assert
      expect(find.text('Filtrado de Partidos'), findsOneWidget);
      expect(find.text('Temporada seleccionada: 2024'), findsOneWidget);
      expect(find.text('Tipo de partido seleccionado: Todos'), findsOneWidget);
    });
  });


    group('PlayerStatTable Widget Tests', () {
    testWidgets('Check that the charging indicator is displayed when starting up', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MatchProvider()),
            ChangeNotifierProvider(create: (_) => TeamProvider()),
          ],
          child: MaterialApp(
            home: PlayerStatTable(),
          ),
        ),
      );

      // Busca el indicador de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Verify that the statistics table is displayed correctly', (WidgetTester tester) async {
      // Proporciona valores simulados para evitar interacciones reales con Firestore
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MatchProvider()),
            ChangeNotifierProvider(create: (_) => TeamProvider()),
          ],
          child: MaterialApp(
            home: PlayerStatTable(),
          ),
        ),
      );

      // Espera a que el widget termine de procesar las estadísticas simuladas
      await tester.pumpAndSettle();

      // Verifica que el título para porteros aparece
      expect(find.text('Estadísticas Porteros'), findsOneWidget);

      // Verifica que el título para jugadores de campo aparece
      expect(find.text('Jugadores de Campo'), findsOneWidget);
    });
  });

  group('MatchList Widget Tests', () {
    testWidgets('Check that the list of matches is displayed correctly', (WidgetTester tester) async {
      // Datos de ejemplo para los partidos
      final matches = [
        {
          'id': '1',
          'data': {
            'rivalTeam': 'Real Madrid',
            'matchDate': '2025-01-01',
            'result': '2-1',
            'location': 'Casa',
            'matchType': 'Liga'
          }
        },
        {
          'id': '2',
          'data': {
            'rivalTeam': 'Barcelona',
            'matchDate': '2025-01-05',
            'result': '1-1',
            'location': 'Fuera',
            'matchType': 'Copa'
          }
        }
      ];

      // Crear el widget con los partidos de ejemplo
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => MatchProvider(),
            child: MatchList(filteredMatches: matches),
          ),
        ),
      );

      // Verifica que el número de tarjetas mostradas coincida con la cantidad de partidos
      expect(find.byType(GestureDetector), findsNWidgets(matches.length));

      // Verifica que el nombre del rival aparezca en la lista
      expect(find.text('Rival: Real Madrid'), findsOneWidget);
      expect(find.text('Rival: Barcelona'), findsOneWidget);

      // Verifica que las fechas de los partidos se muestren correctamente
      expect(find.text('Fecha: 01-01-2025'), findsOneWidget);
      expect(find.text('Fecha: 05-01-2025'), findsOneWidget);
    });

    testWidgets('Check that a message is displayed if there are no matches available', (WidgetTester tester) async {
      // Crear el widget sin partidos
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => MatchProvider(),
            child: MatchList(filteredMatches: [], isLoading: false),
          ),
        ),
      );

      // Verifica que se muestra el mensaje de "No hay partidos disponibles"
      expect(find.text('No hay partidos disponibles'), findsOneWidget);
    });

    testWidgets('Verify that the loading spinner is displayed correctly when isLoading is true', (WidgetTester tester) async {
      // Crear el widget con isLoading = true
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => MatchProvider(),
            child: MatchList(filteredMatches: [], isLoading: true),
          ),
        ),
      );

      // Verifica que se muestra el CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });  
}
