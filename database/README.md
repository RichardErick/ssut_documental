# Scripts de Base de Datos PostgreSQL

## Instalación

1. Asegúrate de tener PostgreSQL instalado (versión 14 o superior)

2. Crea la base de datos:
```sql
CREATE DATABASE ssut_gestion_documental;
```

3. Ejecuta los scripts en orden:
```bash
psql -U postgres -d ssut_gestion_documental -f schema.sql
psql -U postgres -d ssut_gestion_documental -f seed_data.sql
```

## Configuración de Conexión

Actualiza la cadena de conexión en `backend/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=ssut_gestion_documental;Username=postgres;Password=tu_password;Port=5432"
  }
}
```

## Estructura de Tablas

- **areas**: Áreas de la institución
- **tipos_documento**: Tipos de documentos (comprobantes, memorándums, etc.)
- **usuarios**: Usuarios del sistema
- **documentos**: Documentos registrados con sus metadatos
- **movimientos**: Registro de entrada, salida y derivación de documentos

## Notas

- Los usuarios por defecto tienen contraseñas placeholder. Debes implementar un sistema de hash de contraseñas en producción.
- Los índices están optimizados para búsquedas frecuentes por código, gestión y fecha.

