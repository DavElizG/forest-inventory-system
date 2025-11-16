import 'package:equatable/equatable.dart';

class Arbol extends Equatable {
  final int? id;
  final String codigo;
  final int especieId;
  final int parcelaId;
  final double dap;
  final double altura;
  final double latitud;
  final double longitud;
  final String? fotoPath;
  final String? observaciones;
  final String estado;
  final DateTime fechaMedicion;
  final bool sincronizado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Arbol({
    this.id,
    required this.codigo,
    required this.especieId,
    required this.parcelaId,
    required this.dap,
    required this.altura,
    required this.latitud,
    required this.longitud,
    this.fotoPath,
    this.observaciones,
    required this.estado,
    required this.fechaMedicion,
    this.sincronizado = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        codigo,
        especieId,
        parcelaId,
        dap,
        altura,
        latitud,
        longitud,
        fotoPath,
        observaciones,
        estado,
        fechaMedicion,
        sincronizado,
        createdAt,
        updatedAt,
      ];

  Arbol copyWith({
    int? id,
    String? codigo,
    int? especieId,
    int? parcelaId,
    double? dap,
    double? altura,
    double? latitud,
    double? longitud,
    String? fotoPath,
    String? observaciones,
    String? estado,
    DateTime? fechaMedicion,
    bool? sincronizado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Arbol(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      especieId: especieId ?? this.especieId,
      parcelaId: parcelaId ?? this.parcelaId,
      dap: dap ?? this.dap,
      altura: altura ?? this.altura,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fotoPath: fotoPath ?? this.fotoPath,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      fechaMedicion: fechaMedicion ?? this.fechaMedicion,
      sincronizado: sincronizado ?? this.sincronizado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
