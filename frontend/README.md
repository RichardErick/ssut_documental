# Frontend Flutter - Sistema de Gestión Documental SSUT

Este proyecto Flutter fue creado correctamente usando `flutter create frontend`.

## Estructura del Proyecto

```
frontend/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── models/                      # Modelos de datos
│   │   ├── documento.dart
│   │   └── movimiento.dart
│   ├── services/                    # Servicios de API
│   │   ├── api_service.dart
│   │   ├── documento_service.dart
│   │   ├── movimiento_service.dart
│   │   └── reporte_service.dart
│   ├── providers/                   # Gestión de estado
│   │   └── auth_provider.dart
│   └── screens/                     # Pantallas
│       ├── login_screen.dart
│       ├── home_screen.dart
│       ├── documentos/
│       ├── movimientos/
│       ├── reportes/
│       └── qr/
├── assets/                          # Recursos (imágenes, iconos)
│   ├── images/
│   └── icons/
└── pubspec.yaml                     # Dependencias

```

## Instalación

1. Asegúrate de tener Flutter instalado (versión 3.0 o superior)
2. Instala las dependencias:
```bash
flutter pub get
```

## Configuración

Actualiza la URL del backend en `lib/main.dart`:
```dart
ApiService(baseUrl: 'http://localhost:5000/api')
```

## Ejecutar

```bash
# Para web
flutter run -d chrome

# Para Android
flutter run

# Para Windows
flutter run -d windows
```

## Notas

- El proyecto fue creado usando `flutter create` para asegurar la estructura correcta
- Todas las dependencias están configuradas en `pubspec.yaml`
- Las pantallas principales están implementadas y listas para usar
