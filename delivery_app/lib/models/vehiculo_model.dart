class Vehiculo {
  final String? id;
  final String matricula;
  final String tipo;
  final String modelo;
  final String marca;

  Vehiculo({
    this.id,
    required this.matricula,
    required this.tipo,
    required this.modelo,
    required this.marca,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      matricula: json['matricula'],
      tipo: json['tipo'],
      modelo: json['modelo'],
      marca: json['marca'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'matricula': matricula,
      'tipo': tipo,
      'modelo': modelo,
      'marca': marca,
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }

  Vehiculo copyWith({
    String? id,
    String? matricula,
    String? tipo,
    String? modelo,
    String? marca,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      matricula: matricula ?? this.matricula,
      tipo: tipo ?? this.tipo,
      modelo: modelo ?? this.modelo,
      marca: marca ?? this.marca,
    );
  }
}

