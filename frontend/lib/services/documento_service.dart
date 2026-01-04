import 'package:provider/provider.dart';

import '../main.dart';
import '../models/documento.dart';
import 'api_service.dart';

class DocumentoService {
  Future<List<Documento>> getAll() async {
    try {
      final apiService = Provider.of<ApiService>(
        navigatorKey.currentContext!,
        listen: false,
      );
      final response = await apiService.get('/documentos');
      return (response.data as List)
          .map((json) => Documento.fromJson(json))
          .toList();
    } catch (e) {
      print('API Error: $e. Returning mock data.');
      return _getMockDocumentos();
    }
  }

  List<Documento> _getMockDocumentos() {
    return [
      Documento(
        id: 1,
        codigo: 'INF-2024-001',
        numeroCorrelativo: '001',
        tipoDocumentoId: 1,
        tipoDocumentoNombre: 'Informe',
        areaOrigenId: 1,
        areaOrigenNombre: 'Contabilidad',
        gestion: '2024',
        fechaDocumento: DateTime.now().subtract(const Duration(days: 2)),
        descripcion: 'Informe de gestión financiera Q1',
        estado: 'activo',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 2)),
        responsableNombre: 'Juan Perez',
      ),
      Documento(
        id: 2,
        codigo: 'MEM-2024-045',
        numeroCorrelativo: '045',
        tipoDocumentoId: 2,
        tipoDocumentoNombre: 'Memorandum',
        areaOrigenId: 2,
        areaOrigenNombre: 'Recursos Humanos',
        gestion: '2024',
        fechaDocumento: DateTime.now().subtract(const Duration(days: 5)),
        descripcion: 'Asignación de nuevo personal',
        estado: 'archivado',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 5)),
        responsableNombre: 'Maria Diaz',
      ),
      Documento(
        id: 3,
        codigo: 'FAC-2024-789',
        numeroCorrelativo: '789',
        tipoDocumentoId: 3,
        tipoDocumentoNombre: 'Factura',
        areaOrigenId: 3,
        areaOrigenNombre: 'Ventas',
        gestion: '2024',
        fechaDocumento: DateTime.now().subtract(const Duration(days: 1)),
        descripcion: 'Factura de servicios cloud',
        estado: 'prestado',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 1)),
        responsableNombre: 'Carlos Ruiz',
      ),
       Documento(
        id: 4,
        codigo: 'CON-2024-102',
        numeroCorrelativo: '102',
        tipoDocumentoId: 4,
        tipoDocumentoNombre: 'Contrato',
        areaOrigenId: 4,
        areaOrigenNombre: 'Legal',
        gestion: '2024',
        fechaDocumento: DateTime.now().subtract(const Duration(days: 10)),
        descripcion: 'Contrato de servicios de mantenimiento',
        estado: 'activo',
        fechaRegistro: DateTime.now().subtract(const Duration(days: 10)),
        responsableNombre: 'Ana Lopez',
      ),
    ];
  }

  Future<Documento?> getById(int id) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.get('/documentos/$id');
    return Documento.fromJson(response.data);
  }

  Future<Documento?> getByCodigo(String codigo) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.get('/documentos/codigo/$codigo');
    return Documento.fromJson(response.data);
  }

  Future<Documento?> getByQRCode(String codigoQR) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.get('/documentos/qr/$codigoQR');
    return Documento.fromJson(response.data);
  }

  Future<List<Documento>> buscar(BusquedaDocumentoDTO busqueda) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.post(
      '/documentos/buscar',
      data: busqueda.toJson(),
    );
    return (response.data as List)
        .map((json) => Documento.fromJson(json))
        .toList();
  }

  Future<Documento> create(CreateDocumentoDTO dto) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.post('/documentos', data: dto.toJson());
    return Documento.fromJson(response.data);
  }

  Future<Documento> update(int id, Map<String, dynamic> data) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.put('/documentos/$id', data: data);
    return Documento.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    await apiService.delete('/documentos/$id');
  }
}
