class Usuario {
  final String id;
  final String nombreCompleto;
  final String email;
  final int rol;
  final String? organizacion;
  final bool activo;
  final DateTime? ultimoAcceso;

  Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.organizacion,
    required this.activo,
    this.ultimoAcceso,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombreCompleto: json['nombreCompleto'],
      email: json['email'],
      rol: json['rol'],
      organizacion: json['organizacion'],
      activo: json['activo'],
      ultimoAcceso: json['ultimoAcceso'] != null 
          ? DateTime.parse(json['ultimoAcceso'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'rol': rol,
      'organizacion': organizacion,
      'activo': activo,
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
    };
  }
}

class LoginResponse {
  final Usuario usuario;
  final DateTime expiresAt;

  LoginResponse({
    required this.usuario,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      usuario: Usuario.fromJson(json['usuario']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}