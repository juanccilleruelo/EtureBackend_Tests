# Script para sincronizar archivos del framework mediante hardlinks
# Este script crea hardlinks desde EtureFrontend al directorio framework local
# Uso: .\sync-framework-files.ps1

$ErrorActionPreference = "Stop"

# Obtener la ruta base del script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FrameworkDir = $ScriptDir

# Ruta al repositorio fuente
$SourceFrameworkDir = Join-Path (Split-Path -Parent (Split-Path -Parent $ScriptDir)) "EtureFrontend\framework"
$SourceDummyDir = Join-Path (Split-Path -Parent (Split-Path -Parent $ScriptDir)) "EtureFrontend\Dummy"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Sincronizador de Framework - Hardlinks" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que el directorio fuente existe
if (-not (Test-Path $SourceFrameworkDir)) {
    Write-Host "ERROR: No se encuentra el directorio fuente: $SourceFrameworkDir" -ForegroundColor Red
    Write-Host "Verifique que el repositorio EtureFrontend está en la ubicación correcta." -ForegroundColor Red
    exit 1
}

# Crear el directorio framework si no existe
if (-not (Test-Path $FrameworkDir)) {
    Write-Host "Creando directorio framework..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $FrameworkDir -Force | Out-Null
    Write-Host "  [OK] Directorio creado: $FrameworkDir" -ForegroundColor Green
} else {
    Write-Host "Directorio framework ya existe: $FrameworkDir" -ForegroundColor Gray
}

Write-Host ""

# Definir los archivos a enlazar
$FrameworkFiles = @(
    "ConfigurationConsts.pas",
    "senCille.WebSetup.pas",
    "senCille.Bootstrap.pas",
    "senCille.MVCRequests.pas",
    "senCille.Miscellaneous.pas",
    "senCille.CustomWebForm.pas",
    "senCille.CustomWebForm.html",
    "senCille.DataManagement.pas",
    "senCille.TypeConverter.pas"
)

$DummyFiles = @(
    @{
        Name = "Dummy.pas"
        SourceDir = $SourceDummyDir
    },
    @{
        Name = "Dummy.html"
        SourceDir = $SourceDummyDir
    }
)

$SuccessCount = 0
$ErrorCount = 0

Write-Host "Procesando archivos del framework..." -ForegroundColor Cyan
Write-Host ""

# Procesar archivos del framework
foreach ($File in $FrameworkFiles) {
    $SourceFile = Join-Path $SourceFrameworkDir $File
    $TargetFile = Join-Path $FrameworkDir $File
    
    Write-Host "Procesando: $File" -ForegroundColor White
    
    # Verificar que el archivo fuente existe
    if (-not (Test-Path $SourceFile)) {
        Write-Host "  [ERROR] Archivo fuente no encontrado: $SourceFile" -ForegroundColor Red
        $ErrorCount++
        continue
    }
    
    # Eliminar el archivo destino si existe (puede ser hardlink o archivo regular)
    if (Test-Path $TargetFile) {
        try {
            Remove-Item $TargetFile -Force
            Write-Host "  [INFO] Archivo existente eliminado" -ForegroundColor Yellow
        } catch {
            Write-Host "  [ERROR] No se pudo eliminar el archivo existente: $_" -ForegroundColor Red
            $ErrorCount++
            continue
        }
    }
    
    # Crear el hardlink
    try {
        New-Item -ItemType HardLink -Path $TargetFile -Target $SourceFile -Force | Out-Null
        Write-Host "  [OK] Hardlink creado exitosamente" -ForegroundColor Green
        $SuccessCount++
    } catch {
        Write-Host "  [ERROR] No se pudo crear el hardlink: $_" -ForegroundColor Red
        $ErrorCount++
    }
    
    Write-Host ""
}

# Procesar archivos de Dummy
Write-Host "Procesando archivos de Dummy..." -ForegroundColor Cyan
Write-Host ""

foreach ($FileInfo in $DummyFiles) {
    $File = $FileInfo.Name
    $SourceFile = Join-Path $FileInfo.SourceDir $File
    $TargetFile = Join-Path $FrameworkDir $File
    
    Write-Host "Procesando: $File" -ForegroundColor White
    
    # Verificar que el archivo fuente existe
    if (-not (Test-Path $SourceFile)) {
        Write-Host "  [ERROR] Archivo fuente no encontrado: $SourceFile" -ForegroundColor Red
        $ErrorCount++
        continue
    }
    
    # Eliminar el archivo destino si existe
    if (Test-Path $TargetFile) {
        try {
            Remove-Item $TargetFile -Force
            Write-Host "  [INFO] Archivo existente eliminado" -ForegroundColor Yellow
        } catch {
            Write-Host "  [ERROR] No se pudo eliminar el archivo existente: $_" -ForegroundColor Red
            $ErrorCount++
            continue
        }
    }
    
    # Crear el hardlink
    try {
        New-Item -ItemType HardLink -Path $TargetFile -Target $SourceFile -Force | Out-Null
        Write-Host "  [OK] Hardlink creado exitosamente" -ForegroundColor Green
        $SuccessCount++
    } catch {
        Write-Host "  [ERROR] No se pudo crear el hardlink: $_" -ForegroundColor Red
        $ErrorCount++
    }
    
    Write-Host ""
}

# Resumen
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Hardlinks creados exitosamente: $SuccessCount" -ForegroundColor Green
Write-Host "Errores: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if ($ErrorCount -eq 0) {
    Write-Host "Sincronización completada exitosamente!" -ForegroundColor Green
} else {
    Write-Host "Sincronización completada con errores. Revise los mensajes anteriores." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "NOTA: Recuerde agregar estos archivos al .gitignore:" -ForegroundColor Cyan
Write-Host "  framework/*.pas" -ForegroundColor Gray
Write-Host "  framework/*.html" -ForegroundColor Gray
