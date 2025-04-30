import 'dart:convert';
import 'package:delivery_app/config/api_config.dart';
import 'package:delivery_app/models/cliente_model.dart';
import 'package:delivery_app/models/conductor_model.dart';
import 'package:delivery_app/models/envio_model.dart';
import 'package:delivery_app/models/pedido_model.dart';
import 'package:delivery_app/models/vehiculo_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final http.Client _httpClient;

  ApiService({
    String? baseUrl,
    http.Client? httpClient,
  }) : baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _httpClient = httpClient ?? http.Client();

  // Helper methods for HTTP requests
  Future<dynamic> _get(String endpoint, {Map<String, String>? headers}) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? ApiConfig.getHeaders(),
    );
    
    return _handleResponse(response);
  }

  Future<dynamic> _post(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? ApiConfig.getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    
    return _handleResponse(response);
  }

  Future<dynamic> _put(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    final response = await _httpClient.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? ApiConfig.getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    
    return _handleResponse(response);
  }

  Future<dynamic> _delete(String endpoint, {Map<String, String>? headers}) async {
    final response = await _httpClient.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? ApiConfig.getHeaders(),
    );
    
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Cliente API methods
  Future<List<Cliente>> getClientes() async {
    final response = await _get(ApiConfig.clientesEndpoint);
    return (response as List).map((json) => Cliente.fromJson(json)).toList();
  }

  Future<Cliente> getClienteById(String id) async {
    final response = await _get('${ApiConfig.clientesEndpoint}/$id');
    return Cliente.fromJson(response);
  }

  Future<Cliente> createCliente(Cliente cliente) async {
    final response = await _post(
      ApiConfig.clientesEndpoint,
      body: cliente.toJson(),
    );
    return Cliente.fromJson(response);
  }

  Future<Cliente> updateCliente(Cliente cliente) async {
    final response = await _put(
      '${ApiConfig.clientesEndpoint}/${cliente.id}',
      body: cliente.toJson(),
    );
    return Cliente.fromJson(response);
  }

  Future<void> deleteCliente(String id) async {
    await _delete('${ApiConfig.clientesEndpoint}/$id');
  }

  // Conductor API methods
  Future<List<Conductor>> getConductores() async {
    final response = await _get(ApiConfig.conductoresEndpoint);
    return (response as List).map((json) => Conductor.fromJson(json)).toList();
  }

  Future<Conductor> getConductorById(String id) async {
    final response = await _get('${ApiConfig.conductoresEndpoint}/$id');
    return Conductor.fromJson(response);
  }

  Future<Conductor> createConductor(Conductor conductor) async {
    final response = await _post(
      ApiConfig.conductoresEndpoint,
      body: conductor.toJson(),
    );
    return Conductor.fromJson(response);
  }

  Future<Conductor> updateConductor(Conductor conductor) async {
    final response = await _put(
      '${ApiConfig.conductoresEndpoint}/${conductor.id}',
      body: conductor.toJson(),
    );
    return Conductor.fromJson(response);
  }

  Future<void> deleteConductor(String id) async {
    await _delete('${ApiConfig.conductoresEndpoint}/$id');
  }

  Future<List<Conductor>> getAvailableConductores() async {
    final response = await _get(ApiConfig.conductoresDisponiblesEndpoint);
    return (response as List).map((json) => Conductor.fromJson(json)).toList();
  }

  Future<Conductor> updateConductorLocation(String id, double latitud, double longitud) async {
    final response = await _post(
      '${ApiConfig.conductoresEndpoint}/$id/ubicacion?latitud=$latitud&longitud=$longitud',
    );
    return Conductor.fromJson(response);
  }

  // Vehiculo API methods
  Future<List<Vehiculo>> getVehiculos() async {
    final response = await _get(ApiConfig.vehiculosEndpoint);
    return (response as List).map((json) => Vehiculo.fromJson(json)).toList();
  }

  Future<Vehiculo> getVehiculoById(String id) async {
    final response = await _get('${ApiConfig.vehiculosEndpoint}/$id');
    return Vehiculo.fromJson(response);
  }

  Future<Vehiculo> createVehiculo(Vehiculo vehiculo) async {
    final response = await _post(
      ApiConfig.vehiculosEndpoint,
      body: vehiculo.toJson(),
    );
    return Vehiculo.fromJson(response);
  }

  Future<Vehiculo> updateVehiculo(Vehiculo vehiculo) async {
    final response = await _put(
      '${ApiConfig.vehiculosEndpoint}/${vehiculo.id}',
      body: vehiculo.toJson(),
    );
    return Vehiculo.fromJson(response);
  }

  Future<void> deleteVehiculo(String id) async {
    await _delete('${ApiConfig.vehiculosEndpoint}/$id');
  }

  // Pedido API methods
  Future<List<Pedido>> getPedidos() async {
    final response = await _get(ApiConfig.pedidosEndpoint);
    return (response as List).map((json) => Pedido.fromJson(json)).toList();
  }

  Future<Pedido> getPedidoById(String id) async {
    final response = await _get('${ApiConfig.pedidosEndpoint}/$id');
    return Pedido.fromJson(response);
  }

  Future<Pedido> createPedido(Pedido pedido) async {
    final response = await _post(
      ApiConfig.pedidosEndpoint,
      body: pedido.toJson(),
    );
    return Pedido.fromJson(response);
  }

  Future<Pedido> updatePedido(Pedido pedido) async {
    final response = await _put(
      '${ApiConfig.pedidosEndpoint}/${pedido.id}',
      body: pedido.toJson(),
    );
    return Pedido.fromJson(response);
  }

  Future<void> deletePedido(String id) async {
    await _delete('${ApiConfig.pedidosEndpoint}/$id');
  }

  // Envio API methods
  Future<List<Envio>> getEnvios() async {
    final response = await _get(ApiConfig.enviosEndpoint);
    return (response as List).map((json) => Envio.fromJson(json)).toList();
  }

  Future<Envio> getEnvioById(String id) async {
    final response = await _get('${ApiConfig.enviosEndpoint}/$id');
    return Envio.fromJson(response);
  }

  Future<Envio> updateEnvio(Envio envio) async {
    final response = await _put(
      '${ApiConfig.enviosEndpoint}/${envio.id}',
      body: envio.toJson(),
    );
    return Envio.fromJson(response);
  }

  Future<void> deleteEnvio(String id) async {
    await _delete('${ApiConfig.enviosEndpoint}/$id');
  }

  Future<Envio> assignEnvioToPedido(String pedidoId) async {
    final response = await _post('${ApiConfig.enviosEndpoint}/asignar/$pedidoId');
    return Envio.fromJson(response);
  }

  Future<Envio> registerDelivery(String envioId, {String? codigoQrEntrega, String? firmaDigitalEntrega}) async {
    String endpoint = '${ApiConfig.enviosEndpoint}/registrar-entrega/$envioId';
    
    if (codigoQrEntrega != null) {
      endpoint += '?codigoQrEntrega=$codigoQrEntrega';
    }
    
    if (firmaDigitalEntrega != null) {
      endpoint += endpoint.contains('?') ? '&' : '?';
      endpoint += 'firmaDigitalEntrega=$firmaDigitalEntrega';
    }
    
    final response = await _post(endpoint);
    return Envio.fromJson(response);
  }

  Future<Envio> updateDeliveryLocation(String envioId, double latitud, double longitud) async {
    final response = await _post(
      '${ApiConfig.enviosEndpoint}/$envioId/ubicacion?latitud=$latitud&longitud=$longitud',
    );
    return Envio.fromJson(response);
  }

  Future<List<Envio>> getDeliveryHistoryByConductor(String conductorId) async {
    final response = await _get('${ApiConfig.enviosEndpoint}/historial/conductor/$conductorId');
    return (response as List).map((json) => Envio.fromJson(json)).toList();
  }

  Future<List<Envio>> getDeliveryHistoryByCliente(String clienteId) async {
    final response = await _get('${ApiConfig.enviosEndpoint}/historial/cliente/$clienteId');
    return (response as List).map((json) => Envio.fromJson(json)).toList();
  }

  Future<List<Envio>> getDeliveryHistoryByDateRange(DateTime inicio, DateTime fin) async {
    final response = await _get(
      '${ApiConfig.enviosEndpoint}/historial/fechas?inicio=${inicio.toIso8601String()}&fin=${fin.toIso8601String()}',
    );
    return (response as List).map((json) => Envio.fromJson(json)).toList();
  }
}

