import 'package:flutter/material.dart';

/// Vista de formulario de documento (stub - pendiente implementación completa)
class DocumentoFormView extends StatelessWidget {
  final int? initialCarpetaId;
  final int? documentoId;

  const DocumentoFormView({
    super.key,
    this.initialCarpetaId,
    this.documentoId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar formulario usando un DocumentoFormController
    return Scaffold(
      appBar: AppBar(
        title: Text(documentoId == null ? 'Nuevo Documento' : 'Editar Documento'),
      ),
      body: const Center(
        child: Text('Vista en construcción - Crear DocumentoFormController'),
      ),
    );
  }
}
