# Mejoras de Base de Datos PostgreSQL

## Resumen de Optimizaciones Realizadas

Se ha optimizado el esquema de base de datos PostgreSQL para mejorar el rendimiento, integridad y funcionalidad del Sistema de Gestión Documental SSUT.

## Archivos Generados

- **`schema_optimized.sql`** - Esquema completamente optimizado
- **`migration_script.sql`** - Script para migrar desde el schema original
- **`DATABASE_IMPROVEMENTS.md`** - Esta documentación

## Mejoras Principales

### 1. Extensiones PostgreSQL
- **uuid-ossp**: Generación de UUID únicos
- **pg_trgm**: Búsqueda de texto completo y similitud de cadenas

### 2. Tipos de Datos Mejorados

#### Tipos Enumerados
- `rol_enum`: Administrador, AdministradorDocumentos, Usuario, Supervisor
- `estado_documento_enum`: Activo, Inactivo, Archivado, Eliminado
- `tipo_movimiento_enum`: Prestamo, Devolucion, Transferencia, Archivo, Eliminacion
- `estado_movimiento_enum`: Activo, Completado, Cancelado

#### Optimizaciones de Columnas
- **UUID**: Campos `uuid` agregados para identificación única
- **TIMESTAMP WITH TIME ZONE**: Manejo adecuado de zonas horarias
- **BIGINT**: Para tamaños de archivos grandes
- **TEXT**: Para descripciones largas sin límite estricto
- **JSONB**: Para datos estructurados en auditoría

### 3. Restricciones y Validaciones

#### Validaciones de Datos
- Formato de email con expresión regular
- Formato de código de documento: `^[A-Z]{2,4}-[0-9]{4}-[0-9]{6}$`
- Formato de gestión: 4 dígitos numéricos
- Nivel de confidencialidad entre 1 y 5
- Tamaño de archivo positivo

#### Unicidad y Referencias
- Códigos únicos en áreas y tipos de documento
- UUID únicos para todos los registros
- Integridad referencial mejorada

### 4. Índices Optimizados

#### Índices Especializados
- **Índices parciales**: Solo para registros activos (`WHERE activo = TRUE`)
- **Índices GIN**: Para búsqueda de texto completo
- **Índices compuestos**: Para consultas frecuentes combinadas
- **Índices de expresión**: Para búsquedas optimizadas

#### Índices de Búsqueda
- Búsqueda de texto completo en descripciones de documentos
- Búsqueda por código QR
- Búsquedas por fechas y estados

### 5. Funciones y Triggers

#### Triggers Automáticos
- **Actualización de timestamps**: Modificación automática de `fecha_actualizacion`
- **Registro en historial**: Auditoría automática de cambios

#### Funciones PostgreSQL
- **`generar_correlativo()`**: Generación automática de códigos correlativos
- **`actualizar_timestamp()`**: Actualización automática de timestamps

### 6. Nuevas Tablas

#### Tabla `configuracion`
- Configuración dinámica del sistema
- Parámetros ajustables sin modificar código
- Tipos de datos flexibles

#### Tabla `alertas`
- Sistema de notificaciones
- Alertas por documento y movimiento
- Estados de lectura

### 7. Vistas Optimizadas

#### Vista `vista_documentos_activos`
- Consulta optimizada de documentos activos
- Joins predefinidos para rendimiento
- Información completa en una vista

#### Vista `vista_movimientos_activos`
- Movimientos actualmente activos
- Información relacionada completa
- Optimizada para dashboards

## Mejoras de Rendimiento

### 1. Optimización de Consultas
- Índices específicos para consultas frecuentes
- Vistas materializadas para datos complejos
- Búsqueda de texto completo con GIN

### 2. Integridad de Datos
- Constraints a nivel de base de datos
- Tipos enumerados para consistencia
- Validaciones automáticas

### 3. Auditoría Mejorada
- Registro completo de cambios
- JSONB para detalles estructurados
- Información de sesión y user agent

## Seguridad Mejorada

### 1. Niveles de Confidencialidad
- Clasificación de documentos 1-5
- Control de acceso basado en niveles

### 2. Bloqueo de Usuarios
- Intentos fallidos registrados
- Tiempo de bloqueo configurable
- Recuperación automática

### 3. Auditoría Completa
- Todas las acciones registradas
- Dirección IP y user agent
- Detalles en formato JSON

## Proceso de Migración

### Pasos para Migrar
1. **Backup**: Crear backup completo de la base de datos
2. **Ejecutar migration_script.sql**: Aplicar cambios gradualmente
3. **Verificar**: Comprobar integridad de datos
4. **Actualizar aplicación**: Modificar código para usar nuevas características

### Comandos Útiles
```sql
-- Verificar migración
SELECT COUNT(*) FROM areas;
SELECT COUNT(*) FROM tipos_documento;
SELECT COUNT(*) FROM usuarios;
SELECT COUNT(*) FROM documentos;

-- Verificar nuevas columnas
\d areas
\d usuarios
\d documentos;

-- Probar nuevas funciones
SELECT generar_correlativo('CI', '2025', 'ADM');
```

## Configuración Inicial

### Parámetros del Sistema
- `plazo_prestamo_defecto`: 7 días
- `max_intentos_login`: 3 intentos
- `tiempo_bloqueo_minutos`: 30 minutos
- `version_sistema`: 2.0.0
- `notificaciones_email`: true

### Usuarios por Defecto
- **admin**: Administrador del sistema
- **doc_admin**: Administrador de documentos

## Beneficios Obtenidos

### 1. Rendimiento
- Consultas más rápidas con índices optimizados
- Búsqueda de texto completo eficiente
- Vistas precompiladas para operaciones comunes

### 2. Escalabilidad
- UUID para distribución global
- JSONB para datos flexibles
- Estructura preparada para crecimiento

### 3. Mantenimiento
- Triggers automáticos reducen código manual
- Configuración centralizada
- Auditoría completa

### 4. Seguridad
- Validaciones a nivel de base de datos
- Control de acceso granular
- Registro completo de auditoría

## Recomendaciones

### 1. Post-Migración
- Ejecutar `ANALYZE` para actualizar estadísticas
- Monitorear rendimiento de consultas
- Configurar backups automatizados

### 2. Mantenimiento Continuo
- Revisar y optimizar índices periódicamente
- Monitorear crecimiento de tablas
- Actualizar estadísticas regularmente

### 3. Seguridad
- Rotar contraseñas de usuarios por defecto
- Configurar roles y permisos específicos
- Implementar políticas de retención

## Compatibilidad

### Versiones PostgreSQL
- Mínimo: PostgreSQL 12+
- Recomendado: PostgreSQL 14+
- Extensiones requeridas: uuid-ossp, pg_trgm

### Aplicación
- Actualizar drivers de PostgreSQL
- Modificar consultas para usar nuevas vistas
- Implementar manejo de tipos enumerados
