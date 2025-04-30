import 'package:delivery_app/models/conductor_model.dart';
import 'package:delivery_app/models/pedido_model.dart';

class Envio {
  final String? id;
  final String estadoEnvio;
  final DateTime fechaAsignacion;
  final DateTime? fechaEntregaReal;
  final String? codigoQrEntrega;
  final String? firmaDigitalEntrega;
  final Pedido pedido;
  final Conductor conductor;
  final double? latitud;
  final double? longitud;

  Envio({
    this.id,
    required this.estadoEnvio,
    required this.fechaAsignacion,
    this.fechaEntregaReal,
    this.codigoQrEntrega,
    this.firmaDigitalEntrega,
    required this.pedido,
    required this.conductor,
    this.latitud,
    this.longitud,
  });

  factory Envio.fromJson(Map<String, dynamic> json) {
    return Envio(
      id: json['id'],
      estadoEnvio: json['estadoEnvio'],
      fechaAsignacion: DateTime.parse(json['fechaAsignacion']),
      fechaEntregaReal: json['fechaEntregaReal'] != null 
          ? DateTime.parse(json['fechaEntregaReal']) 
          : null,
      codigoQrEntrega: json['codigoQrEntrega'],
      firmaDigitalEntrega: json['firmaDigitalEntrega'],
      pedido: Pedido.fromJson(json['pedido']),
      conductor: Conductor.fromJson(json['conductor']),
      latitud: json['latitud'],
      longitud: json['longitud'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'estadoEnvio': estadoEnvio,
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }

  Envio copyWith({
    String? id,
    String? estadoEnvio,
    DateTime? fechaAsignacion,
    DateTime? fechaEntregaReal,
    String? codigoQrEntrega,
    String? firmaDigitalEntrega,
    Pedido? pedido,
    Conductor? conductor,
    double? latitud,
    double? longitud,
  }) {
    return Envio(
      id: id ?? this.id,
      estadoEnvio: estadoEnvio ?? this.estadoEnvio,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      fechaEntregaReal: fechaEntregaReal ?? this.fechaEntregaReal,
      codigoQrEntrega: codigoQrEntrega ?? this.codigoQrEntrega,
      firmaDigitalEntrega: firmaDigitalEntrega ?? this.firmaDigitalEntrega,
      pedido: pedido ?? this.pedido,
      conductor: conductor ?? this.conductor,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
    );
  }
}

