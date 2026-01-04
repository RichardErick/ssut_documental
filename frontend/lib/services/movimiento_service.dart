import 'package:provider/provider.dart';

import '../main.dart';
import '../models/movimiento.dart';
import 'api_service.dart';

class MovimientoService {
  Future<List<Movimiento>> getAll() async {
    try {
      final apiService = Provider.of<ApiService>(
        navigatorKey.currentContext!,
        listen: false,
      );
      final response = await apiService.get('/movimientos');
      return (response.data as List)
          .map((json) => Movimiento.fromJson(json))
          .toList();
    } catch (e) {
      print('API Error: $e. Returning mock movements.');
      return _getMockMovimientos();
    }
  }

  List<Movimiento> _getMockMovimientos() {
    return [
      Movimiento(
        id: 1,
        documentoId: 1,
        documentoCodigo: 'INF-2024-001',
        tipoMovimiento: 'Entrada',
        areaOrigenNombre: 'Mesa de Partes',
        areaDestinoNombre: 'Secretaría General',
        fechaMovimiento: DateTime.now().subtract(const Duration(minutes: 30)),
        observaciones: 'Ingreso regular',
        usuarioNombre: 'Recepcionista',
        estado: 'Activo',
      ),
      Movimiento(
        id: 2,
        documentoId: 2,
        documentoCodigo: 'MEM-2024-045',
        tipoMovimiento: 'Derivacion',
        areaOrigenNombre: 'Secretaría General',
        areaDestinoNombre: 'Gerencia',
        fechaMovimiento: DateTime.now().subtract(const Duration(hours: 2)),
        observaciones: 'Para revisión urgente',
        usuarioNombre: 'Secretaria',
        estado: 'Activo',
      ),
      Movimiento(
        id: 3,
        documentoId: 3,
        documentoCodigo: 'FAC-2024-789',
        tipoMovimiento: 'Salida',
        areaOrigenNombre: 'Contabilidad',
        areaDestinoNombre: 'Archivo Central',
        fechaMovimiento: DateTime.now().subtract(const Duration(days: 1)),
        observaciones: 'Documento archivado',
        usuarioNombre: 'Contador',
        estado: 'Activo',
      ),
      Movimiento(
        id: 4,
        documentoId: 4,
        documentoCodigo: 'CON-2024-102',
        tipoMovimiento: 'Entrada',
        areaOrigenNombre: 'Legal',
        areaDestinoNombre: 'Gerencia',
        fechaMovimiento: DateTime.now().subtract(const Duration(days: 2)),
        observaciones: 'Contrato firmado',
        usuarioNombre: 'Abogado Jr',
        estado: 'Activo',
      ),
    ];
  }

  Future<List<Movimiento>> getByDocumentoId(int documentoId) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.get(
      '/movimientos/documento/$documentoId',
    );
    return (response.data as List)
        .map((json) => Movimiento.fromJson(json))
        .toList();
  }

  Future<Movimiento> create(CreateMovimientoDTO dto) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.post('/movimientos', data: dto.toJson());
    return Movimiento.fromJson(response.data);
  }

  Future<Movimiento> devolverDocumento(
    int movimientoId, {
    String? observaciones,
  }) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.post(
      '/movimientos/devolver',
      data: {'movimientoId': movimientoId, 'observaciones': observaciones},
    );
    return Movimiento.fromJson(response.data);
  }
}
