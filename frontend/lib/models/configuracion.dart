class Configuracion {
  final int id;
  final String clave;
  final String? valor;
  final String? descripcion;
  final String tipoDato;
  final bool editable;
  final DateTime fechaActualizacion;
  final int? actualizadoPor;
  final String? actualizadoPorNombre;

  Configuracion({
    required this.id,
    required this.clave,
    this.valor,
    this.descripcion,
    required this.tipoDato,
    required this.editable,
    required this.fechaActualizacion,
    this.actualizadoPor,
    this.actualizadoPorNombre,
  });

  factory Configuracion.fromJson(Map<String, dynamic> json) {
    return Configuracion(
      id: json['id'],
      clave: json['clave'],
      valor: json['valor'],
      descripcion: json['descripcion'],
      tipoDato: json['tipoDato'] ?? 'string',
      editable: json['editable'] ?? true,
      fechaActualizacion: DateTime.parse(json['fechaActualizacion']),
      actualizadoPor: json['actualizadoPor'],
      actualizadoPorNombre: json['actualizadoPorNombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clave': clave,
      'valor': valor,
      'descripcion': descripcion,
      'tipoDato': tipoDato,
      'editable': editable,
    };
  }
}

class CreateConfiguracionDTO {
  final String clave;
  final String? valor;
  final String? descripcion;
  final String tipoDato;
  final bool editable;

  CreateConfiguracionDTO({
    required this.clave,
    this.valor,
    this.descripcion,
    this.tipoDato = 'string',
    this.editable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'clave': clave,
      'valor': valor,
      'descripcion': descripcion,
      'tipoDato': tipoDato,
      'editable': editable,
    };
  }
}

class UpdateConfiguracionDTO {
  final String? valor;
  final String? descripcion;
  final bool? editable;

  UpdateConfiguracionDTO({this.valor, this.descripcion, this.editable});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (valor != null) map['valor'] = valor;
    if (descripcion != null) map['descripcion'] = descripcion;
    if (editable != null) map['editable'] = editable;
    return map;
  }
}
