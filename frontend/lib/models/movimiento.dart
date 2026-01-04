class Movimiento {
  final int id;
  final int documentoId;
  final String? documentoCodigo;
  final String tipoMovimiento;
  final int? areaOrigenId;
  final String? areaOrigenNombre;
  final int? areaDestinoId;
  final String? areaDestinoNombre;
  final int? usuarioId;
  final String? usuarioNombre;
  final String? observaciones;
  final DateTime fechaMovimiento;
  final DateTime? fechaDevolucion;
  final String estado;

  Movimiento({
    required this.id,
    required this.documentoId,
    this.documentoCodigo,
    required this.tipoMovimiento,
    this.areaOrigenId,
    this.areaOrigenNombre,
    this.areaDestinoId,
    this.areaDestinoNombre,
    this.usuarioId,
    this.usuarioNombre,
    this.observaciones,
    required this.fechaMovimiento,
    this.fechaDevolucion,
    required this.estado,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      documentoId: json['documentoId'],
      documentoCodigo: json['documentoCodigo'],
      tipoMovimiento: json['tipoMovimiento'],
      areaOrigenId: json['areaOrigenId'],
      areaOrigenNombre: json['areaOrigenNombre'],
      areaDestinoId: json['areaDestinoId'],
      areaDestinoNombre: json['areaDestinoNombre'],
      usuarioId: json['usuarioId'],
      usuarioNombre: json['usuarioNombre'],
      observaciones: json['observaciones'],
      fechaMovimiento: DateTime.parse(json['fechaMovimiento']),
      fechaDevolucion:
          json['fechaDevolucion'] != null
              ? DateTime.parse(json['fechaDevolucion'])
              : null,
      estado: json['estado'],
    );
  }
}

class CreateMovimientoDTO {
  final int documentoId;
  final String tipoMovimiento;
  final int? areaOrigenId;
  final int? areaDestinoId;
  final int? usuarioId;
  final String? observaciones;

  CreateMovimientoDTO({
    required this.documentoId,
    required this.tipoMovimiento,
    this.areaOrigenId,
    this.areaDestinoId,
    this.usuarioId,
    this.observaciones,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentoId': documentoId,
      'tipoMovimiento': tipoMovimiento,
      'areaOrigenId': areaOrigenId,
      'areaDestinoId': areaDestinoId,
      'usuarioId': usuarioId,
      'observaciones': observaciones,
    };
  }
}
