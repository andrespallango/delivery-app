import 'package:delivery_app/models/vehiculo_model.dart';

class Conductor {
  final String? id;
  final String nombre;
  final String apellido;
  final bool disponible;
  final Vehiculo? vehiculo;
  final double? latitud;
  final double? longitud;

  Conductor({
    this.id,
    required this.nombre,
    required this.apellido,
    this.disponible = true,
    this.vehiculo,
    this.latitud,
    this.longitud,
  });

  factory Conductor.fromJson(Map<String, dynamic> json) {
    return Conductor(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      disponible: json['disponible'] ?? true,
      vehiculo: json['vehiculo'] != null ? Vehiculo.fromJson(json['vehiculo']) : null,
      latitud: json['latitud'],
      longitud: json['longitud'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'apellido': apellido,
      'disponible': disponible,
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    if (vehiculo != null) {
      data['vehiculo'] = {'id': vehiculo!.id};
    } else {
      data['vehiculo'] = null;
    }
    
    return data;
  }

  Conductor copyWith({
    String? id,
    String? nombre,
    String? apellido,
    bool? disponible,
    Vehiculo? vehiculo,
    double? latitud,
    double? longitud,
  }) {
    return Conductor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      disponible: disponible ?? this.disponible,
      vehiculo: vehiculo ?? this.vehiculo,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
    );
  }
}

