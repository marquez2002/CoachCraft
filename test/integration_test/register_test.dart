import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:CoachCraft/main.dart'; // Cambia esto por el archivo correcto de tu app


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Inicialización de Firebase
    await Firebase.initializeApp();
  });

  group('Test de registro', () {
    testWidgets('Muestra errores si los campos están vacíos', (tester) async {
      // Cargar la aplicación
      await tester.pumpWidget(const MyApp());

      // Verifica que no haya mensajes de error al principio
      expect(find.text('Por favor ingresa tu correo'), findsNothing);
      expect(find.text('Por favor ingresa tu contraseña'), findsNothing);
      expect(find.text('Por favor confirma tu contraseña'), findsNothing);

      // Toca el botón de registro sin completar los campos
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();

      // Verifica que los mensajes de error sean mostrados
      expect(find.text('Por favor ingresa tu correo'), findsOneWidget);
      expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
      expect(find.text('Por favor confirma tu contraseña'), findsOneWidget);
    });

    testWidgets('No muestra errores si los campos están completos', (tester) async {
      // Cargar la aplicación
      await tester.pumpWidget(const MyApp());

      // Completar los campos
      await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'password123');

      // Toca el botón de registro
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();

      // Verifica que los mensajes de error NO sean mostrados
      expect(find.text('Por favor ingresa tu correo'), findsNothing);
      expect(find.text('Por favor ingresa tu contraseña'), findsNothing);
      expect(find.text('Por favor confirma tu contraseña'), findsNothing);
    });

    testWidgets('Muestra error si las contraseñas no coinciden', (tester) async {
      // Cargar la aplicación
      await tester.pumpWidget(const MyApp());

      // Completar los campos
      await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'differentpassword');

      // Toca el botón de registro
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();

      // Verifica que se muestre el mensaje de error sobre contraseñas no coincidentes
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });
  });
}
