import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:Sistema_info_web_gestion/services/api_service.dart';
import 'package:Sistema_info_web_gestion/services/audit_service.dart';
import 'package:Sistema_info_web_gestion/services/sync_service.dart';
import 'package:Sistema_info_web_gestion/models/sync_log.dart';

// Mocks
class MockApiService extends Mock implements ApiService {}
class MockAuditService extends Mock implements AuditService {
  @override
  Future<void> logEvent({required String action, required String module, required String details, String? username}) async {
    return; // Stub
  }
}

void main() {
  group('SyncService Tests', () {
    late SyncService syncService;
    late MockApiService mockApiService;
    late MockAuditService mockAuditService;

    setUp(() {
      mockApiService = MockApiService();
      mockAuditService = MockAuditService();
      syncService = SyncService(mockApiService, mockAuditService);
    });

    test('sincronizarUsuarios returns successful log and updates history', () async {
      final log = await syncService.sincronizarUsuarios();

      expect(log.estado, SyncStatus.exitoso);
      expect(syncService.history.length, 1);
      expect(syncService.history.first, log);
    });

    // Note: To test failure cases, we would need to mock the delay/error throwing
    // or refactor SyncService to allow injecting behavior.
  });
}
