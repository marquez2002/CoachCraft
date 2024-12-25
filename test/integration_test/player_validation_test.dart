import 'package:CoachCraft/services/player/player_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerValidations', () {

    // Pruebas con el nombre del jugador
    test('validateName returns error for empty name', () {
      var result = PlayerValidations.validateName('');
      expect(result, 'Por favor ingrese un nombre');
    });

    test('validateName returns error for name with 2 characters', () {
      var result = PlayerValidations.validateName('Pe');
      expect(result, 'Por favor ingrese un nombre');
    });

    test('validateName returns null for valid name', () {
      var result = PlayerValidations.validateName('Juan');
      expect(result, null);
    });

    test('validateDorsal returns error for non-numeric dorsal', () {
      var result = PlayerValidations.validateDorsal('abc');
      expect(result, 'El dorsal debe ser un número entre 0 y 99.');
    });

    test('validateDorsal returns error for out of range dorsal', () {
      var result = PlayerValidations.validateDorsal('150');
      expect(result, 'El dorsal debe ser un número entre 0 y 99.');
    });

    test('validateDorsal returns null for valid dorsal', () {
      var result = PlayerValidations.validateDorsal('10');
      expect(result, null);
    });

    test('validatePosition returns error for invalid position', () {
      var result = PlayerValidations.validatePosition('Delantero');
      expect(result, 'Posición no válida. Debe ser: Portero, Ala, Pivot o Cierre');
    });

    test('validatePosition returns error for invalid position', () {
      var result = PlayerValidations.validatePosition('ala');
      expect(result, 'Posición no válida. Debe ser: Portero, Ala, Pivot o Cierre');
    });

    test('validatePosition returns error for invalid position', () {
      var result = PlayerValidations.validatePosition('Cierre');
      expect(result, null);
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validatePosition('Portero');
      expect(result, null);
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validateAge('abc');
      expect(result, 'La edad debe estar entre 1 y 80');
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validateAge('150');
      expect(result, 'La edad debe estar entre 1 y 80');
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validateAge('35');
      expect(result, null);
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validateWeight('0');
      expect(result, 'Peso no válido. Debe estar entre 30 y 200 kg');
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validateWeight('90');
      expect(result, null);
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validateHeight('95');
      expect(result, 'Altura no válida. Debe estar entre 100 y 250 cm');
    });

    test('validatePosition returns null for valid position', () {
      var result = PlayerValidations.validateHeight('169');
      expect(result, null);
    });

  });
}
