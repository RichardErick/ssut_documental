import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_role.dart';
import '../services/audit_service.dart';

class AuthProvider extends ChangeNotifier {
  // Almacenamiento seguro para datos sensibles (token de autenticación)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  AuditService? _auditService;

  void setAuditService(AuditService service) {
    _auditService = service;
  }
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  UserRole _role = UserRole.invitado;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  UserRole get role => _role;
  
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  
  bool get isLocked {
    if (_lockoutEndTime == null) return false;
    if (DateTime.now().isAfter(_lockoutEndTime!)) {
      _resetLockout();
      return false;
    }
    return true;
  }
  
  Duration get remainingLockoutTime {
    if (_lockoutEndTime == null) return Duration.zero;
    return _lockoutEndTime!.difference(DateTime.now());
  }

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      // Cargar token de forma segura
      _token = await _secureStorage.read(key: 'auth_token');
      
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        final roleString = prefs.getString('user_role');
        final userDataString = prefs.getString('user_data');
        
        if (roleString != null) {
          _role = _parseRole(roleString);
        }
        
        if (userDataString != null) {
          try {
            _user = jsonDecode(userDataString);
          } catch (e) {
            // Fallback for old data format or persistent errors
            final username = prefs.getString('user_name');
            if (username != null) {
               _user = {'nombreUsuario': username};
            }
          }
        } else {
             // Fallback if user_data is missing
            final username = prefs.getString('user_name');
            if (username != null) {
               _user = {'nombreUsuario': username};
            }
        }
        _isAuthenticated = true;
      }
    } catch (e) {
      print('Error cargando estado de autenticación: $e');
      _isAuthenticated = false;
      _token = null;
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
  
    // Verificar estado de bloqueo
    if (isLocked) {
      throw Exception('Cuenta bloqueada temporalmente. Intente en ${remainingLockoutTime.inSeconds} segundos.');
    }

    // TODO: Implementar llamada real a API de autenticación
    // Por ahora simulamos el login y validación
    
    // Simulación de fallo esporádico o validación
    // En producción esto vendría de la API (401 Unauthorized)
    bool isValid = true; 
    
    // Simulo validación simple: pass debe ser "admin123" para demo
    if (password != 'admin123' && password != 'Admin123') {
       isValid = false;
    }

    if (!isValid) {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _lockoutEndTime = DateTime.now().add(const Duration(seconds: 30));
        notifyListeners();
        throw Exception('Demasiados intentos fallidos. Bloqueado por 30s.');
      }
      _auditService?.logEvent(
        action: 'LOGIN_FAILED',
        module: 'AUTH',
        details: 'IP desconocida - Intentos: $_failedAttempts',
        username: username,
      );
      notifyListeners();
      throw Exception('Credenciales inválidas');
    }

    // Login Exitoso
    _resetLockout();
    _token = 'mock_token_$username';
    _isAuthenticated = true;
        // Asignar rol
    String roleString = 'AdministradorSistema'; // Mock por defecto
    if (username.toLowerCase().contains('doc')) {
      roleString = 'AdministradorDocumentos';
    }
    
    _role = _parseRole(roleString);

    _user = {
      'id': 1,
      'nombreUsuario': username,
      'nombreCompleto': 'Usuario de Prueba',
      'rol': roleString,
    };

    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('user_data', jsonEncode(_user));
    } catch (e) {
      print('Error saving user data: $e');
    }
    
    // Save persistable auth data
    await prefs.setString('user_role', roleString);
    await prefs.setString('user_name', username);

    // Guardar token de forma segura
    await _secureStorage.write(key: 'auth_token', value: _token!);

    _auditService?.logEvent(
      action: 'LOGIN_SUCCESS',
      module: 'AUTH',
      details: 'Inicio de sesión exitoso',
      username: username,
    );

    notifyListeners();
  }
  
  void _resetLockout() {
    _failedAttempts = 0;
    _lockoutEndTime = null;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_role');
    await prefs.remove('user_name');

    // Eliminar token del almacenamiento seguro
    await _secureStorage.delete(key: 'auth_token');

    _auditService?.logEvent(
      action: 'LOGOUT',
      module: 'AUTH',
      details: 'Cierre de sesión',
      username: _user?['nombreUsuario'],
    );

    notifyListeners();
  }
  UserRole _parseRole(String roleName) {
    switch (roleName) {
      case 'AdministradorSistema': return UserRole.administradorSistema;
      case 'AdministradorDocumentos': return UserRole.administradorDocumentos;
      case 'ArchivoCentral': return UserRole.archivoCentral;
      case 'TramiteDocumentario': return UserRole.tramiteDocumentario;
      default: return UserRole.invitado;
    }
  }
}

