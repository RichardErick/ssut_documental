import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/carpeta.dart';
import '../../services/carpeta_service.dart';

class CarpetaFormScreen extends StatefulWidget {
  final int? padreId;
  final Carpeta? carpetaExistente; // Para edición futura si se requiere

  const CarpetaFormScreen({super.key, this.padreId, this.carpetaExistente});

  @override
  State<CarpetaFormScreen> createState() => _CarpetaFormScreenState();
}

class _CarpetaFormScreenState extends State<CarpetaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  static const String _nombreCarpetaPermitida = 'Comprobante de Egreso';
  
  // Controladores
  final _nombreController = TextEditingController(); // Para nombre o rango
  final _gestionController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Rangos (solo para subcarpetas)
  final _rangoInicioController = TextEditingController();
  final _rangoFinController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gestionController.text = DateTime.now().year.toString();
    
    if (widget.padreId == null) {
      // Es carpeta principal
      _nombreController.text = _nombreCarpetaPermitida;
    } else {
      // Es subcarpeta
      _nombreController.text = 'Rango Documental';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _gestionController.dispose();
    _descripcionController.dispose();
    _rangoInicioController.dispose();
    _rangoFinController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final carpetaService = Provider.of<CarpetaService>(context, listen: false);
      
      // Validaciones especificas
      if (widget.padreId == null) {
        // Verificar si ya existe carpeta principal del año
        final carpetas = await carpetaService.getAll(gestion: _gestionController.text);
        if (carpetas.any((c) => c.nombre == _nombreCarpetaPermitida && c.carpetaPadreId == null)) {
           throw Exception('Ya existe una carpeta "$_nombreCarpetaPermitida" para la gestión ${_gestionController.text}.');
        }
      }

      int? rInicio = int.tryParse(_rangoInicioController.text);
      int? rFin = int.tryParse(_rangoFinController.text);
      String nombreFinal = _nombreController.text;

      if (widget.padreId != null) {
        if (rInicio == null || rFin == null) {
           throw Exception('Debe especificar Rango Inicio y Fin para subcarpetas.');
        }
        nombreFinal = 'Rango $rInicio - $rFin';
      }

      final dto = CreateCarpetaDTO(
        nombre: nombreFinal,
        codigo: null,
        gestion: _gestionController.text,
        descripcion: _descripcionController.text,
        carpetaPadreId: widget.padreId,
        rangoInicio: rInicio,
        rangoFin: rFin,
      );

      await carpetaService.create(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carpeta creada exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Retornar true para recargar
      }

    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception:", "")}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esPrincipal = widget.padreId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esPrincipal ? 'Nueva Carpeta Principal' : 'Nueva Subcarpeta',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(theme, esPrincipal),
                  const SizedBox(height: 24),

                  if (esPrincipal) ...[
                    TextFormField(
                      controller: _nombreController,
                      readOnly: true,
                      decoration: _inputDecoration('Nombre de Carpeta', icon: Icons.folder),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solo se permite crear carpetas de tipo "Comprobante de Egreso".',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ] else ...[
                     TextFormField(
                      controller: _nombreController,
                      decoration: _inputDecoration('Nombre Referencial', icon: Icons.folder_open),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rangoInicioController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Rango Inicio', icon: Icons.start),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _rangoFinController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Rango Fin', icon: Icons.last_page),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _gestionController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: _inputDecoration('Gestión (Año)', icon: Icons.calendar_today),
                    validator: (v) => v!.length != 4 ? 'Año inválido' : null,
                  ),
                  
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: _inputDecoration('Descripción / Observaciones', icon: Icons.notes),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: esPrincipal ? Colors.amber.shade800 : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(
                        'Crear Carpeta',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, bool esPrincipal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esPrincipal ? Colors.amber.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esPrincipal ? Colors.amber.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            esPrincipal ? Icons.folder_special : Icons.folder_copy,
            size: 32,
            color: esPrincipal ? Colors.amber.shade800 : Colors.blue.shade700,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esPrincipal ? 'Carpeta Maestra' : 'Subcarpeta de Archivo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: esPrincipal ? Colors.amber.shade900 : Colors.blue.shade900,
                  ),
                ),
                Text(
                  esPrincipal 
                    ? 'Contenedor principal para los comprobantes de una gestión.'
                    : 'Agrupación de documentos por rango numérico.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey.shade600) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
