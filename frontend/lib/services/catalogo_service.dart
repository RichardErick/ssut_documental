import 'package:provider/provider.dart';
import '../main.dart';
import 'api_service.dart';

class CatalogoService {
  Future<List<Map<String, dynamic>>> getAreas() async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.get('/areas');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getTiposDocumento() async {
    final apiService = Provider.of<ApiService>(
      navigatorKey.currentContext!,
      listen: false,
    );
    final response = await apiService.get('/tiposdocumento');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
