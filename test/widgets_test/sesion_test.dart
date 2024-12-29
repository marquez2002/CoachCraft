import 'package:CoachCraft/screens/sesion/register_screen.dart';
import 'package:CoachCraft/widgets/sesion/register_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CoachCraft/screens/teams/teams_screen.dart';
import 'package:CoachCraft/widgets/sesion/login_widget.dart';

void main() {
  group('RegisterWidget Tests', () {
    testWidgets('Renderizar el formulario de registro correctamente', (tester) async {
      // Act: Renderizar el RegisterWidget
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterWidget(),
        ),
      );

      // Assert: Verificar que los elementos del formulario se muestran correctamente
      expect(find.byType(TextFormField), findsNWidgets(3)); // Tres campos: correo, contraseña, confirmación
      expect(find.byType(ElevatedButton), findsOneWidget); // Un botón de registrar
      expect(find.text('Correo Electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Confirmar Contraseña'), findsOneWidget);
      expect(find.text('¡Ya tengo una cuenta!'), findsOneWidget); // Enlace al login
    });

    testWidgets('Validación de campos vacíos', (tester) async {
      // Act: Renderizar el RegisterWidget
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterWidget(),
        ),
      );

      // Simular presionar el botón de registrar sin llenar los campos
      await tester.tap(find.byKey(Key('registerButton')));
      await tester.pump();

      // Assert: Verificar que los mensajes de validación se muestran
      expect(find.text('Por favor ingresa tu correo'), findsOneWidget);
      expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
      expect(find.text('Por favor confirma tu contraseña'), findsOneWidget);
    });

    testWidgets('Validación de contraseñas no coincidentes', (tester) async {
      // Act: Renderizar el RegisterWidget
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterWidget(),
        ),
      );

      // Rellenar los campos
      await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), 'password123');
      await tester.enterText(find.byKey(Key('confirmPasswordField')), 'password456'); // Contraseña no coincide
      await tester.tap(find.byKey(Key('registerButton')));
      await tester.pump();

      // Assert: Verificar que se muestra el mensaje de error de contraseñas no coincidentes
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('Registro exitoso y navegación a la pantalla de equipos', (tester) async {
      // Act: Renderizar el RegisterWidget
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterWidget(),
        ),
      );

      // Rellenar los campos con datos válidos
      await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), 'password123');
      await tester.enterText(find.byKey(Key('confirmPasswordField')), 'password123'); // Las contraseñas coinciden

      // Simular la acción de presionar el botón de registro
      await tester.tap(find.byKey(Key('registerButton')));
      await tester.pumpAndSettle(); // Esperar la navegación

      // Assert: Verificar que la navegación ha ocurrido hacia la pantalla de equipos
      expect(find.byType(TeamsScreen), findsOneWidget);
    });

    testWidgets('Navegar al LoginWidget desde RegisterWidget', (tester) async {
      // Act: Renderizar el RegisterWidget
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Simular presionar el enlace "¡Ya tengo una cuenta!"
      await tester.tap(find.text('¡Ya tengo una cuenta!'));
      await tester.pumpAndSettle();

      // Assert: Verificar que se navega a la pantalla de inicio de sesión (LoginWidget)
      expect(find.byType(LoginWidget), findsOneWidget);
    });
  });
}
