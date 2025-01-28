/*
 * Archivo: menu_test.dart
 * Descripción: Archivo de test correspondientes a los menus.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:CoachCraft/widgets/menu/menu_widget_futsal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CoachCraft/widgets/menu/menu_widget_futsal_team.dart';
import 'package:CoachCraft/screens/team_management/team_add_player_screen.dart';
import 'package:CoachCraft/screens/team_management/team_list_player_screen.dart';
import 'package:CoachCraft/screens/menu/menu_screen_futsal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test to verify that the MenuWidgetFutsalTeam is rendered correctly
  testWidgets('Verify MenuWidgetFutsalTeam UI Layout', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: MenuWidgetFutsalTeam(),
      ),
    );

    // Check that the background image is displayed
    expect(find.byType(Image), findsOneWidget);
    
    // Check that all buttons are present on the screen
    expect(find.text('Añadir Jugador'), findsOneWidget);
    expect(find.text('Datos Equipo'), findsOneWidget);
    expect(find.text('Listar Jugadores'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
  });

  // Test to verify navigation on button press for 'Añadir Jugador'
  testWidgets('Navigate to TeamAddPlayer on "Añadir Jugador" button press', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: MenuWidgetFutsalTeam(),
      ),
    );

    // Tap on the 'Añadir Jugador' button
    await tester.tap(find.text('Añadir Jugador'));
    await tester.pumpAndSettle();

    // Verify that we navigate to the TeamAddPlayer screen
    expect(find.byType(FootballAddPlayer), findsOneWidget);
  });

  // Test to verify navigation on button press for 'Listar Jugadores'
  testWidgets('Navigate to TeamListPlayer on "Listar Jugadores" button press', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: MenuWidgetFutsalTeam(),
      ),
    );

    // Tap on the 'Listar Jugadores' button
    await tester.tap(find.text('Listar Jugadores'));
    await tester.pumpAndSettle();

    // Verify that we navigate to the TeamListPlayer screen
    expect(find.byType(FootballListPlayer), findsOneWidget);
  });

  // Test to verify navigation on button press for 'Volver'
  testWidgets('Navigate to MenuScreenFutsal on "Volver" button press', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: MenuWidgetFutsalTeam(),
      ),
    );

    // Tap on the 'Volver' button
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    // Verify that we navigate to the MenuScreenFutsal screen
    expect(find.byType(MenuScreenFutsal), findsOneWidget);
  });

    // Test to check if the background image is being rendered
  testWidgets('Render background image correctly', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: MenuWidgetFutsal(),
      ),
    );

    // Check if the background image is present
    expect(find.byType(Image), findsOneWidget);
  });

  // Test to verify that the buttons are visible on the screen
  testWidgets('Check if all buttons are displayed correctly', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: MenuWidgetFutsal(),
      ),
    );

    // Check if the "Gestor de Equipo", "Pizarra", "Partidos", "Estadísticas", and "Volver" buttons are present
    expect(find.text('Gestor de Equipo'), findsOneWidget);
    expect(find.text('Pizarra'), findsOneWidget);
    expect(find.text('Partidos'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
  });
}
