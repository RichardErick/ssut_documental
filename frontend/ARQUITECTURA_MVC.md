# Arquitectura MVC del Proyecto

## 📁 Estructura del Proyecto

```
frontend/lib/
├── models/              # 📋 MODELOS - Clases de datos
├── views/               # 👁️ VISTAS - UI pura (próximamente)
├── controllers/         # 🎮 CONTROLADORES - Lógica de negocio
├── services/            # 🌐 SERVICIOS - Comunicación con API
├── providers/           # 🔄 PROVIDERS - Estado global
├── widgets/             # 🧩 WIDGETS - Componentes reutilizables
├── theme/               # 🎨 TEMA
├── utils/               # 🛠️ UTILIDADES
└── main.dart
```

## 🏗️ Arquitectura MVC Adaptada para Flutter

### 📋 MODELO (models/)

**Responsabilidad:** Representar datos y estructuras

```dart
// models/documento.dart
class Documento {
  final int id;
  final String codigo;
  final String descripcion;
  // ...

  factory Documento.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

**Características:**
- ✅ Clases de datos (POJOs/DTOs)
- ✅ Serialización/Deserialización JSON
- ✅ Validaciones básicas
- ❌ NO contiene lógica de negocio
- ❌ NO llama servicios

---

### 🎮 CONTROLADOR (controllers/)

**Responsabilidad:** Lógica de negocio y gestión de estado

```dart
// controllers/documentos/documentos_controller.dart
class DocumentosController extends ChangeNotifier {
  final DocumentoService _service;
  
  List<Documento> _documentos = [];
  bool _isLoading = false;
  
  List<Documento> get documentos => _documentos;
  bool get isLoading => _isLoading;
  
  Future<void> cargarDocumentos() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _service.getAll();
      _documentos = response.items;
    } catch (e) {
      throw Exception(ErrorHelper.getErrorMessage(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> eliminarDocumento(int id) async {
    await _service.delete(id);
    await cargarDocumentos();
  }
}
```

**Características:**
- ✅ Extiende `ChangeNotifier` para notificar cambios
- ✅ Gestiona estado local del módulo
- ✅ Llama servicios para obtener/modificar datos
- ✅ Expone getters para la vista
- ✅ Expone métodos públicos para acciones
- ✅ Maneja errores y validaciones
- ❌ NO contiene widgets ni UI

---

### 👁️ VISTA (views/) - Próximamente

**Responsabilidad:** Presentación visual

```dart
// views/documentos/documentos_list_view.dart
class DocumentosListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentosController(
        documentoService: context.read<DocumentoService>(),
        carpetaService: context.read<CarpetaService>(),
      )..cargarDocumentos(),
      child: Consumer<DocumentosController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView.builder(
            itemCount: controller.documentos.length,
            itemBuilder: (context, index) {
              final doc = controller.documentos[index];
              return DocumentoCard(
                documento: doc,
                onTap: () => _navegarAlDetalle(context, doc),
                onDelete: () => controller.eliminarDocumento(doc.id),
              );
            },
          );
        },
      ),
    );
  }
}
```

**Características:**
- ✅ **Solo** contiene widgets y UI
- ✅ Usa `Consumer` o `Provider.of` para leer del controlador
- ✅ Llama métodos del controlador en eventos
- ✅ Preferiblemente `StatelessWidget`
- ❌ NO contiene lógica de negocio
- ❌ NO llama servicios directamente

---

### 🌐 SERVICIO (services/)

**Responsabilidad:** Comunicación con backend

```dart
// services/documento_service.dart
class DocumentoService {
  final ApiService _apiService;
  
  Future<PaginatedResponse<Documento>> getAll() async {
    final response = await _apiService.get('/documentos');
    return PaginatedResponse.fromJson(
      response.data,
      (json) => Documento.fromJson(json),
    );
  }
  
  Future<void> delete(int id) async {
    await _apiService.delete('/documentos/$id');
  }
}
```

**Características:**
- ✅ Comunicación HTTP con API
- ✅ Transformación de datos API ↔ Modelo
- ✅ Manejo de errores de red
- ❌ NO contiene lógica de UI
- ❌ NO gestiona estado de la aplicación

---

### 🔄 PROVIDER (providers/)

**Responsabilidad:** Estado global compartido

```dart
// providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  
  bool get isAuthenticated => _token != null;
  
  Future<void> login(String username, String password) async {
    // Lógica de autenticación global
  }
}
```

**Uso:**
- Estado compartido entre múltiples pantallas
- Autenticación
- Configuración global
- Tema

---

## 🔄 Flujo de Datos

```
┌─────────────┐
│   VISTA     │  (UI - Solo presenta datos)
│  (Widget)   │
└──────┬──────┘
       │ Lee estado / Llama métodos
       ▼
┌─────────────┐
│ CONTROLADOR │  (Lógica de negocio)
│(ChangeNotif)│
└──────┬──────┘
       │ Llama
       ▼
┌─────────────┐
│  SERVICIO   │  (Comunicación API)
│   (HTTP)    │
└──────┬──────┘
       │ Transforma
       ▼
┌─────────────┐
│   MODELO    │  (Datos)
│   (Class)   │
└─────────────┘
```

## 📦 Controladores Creados

### Documentos
- ✅ `DocumentosController` - Lista de documentos
- ✅ `DocumentoDetailController` - Detalle de documento

### Carpetas
- ✅ `CarpetasController` - Gestión de carpetas

### Admin
- ✅ `UsuariosController` - Gestión de usuarios
- ✅ `PermisosController` - Gestión de permisos

## 🎯 Ventajas de esta Arquitectura

### 1. **Separación de Responsabilidades**
- Cada capa tiene una función clara
- Fácil de entender y mantener

### 2. **Testabilidad**
```dart
// Fácil de testear sin UI
test('Cargar documentos', () async {
  final controller = DocumentosController(
    documentoService: MockDocumentoService(),
    carpetaService: MockCarpetaService(),
  );
  
  await controller.cargarDocumentos();
  
  expect(controller.documentos.length, 5);
  expect(controller.isLoading, false);
});
```

### 3. **Reutilización**
- Controladores pueden usarse en múltiples vistas
- Widgets de UI son independientes

### 4. **Escalabilidad**
- Agregar nuevas funcionalidades es más fácil
- Modificar una capa no afecta las demás

### 5. **Mantenibilidad**
- Código más limpio y organizado
- Bugs más fáciles de localizar

## 🚀 Cómo Usar los Controladores

### Opción 1: Con ChangeNotifierProvider

```dart
class MiPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentosController(
        documentoService: context.read<DocumentoService>(),
        carpetaService: context.read<CarpetaService>(),
      )..cargarDocumentos(), // Cargar datos al crear
      child: Consumer<DocumentosController>(
        builder: (context, controller, child) {
          return ListView.builder(
            itemCount: controller.documentos.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(controller.documentos[index].codigo),
                onTap: () => _verDetalle(controller.documentos[index]),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Opción 2: Con Provider.of

```dart
final controller = Provider.of<DocumentosController>(context);

ElevatedButton(
  onPressed: () => controller.cargarDocumentos(),
  child: Text('Recargar'),
)
```

### Opción 3: Con context.read (para acciones)

```dart
ElevatedButton(
  onPressed: () {
    context.read<DocumentosController>().eliminarDocumento(id);
  },
  child: Text('Eliminar'),
)
```

## 📚 Próximos Pasos

1. ✅ Crear controladores (COMPLETADO)
2. ⏳ Migrar vistas actuales a usar controladores
3. ⏳ Crear carpeta `views/` con vistas limpias
4. ⏳ Mover widgets específicos a `views/*/widgets/`
5. ⏳ Eliminar archivos antiguos en `screens/`
6. ⏳ Actualizar imports
7. ⏳ Documentar cambios

## 💡 Ejemplo Completo

Ver `.refactor_plan.md` para un plan detallado de migración.

## 🤝 Contribuir

Al agregar nuevas funcionalidades:

1. **Crear modelo** en `models/`
2. **Crear servicio** en `services/`
3. **Crear controlador** en `controllers/`
4. **Crear vista** en `views/`
5. **Usar Provider** para inyectar dependencias

---

**Nota:** Los archivos en `screens/` son la versión antigua (monolítica). Gradualmente se migrarán a la nueva arquitectura MVC.
