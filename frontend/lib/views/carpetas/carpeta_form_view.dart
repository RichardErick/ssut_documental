import 'package:flutter/material.dart';

/// Vista de formulario de carpeta (stub - pendiente implementación completa)
class CarpetaFormView extends StatelessWidget {
  final int? padreId;
  final int? carpetaId;

  const CarpetaFormView({
    super.key,
    this.padreId,
    this.carpetaId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar formulario usando CarpetasController
    return Scaffold(
      appBar: AppBar(
        title: Text(carpetaId == null ? 'Nueva Carpeta' : 'Editar Carpeta'),
      ),
      body: const Center(
        child: Text('Vista en construcción - Usar CarpetasController'),
      ),
    );
  }
}
