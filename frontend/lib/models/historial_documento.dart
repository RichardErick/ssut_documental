class HistorialDocumento {
  final int id;
  final int documentoId;
  final String? documentoCodigo;
  final DateTime fechaCambio;
  final int? usuarioId;
  final String? usuarioNombre;
  final String tipoCambio;
  final String? estadoAnterior;
  final String? estadoNuevo;
  final int? areaAnteriorId;
  final String? areaAnteriorNombre;
  final int? areaNuevaId;
  final String? areaNuevaNombre;
  final String? campoModificado;
  final String? valorAnterior;
  final String? valorNuevo;
  final String? observacion;

  HistorialDocumento({
    required this.id,
    required this.documentoId,
    this.documentoCodigo,
    required this.fechaCambio,
    this.usuarioId,
    this.usuarioNombre,
    required this.tipoCambio,
    this.estadoAnterior,
    this.estadoNuevo,
    this.areaAnteriorId,
    this.areaAnteriorNombre,
    this.areaNuevaId,
    this.areaNuevaNombre,
    this.campoModificado,
    this.valorAnterior,
    this.valorNuevo,
    this.observacion,
  });

  factory HistorialDocumento.fromJson(Map<String, dynamic> json) {
    return HistorialDocumento(
      id: json['id'],
      documentoId: json['documentoId'],
      documentoCodigo: json['documentoCodigo'],
      fechaCambio: DateTime.parse(json['fechaCambio']),
      usuarioId: json['usuarioId'],
      usuarioNombre: json['usuarioNombre'],
      tipoCambio: json['tipoCambio'],
      estadoAnterior: json['estadoAnterior'],
      estadoNuevo: json['estadoNuevo'],
      areaAnteriorId: json['areaAnteriorId'],
      areaAnteriorNombre: json['areaAnteriorNombre'],
      areaNuevaId: json['areaNuevaId'],
      areaNuevaNombre: json['areaNuevaNombre'],
      campoModificado: json['campoModificado'],
      valorAnterior: json['valorAnterior'],
      valorNuevo: json['valorNuevo'],
      observacion: json['observacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentoId': documentoId,
      'fechaCambio': fechaCambio.toIso8601String(),
      'usuarioId': usuarioId,
      'tipoCambio': tipoCambio,
      'estadoAnterior': estadoAnterior,
      'estadoNuevo': estadoNuevo,
      'areaAnteriorId': areaAnteriorId,
      'areaNuevaId': areaNuevaId,
      'campoModificado': campoModificado,
      'valorAnterior': valorAnterior,
      'valorNuevo': valorNuevo,
      'observacion': observacion,
    };
  }
}

class CreateHistorialDocumentoDTO {
  final int documentoId;
  final int? usuarioId;
  final String tipoCambio;
  final String? estadoAnterior;
  final String? estadoNuevo;
  final int? areaAnteriorId;
  final int? areaNuevaId;
  final String? campoModificado;
  final String? valorAnterior;
  final String? valorNuevo;
  final String? observacion;

  CreateHistorialDocumentoDTO({
    required this.documentoId,
    this.usuarioId,
    required this.tipoCambio,
    this.estadoAnterior,
    this.estadoNuevo,
    this.areaAnteriorId,
    this.areaNuevaId,
    this.campoModificado,
    this.valorAnterior,
    this.valorNuevo,
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentoId': documentoId,
      'usuarioId': usuarioId,
      'tipoCambio': tipoCambio,
      'estadoAnterior': estadoAnterior,
      'estadoNuevo': estadoNuevo,
      'areaAnteriorId': areaAnteriorId,
      'areaNuevaId': areaNuevaId,
      'campoModificado': campoModificado,
      'valorAnterior': valorAnterior,
      'valorNuevo': valorNuevo,
      'observacion': observacion,
    };
  }
}
