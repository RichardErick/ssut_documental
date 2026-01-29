# Estructura de Controladores

Esta carpeta contiene todos los **Controladores** del proyecto, organizados por módulo.

## 📁 Estructura

```
controllers/
├── documentos/
│   ├── documentos_controller.dart
│   └── documento_detail_controller.dart
├── carpetas/
│   └── carpetas_controller.dart
├── admin/
│   ├── usuarios_controller.dart
│   └── permisos_controller.dart
└── controllers.dart (exportaciones)
```

## 🎮 ¿Qué es un Controlador?

Un **Controlador** en esta arquitectura MVC es una clase que:

1. **Extiende `ChangeNotifier`** para notificar cambios a la UI
2. **Gestiona el estado** de un módulo o pantalla específica
3. **Contiene la lógica de negocio**
4. **Llama a servicios** para obtener/modificar datos
5. **Expone métodos públicos** para que la vista los use
6. **NO contiene widgets** ni código de UI

## 📝 Ejemplo de Uso

```dart
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';

class MiPantalla extends StatelessWidget {
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
            return CircularProgressIndicator();
          }
          
          return ListView.builder(
            itemCount: controller.documentos.length,
            itemBuilder: (context, index) {
              final doc = controller.documentos[index];
              return ListTile(
                title: Text(doc.codigo),
                onTap: () => _verDetalle(doc),
              );
            },
          );
        },
      ),
    );
  }
}
```

## 🔄 Flujo de Datos

```
Vista (Widget)
    ↓ llama método
Controlador
    ↓ llama
Servicio
    ↓ obtiene
API Backend
```

## ✅ Controladores Disponibles

### Documentos
- **DocumentosController**: Lista y gestión de documentos
- **DocumentoDetailController**: Detalle de un documento específico

### Carpetas
- **CarpetasController**: Gestión de carpetas y subcarpetas

### Admin
- **UsuariosController**: Gestión de usuarios del sistema
- **PermisosController**: Gestión de permisos de usuarios

## 📚 Más Información

Ver `ARQUITECTURA_MVC.md` en la raíz del proyecto frontend para documentación completa.
