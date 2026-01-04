class Documento {
  final int id;
  final String codigo;
  final String numeroCorrelativo;
  final int tipoDocumentoId;
  final String? tipoDocumentoNombre;
  final int areaOrigenId;
  final String? areaOrigenNombre;
  final String gestion;
  final DateTime fechaDocumento;
  final String? descripcion;
  final int? responsableId;
  final String? responsableNombre;
  final String? codigoQR;
  final String? ubicacionFisica;
  final String estado;
  final DateTime fechaRegistro;

  Documento({
    required this.id,
    required this.codigo,
    required this.numeroCorrelativo,
    required this.tipoDocumentoId,
    this.tipoDocumentoNombre,
    required this.areaOrigenId,
    this.areaOrigenNombre,
    required this.gestion,
    required this.fechaDocumento,
    this.descripcion,
    this.responsableId,
    this.responsableNombre,
    this.codigoQR,
    this.ubicacionFisica,
    required this.estado,
    required this.fechaRegistro,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'],
      codigo: json['codigo'],
      numeroCorrelativo: json['numeroCorrelativo'],
      tipoDocumentoId: json['tipoDocumentoId'],
      tipoDocumentoNombre: json['tipoDocumentoNombre'],
      areaOrigenId: json['areaOrigenId'],
      areaOrigenNombre: json['areaOrigenNombre'],
      gestion: json['gestion'],
      fechaDocumento: DateTime.parse(json['fechaDocumento']),
      descripcion: json['descripcion'],
      responsableId: json['responsableId'],
      responsableNombre: json['responsableNombre'],
      codigoQR: json['codigoQR'],
      ubicacionFisica: json['ubicacionFisica'],
      estado: json['estado'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'numeroCorrelativo': numeroCorrelativo,
      'tipoDocumentoId': tipoDocumentoId,
      'areaOrigenId': areaOrigenId,
      'gestion': gestion,
      'fechaDocumento': fechaDocumento.toIso8601String(),
      'descripcion': descripcion,
      'responsableId': responsableId,
      'ubicacionFisica': ubicacionFisica,
    };
  }
}

class CreateDocumentoDTO {
  final String numeroCorrelativo;
  final int tipoDocumentoId;
  final int areaOrigenId;
  final String gestion;
  final DateTime fechaDocumento;
  final String? descripcion;
  final int? responsableId;
  final String? ubicacionFisica;

  CreateDocumentoDTO({
    required this.numeroCorrelativo,
    required this.tipoDocumentoId,
    required this.areaOrigenId,
    required this.gestion,
    required this.fechaDocumento,
    this.descripcion,
    this.responsableId,
    this.ubicacionFisica,
  });

  Map<String, dynamic> toJson() {
    return {
      'numeroCorrelativo': numeroCorrelativo,
      'tipoDocumentoId': tipoDocumentoId,
      'areaOrigenId': areaOrigenId,
      'gestion': gestion,
      'fechaDocumento': fechaDocumento.toIso8601String(),
      'descripcion': descripcion,
      'responsableId': responsableId,
      'ubicacionFisica': ubicacionFisica,
    };
  }
}

class BusquedaDocumentoDTO {
  final String? codigo;
  final String? numeroCorrelativo;
  final int? tipoDocumentoId;
  final int? areaOrigenId;
  final String? gestion;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final String? estado;
  final String? codigoQR;

  BusquedaDocumentoDTO({
    this.codigo,
    this.numeroCorrelativo,
    this.tipoDocumentoId,
    this.areaOrigenId,
    this.gestion,
    this.fechaDesde,
    this.fechaHasta,
    this.estado,
    this.codigoQR,
  });

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'numeroCorrelativo': numeroCorrelativo,
      'tipoDocumentoId': tipoDocumentoId,
      'areaOrigenId': areaOrigenId,
      'gestion': gestion,
      'fechaDesde': fechaDesde?.toIso8601String(),
      'fechaHasta': fechaHasta?.toIso8601String(),
      'estado': estado,
      'codigoQR': codigoQR,
    };
  }
}
