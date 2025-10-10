import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_tienda_app/data/services/firebase_auth_service.dart';
import 'package:mi_tienda_app/domain/entities/user_entity.dart';

/// Provider de autenticación
/// Gestiona el estado de autenticación del usuario
class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService;
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _initAuthListener();
  }

  // Getters
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isEmployee => _currentUser?.isEmployee ?? false;

  /// Inicializar listener de cambios de autenticación
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await _authService.getUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  /// Iniciar sesión
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
      notifyListeners();
    }
  }

  /// Registrar nuevo usuario (solo admin)
  Future<bool> registerUser({
    required String email,
    required String password,
    required String role,
    required String storeId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newUser = await _authService.registerUser(
        email: email,
        password: password,
        role: role,
        storeId: storeId,
      );

      _isLoading = false;
      notifyListeners();

      return newUser != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtener mensaje de error amigable
  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Usuario no encontrado';
    } else if (error.contains('wrong-password')) {
      return 'Contraseña incorrecta';
    } else if (error.contains('email-already-in-use')) {
      return 'El email ya está en uso';
    } else if (error.contains('weak-password')) {
      return 'La contraseña es muy débil';
    } else if (error.contains('invalid-email')) {
      return 'Email inválido';
    } else if (error.contains('network-request-failed')) {
      return 'Error de conexión. Verifica tu internet';
    } else {
      return 'Error al iniciar sesión. Intenta nuevamente';
    }
  }
}

