class Area {
  final int id;
  final String nombre;
  final String? codigo;
  final String? descripcion;
  final bool activo;

  Area({
    required this.id,
    required this.nombre,
    this.codigo,
    this.descripcion,
    required this.activo,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
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

class CreateAreaDTO {
  final String nombre;
  final String? codigo;
  final String? descripcion;
  final bool activo;

  CreateAreaDTO({
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
