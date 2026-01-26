import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/carpeta.dart';
import '../../services/carpeta_service.dart';
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
    setState(() => _isLoading = true);
    try {
      final carpetaService = Provider.of<CarpetaService>(context, listen: false);
      final carpetas = await carpetaService.getArbol(_gestion);
      setState(() => _carpetas = carpetas);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al cargar carpetas: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _crearCarpeta({int? padreId}) async {
    if (padreId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se permite crear la carpeta Comprobante de Egreso'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_carpetas.any((c) => c.nombre == _nombreCarpetaPermitida)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La carpeta Comprobante de Egreso ya existe'), backgroundColor: Colors.orange),
      );
      return;
    }
    final nombreController = TextEditingController(text: _nombreCarpetaPermitida);
    final codigoController = TextEditingController();
    final descripcionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(padreId == null ? 'Nueva Carpeta Principal' : 'Nueva Subcarpeta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Nombre *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(labelText: 'Codigo (Opcional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripcion'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty) return;
              try {
                final carpetaService = Provider.of<CarpetaService>(context, listen: false);
                await carpetaService.create(CreateCarpetaDTO(
                  nombre: nombreController.text,
                  codigo: codigoController.text.isEmpty ? null : codigoController.text,
                  gestion: _gestion,
                  descripcion: descripcionController.text,
                  carpetaPadreId: padreId,
                ));
                if (context.mounted) Navigator.pop(context);
                _loadCarpetas();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCarpetas = _carpetas.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Carpetas $_gestion', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCarpetas,
          ),
        ],
      ),
      floatingActionButton: hasCarpetas
          ? FloatingActionButton.extended(
              onPressed: () => _crearCarpeta(),
              icon: const Icon(Icons.create_new_folder),
              label: const Text('Nueva Carpeta'),
              backgroundColor: Colors.amber.shade800,
            )
          : null,
      body: _isLoading
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
            Icon(Icons.folder_off_rounded, size: 80, color: Colors.amber.shade700),
            const SizedBox(height: 16),
            Text(
              'No hay carpetas para $_gestion',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarpetaItem(Carpeta carpeta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.amber.shade100,
          child: Icon(Icons.folder_rounded, color: Colors.amber.shade800, size: 26),
        ),
        title: Text(carpeta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${carpeta.codigo ?? "S/C"} • ${carpeta.numeroDocumentos} documentos'),
        children: [
          if (carpeta.subcarpetas.isNotEmpty)
            ...carpeta.subcarpetas.map((sub) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                  leading: Icon(Icons.folder_open_rounded, color: Colors.amber.shade400),
                  title: Text(sub.nombre),
                  subtitle: Text('${sub.codigo ?? ""} • ${sub.numeroDocumentos} docs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navegar a detalles de carpeta o lista de documentos filtrada
                  },
                )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _crearCarpeta(padreId: carpeta.id),
                  icon: const Icon(Icons.add_box_outlined, size: 20),
                  label: const Text('Subcarpeta'),
                  style: TextButton.styleFrom(foregroundColor: Colors.amber.shade900),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _agregarDocumentoACarpeta(carpeta),
                  icon: const Icon(Icons.note_add_rounded, size: 20, color: Colors.white),
                  label: const Text('Agregar Documento', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
