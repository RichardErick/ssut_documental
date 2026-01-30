import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/carpeta.dart';
import '../../../models/user_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/carpeta_service.dart';
import '../../../controllers/carpetas/carpetas_controller.dart';
import '../carpeta_form_screen.dart';
import '../documentos_list_screen.dart';

/// View for displaying Carpetas (Folders) organized by modules
class CarpetasView extends StatefulWidget {
  const CarpetasView({super.key});

  @override
  State<CarpetasView> createState() => _CarpetasViewState();
}

class _CarpetasViewState extends State<CarpetasView> {
  late CarpetasController _controller;
  String _gestionSeleccionada = '2025';
  
  // Constantes para módulos
  static const String _moduloEgresos = 'Comprobante de Egreso';
  static const String _moduloIngresos = 'Comprobante de Ingreso';
  static const List<String> _gestionesVisibles = ['2024', '2025', '2026'];

  bool get _hasMainFolder {
    final carpetas = _getCarpetasForGestion(_gestionSeleccionada);
    return carpetas.any((c) => c.carpetaPadreId == null);
  }

  List<Carpeta> _getCarpetasForGestion(String gestion) {
    return _controller.carpetas.where((c) => c.gestion == gestion).toList();
  }

  @override
  void initState() {
    super.initState();
    final carpetaService = Provider.of<CarpetaService>(context, listen: false);
    _controller = CarpetasController(service: carpetaService);
    _controller.cargarCarpetas();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _crearCarpeta({int? padreId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarpetaFormScreen(padreId: padreId),
      ),
    );

    if (result == true) {
      // Reload data
      await _controller.cargarCarpetas();
      
      // Force UI refresh
      if (mounted) {
        setState(() {});
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carpeta creada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Gestión Documental', style: GoogleFonts.poppins()),
            actions: [
              // Filter by gestion
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: _gestionSeleccionada,
                  dropdownColor: Colors.white,
                  style: GoogleFonts.poppins(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                  underline: Container(),
                  items: _gestionesVisibles.map((gestion) {
                    return DropdownMenuItem(
                      value: gestion,
                      child: Text('Gestión $gestion'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _gestionSeleccionada = value);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _controller.cargarCarpetas,
              ),
            ],
          ),
          floatingActionButton: _controller.carpetas.isEmpty || !_hasMainFolder
              ? FloatingActionButton.extended(
                  onPressed: () => _crearCarpeta(),
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text('Crear Módulo'),
                  backgroundColor: Colors.amber.shade800,
                )
              : null,
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _controller.cargarCarpetas,
                  child: _buildModularView(),
                ),
        );
      },
    );
  }

  Widget _buildModularView() {
    final carpetas = _getCarpetasForGestion(_gestionSeleccionada);

    // Separate by modules
    final carpetaEgresos = carpetas
        .where((c) => c.nombre == _moduloEgresos)
        .firstOrNull;
    final carpetaIngresos = carpetas
        .where((c) => c.nombre == _moduloIngresos)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main title
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Text(
                'GESTIÓN $_gestionSeleccionada',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Organizado por Módulos',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Egresos Module
        if (carpetaEgresos != null)
          _buildModuloCard(
            _moduloEgresos,
            carpetaEgresos,
            Colors.red,
            Icons.arrow_upward,
          ),

        const SizedBox(height: 16),

        // Ingresos Module
        if (carpetaIngresos != null)
          _buildModuloCard(
            _moduloIngresos,
            carpetaIngresos,
            Colors.green,
            Icons.arrow_downward,
          ),

        // Empty state
        if (carpetaEgresos == null && carpetaIngresos == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.folder_off_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No hay módulos para esta gestión',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModuloCard(
      String nombre, Carpeta carpeta, Color color, IconData icon) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final canDelete = authProvider.hasPermission('borrar_documento') || 
                      authProvider.role == UserRole.administradorSistema;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Module header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        '${carpeta.subcarpetas.length} subcarpetas',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // DELETE MODULE BUTTON - MUY VISIBLE
                if (canDelete)
                  ElevatedButton.icon(
                    onPressed: () => _confirmarEliminarCarpeta(carpeta),
                    icon: const Icon(Icons.delete_forever, size: 20),
                    label: const Text('BORRAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                  ),
              ],
            ),
          ),
          // Subcarpetas
          if (carpeta.subcarpetas.isNotEmpty)
            ...carpeta.subcarpetas.map((sub) => _buildSubcarpetaItem(sub, color, canDelete))
          else
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No hay subcarpetas en este módulo',
                style: GoogleFonts.poppins(color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcarpetaItem(Carpeta subcarpeta, Color moduleColor, bool canDelete) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: moduleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.folder_open, color: moduleColor, size: 24),
        ),
        title: Text(
          subcarpeta.nombre,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documentos: ${subcarpeta.numeroDocumentos}',
              style:
                  GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (subcarpeta.rangoInicio != null && subcarpeta.rangoFin != null)
              Text(
                'Rango: ${subcarpeta.rangoInicio} - ${subcarpeta.rangoFin}',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.grey.shade500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DELETE SUBCARPETA BUTTON - MUY VISIBLE
            if (canDelete)
              ElevatedButton.icon(
                onPressed: () => _confirmarEliminarCarpeta(subcarpeta),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('BORRAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DocumentosListScreen(initialCarpetaId: subcarpeta.id),
            ),
          ).then((_) => _controller.cargarCarpetas());
        },
      ),
    );
  }

  Future<void> _confirmarEliminarCarpeta(Carpeta carpeta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar carpeta'),
        content: Text(
          '¿Estás seguro de eliminar la carpeta "${carpeta.nombre}"?\n\n'
          'Se eliminarán también sus subcarpetas y documentos (borrado permanente).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Borrar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _eliminarCarpeta(carpeta);
    }
  }

  Future<void> _eliminarCarpeta(Carpeta carpeta) async {
    try {
      await _controller.eliminarCarpeta(carpeta);
      if (!mounted) return;
      
      // Force UI refresh
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carpeta eliminada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
