class Anexo {
  final int id;
  final int documentoId;
  final String? documentoCodigo;
  final String nombreArchivo;
  final String? extension;
  final int? tamano;
  final String? urlArchivo;
  final String? tipoContenido;
  final DateTime fechaRegistro;
  final bool activo;

  Anexo({
    required this.id,
    required this.documentoId,
    this.documentoCodigo,
    required this.nombreArchivo,
    this.extension,
    this.tamano,
    this.urlArchivo,
    this.tipoContenido,
    required this.fechaRegistro,
    required this.activo,
  });

  factory Anexo.fromJson(Map<String, dynamic> json) {
    return Anexo(
      id: json['id'],
      documentoId: json['documentoId'],
      documentoCodigo: json['documentoCodigo'],
      nombreArchivo: json['nombreArchivo'],
      extension: json['extension'],
      tamano: json['tamano'],
      urlArchivo: json['urlArchivo'],
      tipoContenido: json['tipoContenido'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentoId': documentoId,
      'nombreArchivo': nombreArchivo,
      'extension': extension,
      'tamano': tamano,
      'urlArchivo': urlArchivo,
      'tipoContenido': tipoContenido,
      'activo': activo,
    };
  }
}

class CreateAnexoDTO {
  final int documentoId;
  final String nombreArchivo;
  final String? extension;
  final int? tamano;
  final String? urlArchivo;
  final String? tipoContenido;

  CreateAnexoDTO({
    required this.documentoId,
    required this.nombreArchivo,
    this.extension,
    this.tamano,
    this.urlArchivo,
    this.tipoContenido,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentoId': documentoId,
      'nombreArchivo': nombreArchivo,
      'extension': extension,
      'tamano': tamano,
      'urlArchivo': urlArchivo,
      'tipoContenido': tipoContenido,
    };
  }
}
