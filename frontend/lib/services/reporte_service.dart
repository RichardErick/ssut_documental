import 'package:provider/provider.dart';

import '../main.dart';
import '../models/documento.dart';
import '../models/movimiento.dart';
import 'api_service.dart';

class ReporteService {
  Future<List<Movimiento>> reporteMovimientos({
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    int? areaId,
    String? tipoMovimiento,
  }) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.post(
      '/reportes/movimientos',
      data: {
        'fechaDesde': fechaDesde.toIso8601String(),
        'fechaHasta': fechaHasta.toIso8601String(),
        'areaId': areaId,
        'tipoMovimiento': tipoMovimiento,
      },
    );
    return (response.data as List)
        .map((json) => Movimiento.fromJson(json))
        .toList();
  }

  Future<List<Documento>> reporteDocumentos({
    String? gestion,
    int? tipoDocumentoId,
    int? areaOrigenId,
    String? estado,
  }) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.post(
      '/reportes/documentos',
      data: {
        'gestion': gestion,
        'tipoDocumentoId': tipoDocumentoId,
        'areaOrigenId': areaOrigenId,
        'estado': estado,
      },
    );
    return (response.data as List)
        .map((json) => Documento.fromJson(json))
        .toList();
  }

  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final apiService = Provider.of<ApiService>(
        navigatorKey.currentContext!,
        listen: false,
      );
      final response = await apiService.get('/reportes/estadisticas');
      return response.data;
    } catch (e) {
      print('API Error: $e. Returning mock stats.');
      return {
        'totalDocumentos': 1250,
        'documentosActivos': 450,
        'documentosPrestados': 12,
        'movimientosMes': 328,
        'documentosPorTipo': {
          'Informes': 450,
          'Memorandums': 300,
          'Facturas': 250,
          'Contratos': 150,
          'Otros': 100,
        },
      };
    }
  }
}
