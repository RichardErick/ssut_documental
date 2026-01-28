import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/carpeta.dart';
import '../../services/carpeta_service.dart';
import 'carpeta_form_screen.dart';
import 'documento_form_screen.dart';

class CarpetasScreen extends StatefulWidget {
  const CarpetasScreen({super.key});

  @override
  State<CarpetasScreen> createState() => _CarpetasScreenState();
}

class _CarpetasScreenState extends State<CarpetasScreen> {
  static const String _nombreCarpetaPermitida = 'Comprobante de Egreso';
  bool _isLoading = false;
  List<Carpeta> _carpetas = [];
  String _gestion = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    _loadCarpetas();
  }

  Future<void> _loadCarpetas() async {
    print('🔄 [CARPETAS] Iniciando carga de carpetas para gestión: $_gestion');
    setState(() => _isLoading = true);
    try {
      final carpetaService = Provider.of<CarpetaService>(
        context,
        listen: false,
      );
      final carpetas = await carpetaService.getArbol(_gestion);
      print('📦 [CARPETAS] Carpetas recibidas: ${carpetas.length}');

      final ordered = [...carpetas]..sort((a, b) {
        final aIsMain = a.nombre == _nombreCarpetaPermitida;
        final bIsMain = b.nombre == _nombreCarpetaPermitida;
        if (aIsMain == bIsMain) return a.id.compareTo(b.id);
        return aIsMain ? -1 : 1;
      });

      print('📋 [CARPETAS] Carpetas ordenadas:');
      for (var carpeta in ordered) {
        print(
          '  - ID: ${carpeta.id}, Nombre: "${carpeta.nombre}", Subcarpetas: ${carpeta.subcarpetas.length}',
        );
      }

      setState(() => _carpetas = ordered);
      print('✅ [CARPETAS] Estado actualizado con ${_carpetas.length} carpetas');
    } catch (e) {
      print('❌ [CARPETAS] Error al cargar carpetas: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar carpetas: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _crearCarpeta({int? padreId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarpetaFormScreen(padreId: padreId),
      ),
    );

    if (result == true) {
      _loadCarpetas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCarpetas = _carpetas.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Carpetas', style: GoogleFonts.poppins()),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCarpetas),
        ],
      ),
      floatingActionButton:
          !hasCarpetas ||
                  !_carpetas.any((c) => c.nombre == _nombreCarpetaPermitida)
              ? FloatingActionButton.extended(
                onPressed: () => _crearCarpeta(),
                icon: const Icon(Icons.create_new_folder),
                label: const Text('Crear Comprobante Principal'),
                backgroundColor: Colors.amber.shade800,
              )
              : null,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasCarpetas
              ? RefreshIndicator(
                onRefresh: _loadCarpetas,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _carpetas.length,
                  itemBuilder: (context, index) {
                    final carpeta = _carpetas[index];
                    return _buildCarpetaItem(carpeta);
                  },
                ),
              )
              : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_rounded,
              size: 80,
              color: Colors.amber.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay carpetas para $_gestion',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea la primera carpeta para empezar a organizar documentos.',
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 260,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _crearCarpeta(),
                icon: const Icon(Icons.add_box_rounded, size: 22),
                label: const Text('Crear carpeta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarpetaSubtitle(Carpeta carpeta) {
    final gestionLine =
        carpeta.gestion.isNotEmpty ? 'Gestion ${carpeta.gestion}' : null;
    final nroLine =
        carpeta.numeroCarpeta != null ? 'Nro ${carpeta.numeroCarpeta}' : null;
    final romano =
        (carpeta.codigoRomano ?? '').isNotEmpty
            ? carpeta.codigoRomano
            : carpeta.codigo;
    final romanoLine = (romano ?? '').isNotEmpty ? 'Romano $romano' : null;
    final rango = _formatRango(carpeta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (gestionLine != null) Text(gestionLine),
        if (nroLine != null) Text(nroLine),
        if (romanoLine != null) Text(romanoLine),
        const SizedBox(height: 4),
        Text('Documentos: ${carpeta.numeroDocumentos} - Rango: $rango'),
      ],
    );
  }

  Future<void> _confirmarEliminarCarpeta(Carpeta carpeta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar carpeta'),
            content: Text(
              '¿Estás seguro de eliminar la carpeta "${carpeta.nombre}"?\n\n'
              'Se eliminarán también sus subcarpetas y documentos (borrado permanente).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar (Conservar)'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
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
      final carpetaService = Provider.of<CarpetaService>(
        context,
        listen: false,
      );
      await carpetaService.delete(carpeta.id, hard: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carpeta eliminada (cascada)')),
      );
      _loadCarpetas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }

  Widget _buildCarpetaItem(Carpeta carpeta) {
    print(
      '🎨 [RENDER] Construyendo carpeta: ID=${carpeta.id}, Nombre="${carpeta.nombre}"',
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.folder_rounded,
            color: Colors.amber.shade800,
            size: 28,
          ),
        ),
        title: Text(
          carpeta.nombre,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: _buildCarpetaSubtitle(carpeta),
        trailing: _buildCarpetaActions(carpeta),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          if (carpeta.subcarpetas.isNotEmpty)
            ...carpeta.subcarpetas.map(
              (sub) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 24, right: 8),
                  leading: Icon(
                    Icons.folder_open_rounded,
                    color: Colors.amber.shade700,
                  ),
                  title: Text(
                    sub.nombre,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${sub.numeroDocumentos} documentos',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade700,
                          size: 22,
                        ),
                        tooltip: 'Eliminar Subcarpeta',
                        onPressed: () {
                          print(
                            '🗑️ [ACTION] Botón eliminar subcarpeta presionado: ID=${sub.id}, Nombre="${sub.nombre}"',
                          );
                          _confirmarEliminarCarpeta(sub);
                        },
                      ),
                      // Un icono visual para indicar que se puede entrar (aunque onTap está pendiente)
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navegar a detalles de carpeta o lista de documentos filtrada
                    // Por ahora mostramos un snackbar para feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Abrir subcarpeta ${sub.nombre} (Pendiente)',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (carpeta.subcarpetas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Esta carpeta está vacía',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarpetaActions(Carpeta carpeta) {
    print(
      '🔘 [ACTIONS] Construyendo botones de acción para carpeta: ID=${carpeta.id}, Nombre="${carpeta.nombre}"',
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.create_new_folder_outlined,
            color: Colors.blue.shade700,
          ),
          tooltip: 'Nueva Subcarpeta',
          onPressed: () {
            print(
              '➕ [ACTION] Botón crear subcarpeta presionado para: ID=${carpeta.id}',
            );
            _crearCarpeta(padreId: carpeta.id);
          },
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
          tooltip: 'Eliminar Carpeta',
          onPressed: () {
            print(
              '🗑️ [ACTION] Botón eliminar carpeta presionado: ID=${carpeta.id}, Nombre="${carpeta.nombre}"',
            );
            _confirmarEliminarCarpeta(carpeta);
          },
        ),
        // Icono para indicar expansión manualmente ya que overrideamos trailing
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        ),
      ],
    );
  }

  int _nextNumeroSubcarpeta(int padreId) {
    final padre = _carpetas.firstWhere((c) => c.id == padreId);
    if (padre.subcarpetas.isEmpty) return 1;
    return padre.subcarpetas.length + 1;
  }

  int _nextNumeroCarpeta() {
    if (_carpetas.isEmpty) return 1;
    final numeros =
        _carpetas.map((c) => c.numeroCarpeta).whereType<int>().toList();
    if (numeros.isEmpty) return _carpetas.length + 1;
    numeros.sort();
    return numeros.last + 1;
  }

  String _formatRango(Carpeta carpeta) {
    if (carpeta.rangoInicio == null || carpeta.rangoFin == null) {
      return 'sin documentos';
    }
    return '${carpeta.rangoInicio} - ${carpeta.rangoFin}';
  }

  void _agregarDocumentoACarpeta(Carpeta carpeta) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentoFormScreen(initialCarpetaId: carpeta.id),
      ),
    );
    if (result == true) {
      _loadCarpetas();
    }
  }
}
