class Alerta {
  final int id;
  final int? usuarioId;
  final String? usuarioNombre;
  final String titulo;
  final String mensaje;
  final String tipoAlerta;
  final bool leida;
  final DateTime fechaCreacion;
  final DateTime? fechaLectura;
  final int? documentoId;
  final String? documentoCodigo;
  final int? movimientoId;

  Alerta({
    required this.id,
    this.usuarioId,
    this.usuarioNombre,
    required this.titulo,
    required this.mensaje,
    required this.tipoAlerta,
    required this.leida,
    required this.fechaCreacion,
    this.fechaLectura,
    this.documentoId,
    this.documentoCodigo,
    this.movimientoId,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id'],
      usuarioId: json['usuarioId'],
      usuarioNombre: json['usuarioNombre'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      tipoAlerta: json['tipoAlerta'] ?? 'info',
      leida: json['leida'] ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaLectura:
          json['fechaLectura'] != null
              ? DateTime.parse(json['fechaLectura'])
              : null,
      documentoId: json['documentoId'],
      documentoCodigo: json['documentoCodigo'],
      movimientoId: json['movimientoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipoAlerta': tipoAlerta,
      'leida': leida,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaLectura': fechaLectura?.toIso8601String(),
      'documentoId': documentoId,
      'movimientoId': movimientoId,
    };
  }
}

class CreateAlertaDTO {
  final int? usuarioId;
  final String titulo;
  final String mensaje;
  final String tipoAlerta;
  final int? documentoId;
  final int? movimientoId;

  CreateAlertaDTO({
    this.usuarioId,
    required this.titulo,
    required this.mensaje,
    this.tipoAlerta = 'info',
    this.documentoId,
    this.movimientoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipoAlerta': tipoAlerta,
      'documentoId': documentoId,
      'movimientoId': movimientoId,
    };
  }
}

class MarkAlertaLeidaDTO {
  final bool leida;

  MarkAlertaLeidaDTO({this.leida = true});

  Map<String, dynamic> toJson() {
    return {'leida': leida};
  }
}
