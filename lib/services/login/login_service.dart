/*
 * Archivo: login_service.dart
 * Descripción: Este archivo contiene un servicio de autenticación que gestiona el registro, 
 *              inicio de sesión y cierre de sesión de los usuarios utilizando Firebase Authentication. 
 *              También incluye la validación de correo electrónico y contraseña.
 * 
 * Autor: Gonzalo Márquez de Torres
 */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

/// Servicio de autenticación que maneja el inicio de sesión, registro y cierre de sesión de usuarios.
class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  /// Valida el correo electrónico y la contraseña para el registro.
  String? validateEmailAndPassword(String email, String password) {    
    if (!EmailValidator.validate(email)) {
      return 'Correo electrónico no válido'; 
    }

    // Verificar que la contraseña tenga al menos 8 caracteres
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres'; 
    }
    return null;
  }

  /// Inicia sesión con el correo y la contraseña proporcionados.
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; 
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Error al iniciar sesión';
    }
  }

  /// Registra un nuevo usuario con el correo y la contraseña proporcionados.
  Future<User?> register(String email, String password) async {
    // Validar el correo y la contraseña antes de intentar el registro
    String? validationError = validateEmailAndPassword(email, password);
    if (validationError != null) {
      throw validationError;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Verifica si el correo ya está en uso
      if (e.code == 'email-already-in-use') {
        throw 'El correo electrónico ya está en uso. Por favor, utiliza otro.';
      }
      throw e.message ?? 'Error al registrar el usuario';
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> logout() async {
    await _auth.signOut();
  }
}
