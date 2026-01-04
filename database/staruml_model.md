# Modelo de Base de Datos para StarUML - Sistema de Gestión Documental

## Estructura de Entidades

### 1. Usuario
```
@startuml
!define RECTANGLE class

class Usuario {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + nombre_usuario: varchar(50) (UNIQUE)
  + nombre_completo: varchar(100)
  + email: varchar(255) (UNIQUE)
  + password_hash: varchar(255)
  + rol: rol_enum
  + area_id: int (FK)
  + activo: boolean
  + ultimo_aceso: timestamp
  + intentos_fallidos: int
  + bloqueado_hasta: timestamp
  + fecha_registro: timestamp
  + fecha_actualizacion: timestamp
  
  -- Relaciones --
  * -- "1..*" Documento : responsable
  * -- "1..*" Movimiento : usuario
  * -- "1..*" Alerta : usuario
  * -- "1" Area : pertenece
}

enum rol_enum {
  Administrador
  AdministradorDocumentos
  Usuario
  Supervisor
}
@enduml
```

### 2. Area
```
@startuml
class Area {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + nombre: varchar(100)
  + codigo: varchar(20) (UNIQUE)
  + descripcion: text
  + activo: boolean
  + fecha_creacion: timestamp
  + fecha_actualizacion: timestamp
  + creado_por: int (FK)
  
  -- Relaciones --
  * -- "1..*" Usuario : contiene
  * -- "1..*" Documento : origen
  * -- "1..*" Documento : actual
  * -- "1..*" Movimiento : origen
  * -- "1..*" Movimiento : destino
}
@enduml
```

### 3. TipoDocumento
```
@startuml
class TipoDocumento {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + nombre: varchar(100)
  + codigo: varchar(20) (UNIQUE)
  + descripcion: text
  + activo: boolean
  + requiere_aprobacion: boolean
  + plazo_retencion_dias: int
  + fecha_creacion: timestamp
  + fecha_actualizacion: timestamp
  + creado_por: int (FK)
  
  -- Relaciones --
  * -- "1..*" Documento : clasifica
}
@enduml
```

### 4. Documento
```
@startuml
class Documento {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + codigo: varchar(50) (UNIQUE)
  + numero_correlativo: varchar(50)
  + tipo_documento_id: int (FK)
  + area_origen_id: int (FK)
  + area_actual_id: int (FK)
  + gestion: varchar(4)
  + fecha_documento: date
  + descripcion: text
  + responsable_id: int (FK)
  + codigo_qr: varchar(255)
  + ubicacion_fisica: varchar(200)
  + estado: estado_documento_enum
  + nivel_confidencialidad: int (1-5)
  + fecha_vencimiento: date
  + fecha_registro: timestamp
  + fecha_actualizacion: timestamp
  
  -- Relaciones --
  * -- "1" TipoDocumento : tipo
  * -- "1" Area : origen
  * -- "1" Area : actual
  * -- "1" Usuario : responsable
  * -- "1..*" Movimiento : movimientos
  * -- "1..*" Anexo : anexos
  * -- "1..*" HistorialDocumento : historial
  * -- "1..*" Alerta : alertas
}

enum estado_documento_enum {
  Activo
  Inactivo
  Archivado
  Eliminado
}
@enduml
```

### 5. Movimiento
```
@startuml
class Movimiento {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + documento_id: int (FK)
  + tipo_movimiento: tipo_movimiento_enum
  + area_origen_id: int (FK)
  + area_destino_id: int (FK)
  + usuario_id: int (FK)
  + usuario_autoriza_id: int (FK)
  + observaciones: text
  + fecha_movimiento: timestamp
  + fecha_devolucion: timestamp
  + estado: estado_movimiento_enum
  + plazo_dias: int
  
  -- Relaciones --
  * -- "1" Documento : documento
  * -- "1" Area : origen
  * -- "1" Area : destino
  * -- "1" Usuario : solicita
  * -- "1" Usuario : autoriza
  * -- "1..*" Alerta : alertas
}

enum tipo_movimiento_enum {
  Prestamo
  Devolucion
  Transferencia
  Archivo
  Eliminacion
}

enum estado_movimiento_enum {
  Activo
  Completado
  Cancelado
}
@enduml
```

### 6. Anexo
```
@startuml
class Anexo {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + documento_id: int (FK)
  + nombre_archivo: varchar(255)
  + extension: varchar(10)
  + tamano_bytes: bigint
  + url_archivo: varchar(500)
  + tipo_contenido: varchar(100)
  + hash_archivo: varchar(64)
  + version: int
  + fecha_registro: timestamp
  + activo: boolean
  
  -- Relaciones --
  * -- "1" Documento : pertenece
}
@enduml
```

### 7. HistorialDocumento
```
@startuml
class HistorialDocumento {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + documento_id: int (FK)
  + fecha_cambio: timestamp
  + usuario_id: int (FK)
  + tipo_cambio: varchar(50)
  + estado_anterior: estado_documento_enum
  + estado_nuevo: estado_documento_enum
  + area_anterior_id: int (FK)
  + area_nueva_id: int (FK)
  + campo_modificado: varchar(100)
  + valor_anterior: text
  + valor_nuevo: text
  + observacion: text
  
  -- Relaciones --
  * -- "1" Documento : documento
  * -- "1" Usuario : usuario
  * -- "1" Area : anterior
  * -- "1" Area : nueva
}
@enduml
```

### 8. Auditoria
```
@startuml
class Auditoria {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + usuario_id: int (FK)
  + sesion_id: varchar(255)
  + accion: varchar(100)
  + tabla_afectada: varchar(50)
  + registro_id: int
  + registro_uuid: UUID
  + detalle: jsonb
  + ip_address: inet
  + user_agent: text
  + fecha_accion: timestamp
  
  -- Relaciones --
  * -- "1" Usuario : usuario
}
@enduml
```

### 9. Alerta
```
@startuml
class Alerta {
  + id: int (PK)
  + uuid: UUID (UNIQUE)
  + usuario_id: int (FK)
  + titulo: varchar(200)
  + mensaje: text
  + tipo_alerta: varchar(20)
  + leida: boolean
  + fecha_creacion: timestamp
  + fecha_lectura: timestamp
  + documento_id: int (FK)
  + movimiento_id: int (FK)
  
  -- Relaciones --
  * -- "1" Usuario : usuario
  * -- "1" Documento : documento
  * -- "1" Movimiento : movimiento
}
@enduml
```

### 10. Configuracion
```
@startuml
class Configuracion {
  + id: int (PK)
  + clave: varchar(100) (UNIQUE)
  + valor: text
  + descripcion: text
  + tipo_dato: varchar(20)
  + editable: boolean
  + fecha_actualizacion: timestamp
  + actualizado_por: int (FK)
  
  -- Relaciones --
  * -- "1" Usuario : actualizado_por
}
@enduml
```

## Diagrama Completo de Relaciones
```
@startuml
left to right direction

class Usuario
class Area
class TipoDocumento
class Documento
class Movimiento
class Anexo
class HistorialDocumento
class Auditoria
class Alerta
class Configuracion

Usuario "1" -- "*" Documento : responsable
Usuario "1" -- "*" Movimiento : usuario
Usuario "1" -- "*" Alerta : usuario
Usuario "1" -- "1" Area : pertenece

Area "1" -- "*" Usuario : contiene
Area "1" -- "*" Documento : origen
Area "1" -- "*" Documento : actual
Area "1" -- "*" Movimiento : origen
Area "1" -- "*" Movimiento : destino

TipoDocumento "1" -- "*" Documento : clasifica

Documento "1" -- "*" Movimiento : movimientos
Documento "1" -- "*" Anexo : anexos
Documento "1" -- "*" HistorialDocumento : historial
Documento "1" -- "*" Alerta : alertas

Movimiento "1" -- "*" Alerta : alertas

HistorialDocumento "1" -- "1" Area : anterior
HistorialDocumento "1" -- "1" Area : nueva

Configuracion "1" -- "1" Usuario : actualizado_por
@enduml
```

## Índices y Optimizaciones

### Índices Principales
- Documentos: codigo, gestion+numero_correlativo, area_actual_id, estado, fecha_documento
- Usuarios: email, nombre_usuario, rol, activo
- Movimientos: documento_id, fecha_movimiento, tipo_movimiento, estado
- Anexos: documento_id, hash_archivo
- Auditoría: usuario_id, fecha_accion, tabla_afectada
- Alertas: usuario_id, leida, fecha_creacion

### Vistas Optimizadas
- vista_documentos_activos
- vista_movimientos_activos

### Triggers
- actualizar_timestamp() para timestamps automáticos
- registrar_historial_documento() para auditoría

### Funciones
- generar_correlativo() para códigos automáticos

## Para implementar en StarUML:

1. **Abrir StarUML**
2. **Crear nuevo proyecto** -> "Data Model"
3. **Agregar cada clase** usando el código PlantUML proporcionado
4. **Establecer relaciones** según el diagrama completo
5. **Configurar tipos de datos** y restricciones
6. **Generar código SQL** desde StarUML

StarUML puede generar automáticamente el código DDL SQL a partir del diagrama creado.
