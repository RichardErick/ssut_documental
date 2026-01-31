# Solución: errores en roles_permissions_screen.dart

Tu copia del archivo tiene errores de sintaxis (paréntesis/corchetes sin cerrar, parámetros mal puestos). La versión correcta del repositorio tiene **457 líneas** y compila bien.

## Opción 1: Restaurar el archivo desde el repositorio (recomendado)

En la carpeta del proyecto (donde está el `.git`), ejecuta:

```powershell
git fetch origin
git checkout origin/main -- frontend/lib/screens/admin/roles_permissions_screen.dart
```

Si la rama principal se llama `master` en lugar de `main`:

```powershell
git checkout origin/master -- frontend/lib/screens/admin/roles_permissions_screen.dart
```

Luego vuelve a compilar:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

## Opción 2: Si sigue el merge sin terminar

Si todavía sale "You have not concluded your merge":

```powershell
git merge --abort
git pull
cd frontend
flutter pub get
flutter run -d chrome
```

## Opción 3: Reemplazar el archivo a mano

Si no puedes usar git, copia el contenido del archivo `frontend/lib/screens/admin/roles_permissions_screen.dart` desde el repositorio de un compañero (la versión que tiene **457 líneas**) y pégalo en tu archivo, reemplazando todo. Guarda y ejecuta `flutter run -d chrome`.
