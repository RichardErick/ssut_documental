import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/reporte_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/glass_container.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  Map<String, dynamic>? _estadisticas;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstadisticas();
  }

  Future<void> _loadEstadisticas() async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ReporteService>(context, listen: false);
      final stats = await service.obtenerEstadisticas();
      setState(() {
        _estadisticas = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estadísticas: $e'),
            backgroundColor: AppTheme.colorError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? _buildLoadingState()
          : _estadisticas == null
              ? const Center(child: Text('No hay datos disponibles'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme),
                      const SizedBox(height: 40),
                      _buildStatGrid(isDesktop),
                      const SizedBox(height: 40),
                      _buildDetailedReports(theme, isDesktop),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colorPrimario)),
          const SizedBox(height: 24),
          Text('Analizando datos...', style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PANEL DE ESTADÍSTICAS',
          style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
        ),
        Text(
          'Resumen general del estado de la documentación',
          style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildStatGrid(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildStatCard(
              'Total Documentos',
              '${_estadisticas!['totalDocumentos']}',
              Icons.description_rounded,
              AppTheme.colorPrimario,
              constraints.maxWidth,
              isDesktop,
            ),
            _buildStatCard(
              'Documentos Activos',
              '${_estadisticas!['documentosActivos']}',
              Icons.verified_rounded,
              AppTheme.colorExito,
              constraints.maxWidth,
              isDesktop,
            ),
            _buildStatCard(
              'En Préstamo',
              '${_estadisticas!['documentosPrestados']}',
              Icons.pending_actions_rounded,
              AppTheme.colorAdvertencia,
              constraints.maxWidth,
              isDesktop,
            ),
            _buildStatCard(
              'Movimientos Mes',
              '${_estadisticas!['movimientosMes']}',
              Icons.auto_graph_rounded,
              Colors.purple,
              constraints.maxWidth,
              isDesktop,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double maxWidth, bool isDesktop) {
    // Responsive width calculation
    double width;
    if (isDesktop) {
       // 4 items per row on desktop
       width = (maxWidth - (24 * 3)) / 4; 
    } else if (maxWidth > 600) {
      // 2 items per row on tablet
      width = (maxWidth - 24) / 2;
    } else {
      // 1 item per row on mobile
      width = maxWidth;
    }

    return Container(
      width: width,
      child: AnimatedCard(
        delay: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                duration: const Duration(milliseconds: 1500),
                builder: (context, val, _) => Text(
                  val.toString(),
                  style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedReports(ThemeData theme, bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildTypeReportList(theme),
        ),
        if (isDesktop) ...[
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(child: _buildExportSection(theme)),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeReportList(ThemeData theme) {
    final types = (_estadisticas!['documentosPorTipo'] as Map? ?? {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DISTRIBUCIÓN POR TIPO', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: types.entries.map((e) => _buildTypeTile(e.key.toString(), e.value.toString(), theme)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeTile(String name, String value, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.folder_open_rounded, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      trailing: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)),
    );
  }

  Widget _buildExportSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.colorPrimario, AppTheme.colorSecundario], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.colorPrimario.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 48),
          const SizedBox(height: 24),
          Text(
            'Generar Reporte Mensual',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            'Obtén un resumen detallado en formato PDF para impresión o auditoría.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.colorPrimario,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('DESCARGAR PDF', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

