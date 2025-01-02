import 'package:CoachCraft/widgets/plays/upload_photo_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CoachCraft/widgets/plays/upload_plays_form.dart';


void main() {
  testWidgets('Test de validación de nombre vacío', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadPhotosForm(),
        ),
      ),
    );

    // Simula intentar enviar el formulario sin completar el campo de nombre
    await tester.tap(find.text('Subir Foto'));
    await tester.pump();

    // Verifica que muestra un mensaje de advertencia cuando el campo de nombre está vacío
    expect(find.text('Por favor, ingresa un nombre'), findsOneWidget);
  });

  testWidgets('Empty name validation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadForm(),
        ),
      ),
    );

    // Simula intentar enviar el formulario sin completar el campo de nombre
    await tester.tap(find.text('Subir Jugada'));
    await tester.pump();

    // Verifica que muestra un mensaje de advertencia cuando el campo de nombre está vacío
    expect(find.text('Por favor, ingresa un nombre'), findsOneWidget);
  });

  testWidgets('Empty type validation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadForm(),
        ),
      ),
    );

    // Simula completar el nombre pero no seleccionar el tipo ni el video
    await tester.enterText(find.byType(TextFormField), 'Jugada sin tipo');
    await tester.pump();

    // Simula intentar enviar el formulario sin seleccionar un tipo
    await tester.tap(find.text('Subir Jugada'));
    await tester.pump();

    // Verifica que muestra un mensaje de advertencia cuando el tipo no ha sido seleccionado
    expect(find.text('Por favor, selecciona un tipo'), findsOneWidget);
  });
}

