class Auditoria {
  final int id;
  final int? usuarioId;
  final String? usuarioNombre;
  final String accion;
  final String? tablaAfectada;
  final int? registroId;
  final String? detalle;
  final String? ipAddress;
  final DateTime fechaAccion;

  Auditoria({
    required this.id,
    this.usuarioId,
    this.usuarioNombre,
    required this.accion,
    this.tablaAfectada,
    this.registroId,
    this.detalle,
    this.ipAddress,
    required this.fechaAccion,
  });

  factory Auditoria.fromJson(Map<String, dynamic> json) {
    return Auditoria(
      id: json['id'],
      usuarioId: json['usuarioId'],
      usuarioNombre: json['usuarioNombre'],
      accion: json['accion'],
      tablaAfectada: json['tablaAfectada'],
      registroId: json['registroId'],
      detalle: json['detalle'],
      ipAddress: json['ipAddress'],
      fechaAccion: DateTime.parse(json['fechaAccion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'accion': accion,
      'tablaAfectada': tablaAfectada,
      'registroId': registroId,
      'detalle': detalle,
      'ipAddress': ipAddress,
      'fechaAccion': fechaAccion.toIso8601String(),
    };
  }
}

class BusquedaAuditoriaDTO {
  final int? usuarioId;
  final String? accion;
  final String? tablaAfectada;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  BusquedaAuditoriaDTO({
    this.usuarioId,
    this.accion,
    this.tablaAfectada,
    this.fechaDesde,
    this.fechaHasta,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'accion': accion,
      'tablaAfectada': tablaAfectada,
      'fechaDesde': fechaDesde?.toIso8601String(),
      'fechaHasta': fechaHasta?.toIso8601String(),
    };
  }
}
