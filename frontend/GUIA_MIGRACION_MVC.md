# 🔄 Guía de Migración de Screens a MVC

## Objetivo
Convertir las pantallas monolíticas de `screens/` a la nueva arquitectura MVC.

---

## 📝 Proceso de Migración (Paso a Paso)

### Ejemplo: Migrar `documento_detail_screen.dart`

#### PASO 1: Analizar la pantalla actual

```dart
// screens/documentos/documento_detail_screen.dart (1538 líneas)
class DocumentoDetailScreen extends StatefulWidget {
  final Documento documento;
  
  @override
  _DocumentoDetailScreenState createState() => _DocumentoDetailScreenState();
}

class _DocumentoDetailScreenState extends State<DocumentoDetailScreen> {
  // ❌ PROBLEMA: Todo mezclado
  String? _qrData;
  bool _isGeneratingQr = false;
  
  // Lógica de negocio
  Future<void> _generateQr() async { ... }
  
  // UI
  @override
  Widget build(BuildContext context) { ... }
}
```

#### PASO 2: Extraer lógica al Controlador

```dart
// controllers/documentos/documento_detail_controller.dart
class DocumentoDetailController extends ChangeNotifier {
  final DocumentoService _service;
  final Documento documento;
  
  // Estado
  String? _qrData;
  bool _isGeneratingQr = false;
  
  // Getters
  String? get qrData => _qrData;
  bool get isGeneratingQr => _isGeneratingQr;
  
  // Lógica de negocio
  Future<void> generateQr() async {
    _isGeneratingQr = true;
    notifyListeners();
    
    try {
      final response = await _service.generarQR(documento.id);
      _qrData = response['qrContent'];
    } finally {
      _isGeneratingQr = false;
      notifyListeners();
    }
  }
}
```

#### PASO 3: Crear Vista limpia

```dart
// views/documentos/documento_detail_view.dart
class DocumentoDetailView extends StatelessWidget {
  final Documento documento;
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentoDetailController(
        service: context.read<DocumentoService>(),
        documento: documento,
      )..initQr(),
      child: Consumer<DocumentoDetailController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: _buildAppBar(context, controller),
            body: _buildBody(context, controller),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, DocumentoDetailController controller) {
    if (controller.isGeneratingQr) {
      return Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildQrSection(controller),
          _buildInfoSection(controller),
          // ... más secciones
        ],
      ),
    );
  }
}
```

---

## 🎯 Patrones Comunes de Migración

### Patrón 1: Estado Local → Controlador

**Antes:**
```dart
class _MyScreenState extends State<MyScreen> {
  List<Documento> _documentos = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final docs = await DocumentoService().getAll();
    setState(() {
      _documentos = docs.items;
      _isLoading = false;
    });
  }
}
```

**Después:**
```dart
// Controlador
class MyController extends ChangeNotifier {
  List<Documento> _documentos = [];
  bool _isLoading = false;
  
  List<Documento> get documentos => _documentos;
  bool get isLoading => _isLoading;
  
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    final docs = await _service.getAll();
    _documentos = docs.items;
    _isLoading = false;
    notifyListeners();
  }
}

// Vista
class MyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyController(...)..loadData(),
      child: Consumer<MyController>(
        builder: (context, controller, _) {
          if (controller.isLoading) return LoadingWidget();
          return ListView.builder(
            itemCount: controller.documentos.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(controller.documentos[index].codigo),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Patrón 2: Métodos de Acción → Controlador

**Antes:**
```dart
class _MyScreenState extends State<MyScreen> {
  Future<void> _eliminarDocumento(int id) async {
    try {
      await DocumentoService().delete(id);
      await _loadData(); // Recargar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

**Después:**
```dart
// Controlador
class MyController extends ChangeNotifier {
  Future<void> eliminarDocumento(int id) async {
    await _service.delete(id);
    await loadData(); // Recargar automáticamente
  }
}

// Vista
ElevatedButton(
  onPressed: () async {
    try {
      await context.read<MyController>().eliminarDocumento(doc.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  },
  child: Text('Eliminar'),
)
```

### Patrón 3: Filtros y Búsqueda → Controlador

**Antes:**
```dart
class _MyScreenState extends State<MyScreen> {
  String _searchQuery = '';
  
  List<Documento> get _filteredDocs {
    return _documentos.where((doc) {
      return doc.codigo.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }
}
```

**Después:**
```dart
// Controlador
class MyController extends ChangeNotifier {
  String _searchQuery = '';
  
  List<Documento> get filteredDocs {
    return _documentos.where((doc) {
      return doc.codigo.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

// Vista
TextField(
  onChanged: (value) => context.read<MyController>().updateSearch(value),
)
```

---

## 🛠️ Herramientas de Migración

### Checklist para cada pantalla

```markdown
- [ ] 1. Identificar estado local
- [ ] 2. Identificar métodos de lógica de negocio
- [ ] 3. Identificar llamadas a servicios
- [ ] 4. Crear controlador con estado y métodos
- [ ] 5. Crear vista con solo UI
- [ ] 6. Extraer widgets reutilizables
- [ ] 7. Probar funcionalidad
- [ ] 8. Eliminar archivo antiguo
- [ ] 9. Actualizar imports
```

### Script de ayuda

```bash
# Buscar todas las pantallas StatefulWidget
grep -r "extends StatefulWidget" lib/screens/

# Buscar llamadas directas a servicios en screens
grep -r "Service()" lib/screens/

# Buscar setState (candidatos a migrar)
grep -r "setState" lib/screens/
```

---

## 📊 Ejemplo Completo: PermisosScreen

### Antes (Monolítico)

```dart
// screens/admin/permisos_screen.dart (800 líneas)
class PermisosScreen extends StatefulWidget { ... }

class _PermisosScreenState extends State<PermisosScreen> {
  List<Usuario> _usuarios = [];
  List<Permiso> _permisos = [];
  Usuario? _usuarioSeleccionado;
  Map<int, bool> _cambiosLocales = {};
  bool _isLoading = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadUsuarios();
    _loadPermisos();
  }
  
  Future<void> _loadUsuarios() async { ... }
  Future<void> _loadPermisos() async { ... }
  Future<void> _guardarCambios() async { ... }
  void _onPermisoChanged(int id, bool value) { ... }
  
  @override
  Widget build(BuildContext context) {
    // 600 líneas de UI
  }
}
```

### Después (MVC)

```dart
// controllers/admin/permisos_controller.dart (150 líneas)
class PermisosController extends ChangeNotifier {
  final PermisoService _permisoService;
  final UsuarioService _usuarioService;
  
  List<Usuario> _usuarios = [];
  List<Permiso> _permisos = [];
  Usuario? _usuarioSeleccionado;
  Map<int, bool> _cambiosLocales = {};
  bool _isLoading = false;
  bool _isSaving = false;
  
  // Getters
  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  bool get hayCambios => _cambiosLocales.isNotEmpty;
  
  // Métodos
  Future<void> cargarUsuarios() async { ... }
  Future<void> seleccionarUsuario(Usuario u) async { ... }
  void cambiarPermiso(int id, bool value) { ... }
  Future<void> guardarCambios() async { ... }
}

// views/admin/permisos_view.dart (400 líneas)
class PermisosView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PermisosController(
        permisoService: context.read<PermisoService>(),
        usuarioService: context.read<UsuarioService>(),
      )..cargarUsuarios(),
      child: Consumer<PermisosController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: _buildAppBar(controller),
            body: Row(
              children: [
                _buildUsuariosList(controller),
                _buildPermisosList(controller),
              ],
            ),
            floatingActionButton: controller.hayCambios
                ? _buildSaveButton(controller)
                : null,
          );
        },
      ),
    );
  }
}

// views/admin/widgets/usuario_list_item.dart (50 líneas)
class UsuarioListItem extends StatelessWidget { ... }

// views/admin/widgets/permiso_switch.dart (60 líneas)
class PermisoSwitch extends StatelessWidget { ... }
```

---

## ✅ Beneficios de la Migración

### Antes
- ❌ 800 líneas en un archivo
- ❌ UI y lógica mezcladas
- ❌ Difícil de testear
- ❌ Difícil de mantener
- ❌ No reutilizable

### Después
- ✅ Controlador: 150 líneas (solo lógica)
- ✅ Vista: 400 líneas (solo UI)
- ✅ Widgets: 3 archivos de 50-60 líneas
- ✅ Fácil de testear
- ✅ Fácil de mantener
- ✅ Componentes reutilizables

---

## 🎯 Prioridades de Migración

### Alta Prioridad
1. ✅ `documentos_list_screen.dart` → `DocumentosListView` (COMPLETADO)
2. ⏳ `documento_detail_screen.dart` → `DocumentoDetailView`
3. ⏳ `permisos_screen.dart` → `PermisosView`

### Media Prioridad
4. ⏳ `usuarios_screen.dart` → `UsuariosView`
5. ⏳ `carpetas_screen.dart` → `CarpetasView`
6. ⏳ `documento_form_screen.dart` → `DocumentoFormView`

### Baja Prioridad
7. ⏳ `login_screen.dart` → `LoginView`
8. ⏳ `home_screen.dart` → `HomeView`
9. ⏳ Otras pantallas menos usadas

---

## 📚 Recursos Adicionales

- Ver `ARQUITECTURA_MVC.md` para conceptos
- Ver `MVC_IMPLEMENTACION.md` para estado actual
- Ver `views/documentos/documentos_list_view.dart` para ejemplo completo
- Ver `controllers/documentos/documentos_controller.dart` para patrón de controlador

---

**Última actualización:** 28 de Enero, 2026
