class TipoDocumento {
  final int id;
  final String nombre;
  final String? codigo;
  final String? descripcion;
  final bool activo;

  TipoDocumento({
    required this.id,
    required this.nombre,
    this.codigo,
    this.descripcion,
    required this.activo,
  });

  factory TipoDocumento.fromJson(Map<String, dynamic> json) {
    return TipoDocumento(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}

class CreateTipoDocumentoDTO {
  final String nombre;
  final String? codigo;
  final String? descripcion;
  final bool activo;

  CreateTipoDocumentoDTO({
    required this.nombre,
    this.codigo,
    this.descripcion,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
