// login_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

/// Servicio de autenticación que maneja el inicio de sesión y registro de usuarios.
class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Valida el correo electrónico y la contraseña para el registro.
  String? validateEmailAndPassword(String email, String password) {
    // Validar el formato del correo electrónico
    if (!EmailValidator.validate(email)) {
      return 'Correo electrónico no válido';
    }
    // Verificar que la contraseña tenga al menos 8 caracteres
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null; // Retorna null si no hay errores
  }

  /// Inicia sesión con el correo y la contraseña proporcionados.
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Retorna el usuario autenticado
    } on FirebaseAuthException catch (e) {
      // Maneja errores de autenticación
      throw e.message ?? 'Error al iniciar sesión';
    }
  }

  /// Registra un nuevo usuario con el correo y la contraseña proporcionados.
  Future<User?> register(String email, String password) async {
    // Validar correo y contraseña
    String? validationError = validateEmailAndPassword(email, password);
    if (validationError != null) {
      throw validationError; // Lanza un error si hay problemas de validación
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; 
    } on FirebaseAuthException catch (e) {
      // Maneja errores de autenticación
      throw e.message ?? 'Error al registrar el usuario';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
