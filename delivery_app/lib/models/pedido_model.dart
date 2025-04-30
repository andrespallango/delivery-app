import 'package:delivery_app/models/cliente_model.dart';

class Pedido {
  final String? id;
  final String numeroPedido;
  final String estado;
  final DateTime fechaEntregaEstimada;
  final Cliente cliente;

  Pedido({
    this.id,
    required this.numeroPedido,
    required this.estado,
    required this.fechaEntregaEstimada,
    required this.cliente,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      numeroPedido: json['numeroPedido'],
      estado: json['estado'],
      fechaEntregaEstimada: DateTime.parse(json['fechaEntregaEstimada']),
      cliente: Cliente.fromJson(json['cliente']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'numeroPedido': numeroPedido,
      'estado': estado,
      'fechaEntregaEstimada': fechaEntregaEstimada.toIso8601String(),
      'cliente': {'id': cliente.id},
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }

  Pedido copyWith({
    String? id,
    String? numeroPedido,
    String? estado,
    DateTime? fechaEntregaEstimada,
    Cliente? cliente,
  }) {
    return Pedido(
      id: id ?? this.id,
      numeroPedido: numeroPedido ?? this.numeroPedido,
      estado: estado ?? this.estado,
      fechaEntregaEstimada: fechaEntregaEstimada ?? this.fechaEntregaEstimada,
      cliente: cliente ?? this.cliente,
    );
  }
}

