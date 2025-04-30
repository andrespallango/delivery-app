class Cliente {
  final String? id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;

  Cliente({
    this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }

  Cliente copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? telefono,
    String? email,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }
}

