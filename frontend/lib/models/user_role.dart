enum UserRole {
  administradorSistema,
  administradorDocumentos,
  archivoCentral,
  tramiteDocumentario,
  invitado;

  String get displayName {
    switch (this) {
      case UserRole.administradorSistema:
        return 'Admin Sistema';
      case UserRole.administradorDocumentos:
        return 'Admin Documentos';
      case UserRole.archivoCentral:
        return 'Archivo Central';
      case UserRole.tramiteDocumentario:
        return 'Trámite Doc.';
      default:
        return 'Invitado';
    }
  }
}
