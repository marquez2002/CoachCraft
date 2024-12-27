import 'package:CoachCraft/widgets/match/player_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CoachCraft/provider/match_provider.dart';
import 'package:CoachCraft/provider/team_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('PlayerStatTable Widget Tests', () {
    testWidgets('Verifica que se muestra el indicador de carga al iniciar', (WidgetTester tester) async {
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

    testWidgets('Verifica que la tabla de estadísticas se muestra correctamente', (WidgetTester tester) async {
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

    testWidgets('Verifica que el diálogo de actualización de estadísticas se muestra al tocar una celda', (WidgetTester tester) async {
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

      // Encuentra una celda de estadísticas y realiza un gesto de toque
      final statCell = find.text('0').first; // Ajusta según las estadísticas por defecto
      await tester.tap(statCell);
      await tester.pumpAndSettle();

      // Verifica que el diálogo aparece
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verifica que los botones dentro del diálogo están presentes
      expect(find.text('Guardar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });
  });
}
