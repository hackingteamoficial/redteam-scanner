# REDTEAM SCANNER - VERSION FUNCIONAL CORREGIDA
param([string]$target = "")

# Configuración
$ErrorActionPreference = "Continue"
$global:Domain = ""
$global:OutDir = "outputs"
$global:StartTime = Get-Date
$global:Tools = @{}

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Test-Tool {
    param([string]$ToolName)
    $cmd = Get-Command $ToolName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    
    $goBin = "$env:USERPROFILE\go\bin\$ToolName.exe"
    if (Test-Path $goBin) { return $goBin }
    
    return $null
}

# Validación CORREGIDA del dominio
if ([string]::IsNullOrEmpty($target)) {
    Write-Log "Uso: .\redteam.ps1 dominio.com" "Red"
    exit 1
}

# Limpiar protocolo si existe
$cleanTarget = $target -replace '^https?://', ''
$cleanTarget = $cleanTarget -replace '/.*$', ''  # Quitar paths
$cleanTarget = $cleanTarget.TrimEnd('.')

if ($cleanTarget -match '^[a-zA-Z0-9][a-zA-Z0-9\-\.]*\.[a-zA-Z]{2,}$') {
    $global:Domain = $cleanTarget
    Write-Log "Dominio validado: $global:Domain" "Green"
} else {
    Write-Log "Error: Dominio invalido. Usa: dominio.com" "Red"
    exit 1
}

# Crear directorio
$safeDomain = $global:Domain -replace '[\\/:*?"<>|]', '_'
$global:OutDir = Join-Path $global:OutDir $safeDomain
New-Item -ItemType Directory -Path $global:OutDir -Force | Out-Null

Write-Host "`nREDTEAM SCANNER" -ForegroundColor Cyan
Write-Host "Target: $global:Domain" -ForegroundColor Green
Write-Host "-" * 60 -ForegroundColor Gray

# Detectar herramientas
Write-Log "Detectando herramientas..." "Yellow"
$toolsToCheck = @("nmap", "gobuster", "subfinder", "httpx", "nuclei", "curl")

foreach ($tool in $toolsToCheck) {
    $path = Test-Tool $tool
    if ($path) {
        $global:Tools[$tool] = $path
        Write-Log "OK: $tool" "Green"
    }
}

# ===== ESCANEO DE PUERTOS =====
Write-Log "`n[ESCANEO DE PUERTOS]" "Cyan"
$nmapOutput = Join-Path $global:OutDir "nmap_scan.txt"
$openPorts = 0

if ($global:Tools.ContainsKey("nmap")) {
    Write-Log "Ejecutando Nmap..." "Yellow"
    try {
        $nmapPath = $global:Tools["nmap"]
        # Usar -sn primero para ver si resuelve, si no, usar IP o forzar
        & $nmapPath -Pn -T4 -F --open -oN $nmapOutput $global:Domain 2>&1 | ForEach-Object {
            if ($_ -match "open|filtered") { Write-Host $_ -ForegroundColor Green }
        }
        
        if (Test-Path $nmapOutput) {
            $results = Get-Content $nmapOutput -Raw
            $openPorts = ([regex]::Matches($results, "\bopen\b")).Count
            if ($openPorts -gt 0) {
                Write-Log "Puertos abiertos encontrados: $openPorts" "Green"
            } else {
                Write-Log "Nmap no encontro puertos abiertos o no pudo resolver" "Yellow"
            }
        }
    } catch {
        Write-Log "Error Nmap: $_" "Red"
    }
} else {
    Write-Log "Nmap no encontrado, usando escaneo basico..." "Yellow"
    # Escaneo basico de puertos comunes
    $commonPorts = @(80,443,22,21,25,53,3306,8080,8443,3389)
    foreach ($port in $commonPorts) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $result = $tcp.BeginConnect($global:Domain, $port, $null, $null)
            if ($result.AsyncWaitHandle.WaitOne(1000, $false) -and $tcp.Connected) {
                "Puerto $port abierto" | Out-File $nmapOutput -Append
                Write-Log "Puerto $port - ABIERTO" "Green"
                $openPorts++
                $tcp.Close()
            }
        } catch {}
    }
}

# ===== ESCANEO WEB CON HTTPX =====
Write-Log "`n[ESCANEO WEB]" "Cyan"
$webOutput = Join-Path $global:OutDir "web_alive.txt"
$webCount = 0

if ($global:Tools.ContainsKey("httpx")) {
    Write-Log "Usando httpx (rapido)..." "Yellow"
    try {
        $httpxPath = $global:Tools["httpx"]
        # Escanear puertos comunes web
        $ports = "80,443,8080,8443,3000,8000,9000"
        $inputDomains = "http://$global:Domain`nhttps://$global:Domain"
        
        $inputDomains | & $httpxPath -silent -ports $ports -o $webOutput 2>$null
        
        if (Test-Path $webOutput) {
            $lines = Get-Content $webOutput
            $webCount = $lines.Count
            Write-Log "Servicios web encontrados: $webCount" "Green"
            $lines | ForEach-Object { Write-Log "  $_" "Cyan" }
        }
    } catch {
        Write-Log "Error httpx: $_" "Red"
    }
} else {
    # Fallback manual
    Write-Log "Httpx no disponible, probando manualmente..." "Yellow"
    @(80,443,8080) | ForEach-Object {
        try {
            $proto = if ($_ -eq 443) { "https" } else { "http" }
            $response = Invoke-WebRequest -Uri "$proto`://$($global:Domain):$_" -TimeoutSec 5 -SkipCertificateCheck
            "Puerto $_ ($proto) - Abierto" | Out-File $webOutput -Append
            $webCount++
            Write-Log "Puerto $_ - ABIERTO" "Green"
        } catch {}
    }
}

# ===== SUBDOMINIOS =====
Write-Log "`n[BUSQUEDA SUBDOMINIOS]" "Cyan"
$subOutput = Join-Path $global:OutDir "subdominios.txt"
$subCount = 0

if ($global:Tools.ContainsKey("subfinder")) {
    Write-Log "Ejecutando Subfinder..." "Yellow"
    try {
        $subPath = $global:Tools["subfinder"]
        & $subPath -d $global:Domain -o $subOutput -silent 2>$null
        
        if (Test-Path $subOutput) {
            $subs = Get-Content $subOutput
            $subCount = $subs.Count
            if ($subCount -gt 0) {
                Write-Log "Subdominios encontrados: $subCount" "Green"
                $subs | Select-Object -First 10 | ForEach-Object { Write-Log "  $_" "Gray" }
            } else {
                Write-Log "No se encontraron subdominios" "Yellow"
            }
        }
    } catch {
        Write-Log "Error subfinder: $_" "Red"
    }
}

# ===== FUZZING DIRECTORIOS =====
Write-Log "`n[FUZZING DIRECTORIOS]" "Cyan"
$dirOutput = Join-Path $global:OutDir "directorios.txt"

if ($global:Tools.ContainsKey("gobuster")) {
    # Crear wordlist temporal si no existe
    $wordlist = "$env:TEMP\wordlist.txt"
    if (-not (Test-Path $wordlist)) {
        Write-Log "Creando wordlist temporal..." "Yellow"
        @("admin", "login", "dashboard", "api", "test", "dev", "backup", "config", ".env", "wp-admin", "admin.php", "index.php", "robots.txt", "sitemap.xml") | Out-File $wordlist
    }
    
    Write-Log "Ejecutando Gobuster..." "Yellow"
    try {
        $gobPath = $global:Tools["gobuster"]
        
        # Determinar URL base
        $baseUrl = "http://$global:Domain"
        if ($webCount -gt 0 -and (Get-Content $webOutput | Select-String "https")) {
            $baseUrl = "https://$global:Domain"
        }
        
        & $gobPath dir -u $baseUrl -w $wordlist -q -o $dirOutput 2>$null
        
        if (Test-Path $dirOutput) {
            $dirs = Get-Content $dirOutput
            if ($dirs) {
                Write-Log "Directorios encontrados:" "Green"
                $dirs | Select-Object -First 10 | ForEach-Object { Write-Log "  $_" "Cyan" }
            } else {
                Write-Log "No se encontraron directorios comunes" "Yellow"
            }
        }
    } catch {
        Write-Log "Error gobuster: $_" "Red"
    }
}

# ===== NUCLEI (SCANNER VULNERABILIDADES) =====
if ($global:Tools.ContainsKey("nuclei")) {
    Write-Log "`n[SCANNER VULNERABILIDADES]" "Cyan"
    $nucleiOutput = Join-Path $global:OutDir "vulnerabilidades.txt"
    Write-Log "Ejecutando Nuclei (esto puede tardar)..." "Yellow"
    try {
        $nucPath = $global:Tools["nuclei"]
        & $nucPath -u "http://$global:Domain" -o $nucleiOutput -silent -nc 2>$null
        if (Test-Path $nucleiOutput) {
            $vulns = Get-Content $nucleiOutput
            if ($vulns) {
                Write-Log "Vulnerabilidades encontradas: $($vulns.Count)" "Red"
            } else {
                Write-Log "No se detectaron vulnerabilidades comunes" "Green"
            }
        }
    } catch {
        Write-Log "Error nuclei: $_" "Red"
    }
}

# Reporte final
Write-Log "`nGenerando reporte..." "Cyan"
$reportFile = Join-Path $global:OutDir "reporte_final.txt"
$duration = [math]::Round((Get-Date - $global:StartTime).TotalSeconds, 2)

@"
=== REPORTE ESCANEO ===
Target: $global:Domain
Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Duracion: $duration segundos

RESULTADOS:
- Puertos abiertos: $openPorts
- Servicios web: $webCount
- Subdominios: $subCount

Herramientas usadas: $($global:Tools.Keys -join ', ')

ARCHIVOS:
$(Get-ChildItem $global:OutDir | ForEach-Object { "- $($_.Name)" })
"@ | Out-File $reportFile

# Resumen
Write-Host "`n$( '=' * 60 )" -ForegroundColor Green
Write-Host "ESCANEO COMPLETADO" -ForegroundColor Green
Write-Host "Dominio: $global:Domain" -ForegroundColor White
Write-Host "Puertos: $openPorts | Web: $webCount | Subdominios: $subCount" -ForegroundColor Cyan
Write-Host "Tiempo: $duration segundos" -ForegroundColor Magenta
Write-Host "Resultados: $global:OutDir" -ForegroundColor Yellow
