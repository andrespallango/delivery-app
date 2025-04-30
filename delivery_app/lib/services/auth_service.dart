import 'package:delivery_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService;
  String? _token;
  String? _userType; // 'admin', 'driver', 'client'
  String? _userId;

  AuthService(this._apiService);

  String? get token => _token;
  String? get userType => _userType;
  String? get userId => _userId;

  bool get isAuthenticated => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userType = prefs.getString('userType');
    _userId = prefs.getString('userId');
  }

  Future<bool> login(String email, String phone) async {
    try {
      // This is a mock implementation since the API doesn't have auth endpoints
      // In a real app, you would call the API to authenticate

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, we'll set hardcoded values
      // In a real app, these would come from the API response
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Determine user type based on email (for demo)
      if (email.contains('admin')) {
        _userType = 'admin';
        _userId = 'admin_1';
      } else if (email.contains('driver')) {
        _userType = 'driver';
        _userId = 'driver_1';
      } else {
        _userType = 'client';
        _userId = 'client_1';
      }

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userType', _userType!);
      await prefs.setString('userId', _userId!);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userType = null;
    _userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userType');
    await prefs.remove('userId');
  }

  Future<bool> register(String name, String email, String phone, String address, String userType) async {
    try {
      // This is a mock implementation since the API doesn't have auth endpoints
      // In a real app, you would call the API to register

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Print the data that would be sent to the API
      print("Registrando usuario:");
      print("Nombre: $name");
      print("Email: $email");
      print("Teléfono: $phone");
      print("Dirección: $address");
      print("Tipo de usuario: $userType");

      // Si quisieras hacer una llamada real a la API, sería algo como:
      /*
      final response = await _apiService.post('/register', {
        'nombre': name,
        'email': email,
        'telefono': phone,
        'direccion': address,
        'tipo': userType,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registro exitoso
      } else {
        throw Exception('Failed to register');
      }
      */

      // After registration, log the user in
      return await login(email, phone);
    } catch (e) {
      print("Error en registro: $e");
      return false;
    }
  }
}