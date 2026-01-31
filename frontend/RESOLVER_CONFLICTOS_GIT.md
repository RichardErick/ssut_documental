# Cómo quitar los errores de conflicto de Git

Los errores tipo `'HEAD' isn't a type` o `Expected '>' after this` aparecen porque en el código quedaron **marcadores de conflicto de Git** que no son Dart válido.

## Opción rápida: script automático

En la carpeta **frontend** (donde está `lib/screens`), abre PowerShell y ejecuta:

```powershell
.\quitar_conflictos_git.ps1
```

Eso quita los marcadores y deja la versión HEAD. Luego: `flutter run -d chrome`.

---

## Opción manual

1. **Abre** en tu editor:
   - `lib/screens/home_screen.dart`
   - `lib/screens/notifications_screen.dart`

2. **Busca** en cada archivo (Ctrl+F):
   - `<<<<<<< `
   - `=======`
   - `>>>>>>> `

3. **En cada conflicto** verás algo así:
   ```
   <<<<<<< HEAD
   (código versión A)
   =======
   (código versión B)
   >>>>>>> 15e9afe3caae8906b3b40cf95a234a6070fd9b2d
   ```
   - Borra la línea `<<<<<<< HEAD`
   - Borra la línea `=======`
   - Borra la línea `>>>>>>> 15e9afe3...`
   - **Deja solo una de las dos versiones** (A o B). Si quieres menú con Notificaciones, Mi perfil y Gestión de Permisos para admin documentos, quédate con la **primera** (versión A / HEAD).

4. **Guarda** y vuelve a ejecutar: `flutter run -d chrome`

## Si prefieres reemplazar todo el archivo

Copia el contenido actual de `home_screen.dart` y `notifications_screen.dart` desde este mismo proyecto (la copia que no tiene conflictos) y pégalo en tu carpeta donde estás compilando (por ejemplo `C:\Users\Brayan Cortez\Desktop\sistema seguro\frontend\lib\screens\`), sobrescribiendo los archivos.

## Nota

Si estás en otro equipo o carpeta (por ejemplo "sistema seguro"), haz un **pull** desde el repo y resuelve los conflictos en Git, o copia estos dos archivos desde el repo que ya está limpio.
