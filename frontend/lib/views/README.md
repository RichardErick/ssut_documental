# Estructura de Vistas (Views)

Esta carpeta contiene todas las **Vistas** del proyecto, organizadas por módulo.

## 📁 Estructura

```
views/
├── documentos/
│   ├── documentos_list_view.dart       ✅ IMPLEMENTADO
│   ├── documento_detail_view.dart      ⏳ STUB
│   ├── documento_form_view.dart        ⏳ STUB
│   └── widgets/
│       ├── documento_card.dart         ✅ IMPLEMENTADO
│       ├── carpeta_card.dart           ✅ IMPLEMENTADO
│       ├── subcarpeta_card.dart        ✅ IMPLEMENTADO
│       └── documento_filters.dart      ✅ IMPLEMENTADO
├── carpetas/
│   └── carpeta_form_view.dart          ⏳ STUB
└── views.dart (exportaciones)
```

## 👁️ ¿Qué es una Vista?

Una **Vista** en esta arquitectura MVC es un widget que:

1. **Solo contiene UI** (widgets visuales)
2. **NO tiene lógica de negocio**
3. **Lee datos del Controlador** usando `Consumer` o `Provider.of`
4. **Llama métodos del Controlador** en eventos de usuario
5. **Preferiblemente es StatelessWidget**
6. **NO llama servicios directamente**

## 📝 Ejemplo de Uso

### Vista Completa con Controlador

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/documentos/documentos_controller.dart';
import '../../services/documento_service.dart';

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
            return CircularProgressIndicator();
          }
          
          return ListView.builder(
            itemCount: controller.documentos.length,
            itemBuilder: (context, index) {
              return DocumentoCard(
                documento: controller.documentos[index],
                onTap: () => _verDetalle(controller.documentos[index]),
                onDelete: () => controller.eliminarDocumento(
                  controller.documentos[index].id
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## 🧩 Widgets Reutilizables

Los widgets específicos de cada módulo se encuentran en `views/*/widgets/`:

### DocumentoCard
Widget para mostrar una tarjeta de documento, soporta dos modos:
- **Grid View**: Tarjeta completa con toda la información
- **List View**: Versión compacta para listas

```dart
DocumentoCard(
  documento: doc,
  onTap: () => _verDetalle(doc),
  onDelete: () => _eliminar(doc),
  theme: theme,
  isListView: false, // o true para vista de lista
)
```

### CarpetaCard
Widget para mostrar una carpeta con su información:

```dart
CarpetaCard(
  carpeta: carpeta,
  onTap: () => _abrirCarpeta(carpeta),
  theme: theme,
)
```

### SubcarpetaCard
Widget compacto para mostrar subcarpetas en scroll horizontal:

```dart
SubcarpetaCard(
  subcarpeta: sub,
  onTap: () => _abrirSubcarpeta(sub),
  theme: theme,
)
```

### DocumentoFilters
Barra de búsqueda y filtros:

```dart
DocumentoFilters(canCreate: true)
```

## 🔄 Flujo de Datos en una Vista

```
Usuario interactúa con Vista
    ↓
Vista llama método del Controlador
    ↓
Controlador procesa lógica
    ↓
Controlador llama Servicio
    ↓
Servicio obtiene datos de API
    ↓
Controlador actualiza estado
    ↓
Controlador notifica cambios (notifyListeners)
    ↓
Vista se reconstruye automáticamente (Consumer)
    ↓
Usuario ve datos actualizados
```

## ✅ Vistas Implementadas

### DocumentosListView ✅
**Ubicación:** `views/documentos/documentos_list_view.dart`

**Características:**
- ✅ Lista de carpetas en grid
- ✅ Vista de documentos dentro de carpeta
- ✅ Subcarpetas en scroll horizontal
- ✅ Toggle entre vista grid/lista
- ✅ Búsqueda y filtros
- ✅ Navegación a detalle
- ✅ Eliminación con confirmación

**Controlador:** `DocumentosController`

## ⏳ Vistas Pendientes (Stubs)

### DocumentoDetailView
- **Estado:** Stub creado
- **Pendiente:** Implementar usando `DocumentoDetailController`
- **Funcionalidad:** Mostrar detalles completos, generar QR, imprimir

### DocumentoFormView
- **Estado:** Stub creado
- **Pendiente:** Crear `DocumentoFormController` e implementar formulario
- **Funcionalidad:** Crear/editar documentos

### CarpetaFormView
- **Estado:** Stub creado
- **Pendiente:** Implementar usando `CarpetasController`
- **Funcionalidad:** Crear/editar carpetas

## 🎯 Principios de las Vistas

### ✅ HACER
- Usar `Consumer` o `context.watch` para leer estado
- Usar `context.read` para llamar métodos (acciones)
- Mantener widgets pequeños y enfocados
- Extraer widgets reutilizables
- Usar `const` cuando sea posible

### ❌ NO HACER
- NO incluir lógica de negocio
- NO llamar servicios directamente
- NO gestionar estado complejo (usar Controlador)
- NO hacer validaciones complejas (usar Controlador)
- NO hacer cálculos pesados (usar Controlador)

## 📚 Más Información

Ver `ARQUITECTURA_MVC.md` en la raíz del proyecto frontend para documentación completa.

## 🚀 Próximos Pasos

1. ✅ Implementar `DocumentosListView` (COMPLETADO)
2. ⏳ Implementar `DocumentoDetailView`
3. ⏳ Implementar `DocumentoFormView`
4. ⏳ Implementar vistas de Admin (Usuarios, Permisos)
5. ⏳ Implementar vistas de Auth (Login, Register)
6. ⏳ Migrar pantallas antiguas de `screens/`
