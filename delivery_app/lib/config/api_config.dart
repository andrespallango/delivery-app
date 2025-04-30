class ApiConfig {
  // Base URL for API
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // Endpoints
  static const String clientesEndpoint = '/clientes';
  static const String conductoresEndpoint = '/conductores';
  static const String conductoresDisponiblesEndpoint = '/conductores/disponibles';
  static const String vehiculosEndpoint = '/vehiculos';
  static const String pedidosEndpoint = '/pedidos';
  static const String enviosEndpoint = '/envios';
  
  // Timeout durations
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}

