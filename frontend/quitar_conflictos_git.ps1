# Ejecuta en la carpeta frontend (donde esta lib/screens).
# Ejemplo: cd "C:\...\sistema seguro\frontend"; .\quitar_conflictos_git.ps1

$ErrorActionPreference = "Stop"
$files = @(
    "lib\screens\home_screen.dart",
    "lib\screens\notifications_screen.dart"
)

function Resolve-Conflicts($path) {
    $lines = Get-Content -Path $path
    $out = New-Object System.Collections.ArrayList
    $skip = $false
    foreach ($line in $lines) {
        if ($line -match '^<<<<<<< ') { $skip = $false; continue }
        if ($line -match '^=======$') { $skip = $true; continue }
        if ($line -match '^>>>>>>> ') { $skip = $false; continue }
        if (-not $skip) { [void]$out.Add($line) }
    }
    $out -join "`r`n"
}

foreach ($f in $files) {
    if (-not (Test-Path $f)) { Write-Host "No encontrado: $f"; continue }
    $content = Get-Content -Path $f -Raw
    if ($content -notmatch '<<<<<<< ') { Write-Host "$f : sin conflictos."; continue }
    $resolved = Resolve-Conflicts $f
    Set-Content -Path $f -Value $resolved -NoNewline
    Write-Host "Resuelto: $f"
}
Write-Host "Listo. Ejecuta: flutter run -d chrome"
