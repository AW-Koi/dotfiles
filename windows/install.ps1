#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the Windows starship + fish configuration.
.DESCRIPTION
    Copies starship.toml into %USERPROFILE%\.config and installs config.fish into
    every fish installation found. Existing files are renamed to *.backup first.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    # Extra fish.exe paths to configure alongside the ones probed by default.
    [string[]]$FishPath = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoWindowsDir = $PSScriptRoot
$starshipSource = Join-Path $repoWindowsDir 'starship\.config\starship.toml'
$fishSource = Join-Path $repoWindowsDir 'fish\.config\fish\config.fish'

foreach ($required in @($starshipSource, $fishSource)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Missing repo file: $required. Run this script from a full checkout of the windows branch."
    }
}

function Install-ConfigFile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not $PSCmdlet.ShouldProcess($Destination, 'Install config file')) { return }

    $destDir = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Destination) {
        if ((Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash) {
            Write-Host "  unchanged  $Destination" -ForegroundColor DarkGray
            return
        }
        $backup = "$Destination.backup"
        Copy-Item -LiteralPath $Destination -Destination $backup -Force
        Write-Host "  backed up  $backup" -ForegroundColor Yellow
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "  installed  $Destination" -ForegroundColor Green
}

# fish resolves ~ from its own mount table, which differs between msys2 and
# cygwin and shifts with nsswitch.conf db_home. Ask each fish where it reads
# config from rather than assuming a path.
function Get-FishConfigDir {
    param([Parameter(Mandatory = $true)][string]$FishExe)

    $reported = & $FishExe -c 'echo $__fish_config_dir'
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($reported)) {
        return $null
    }
    $posix = ([string]$reported).Trim()

    # cygpath ships next to fish.exe in both msys2 and cygwin. Calling it there
    # avoids depending on the PATH fish inherits when launched from Windows.
    $cygpath = Join-Path (Split-Path -Parent $FishExe) 'cygpath.exe'
    if (-not (Test-Path -LiteralPath $cygpath)) { return $null }

    $translated = & $cygpath -w $posix
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($translated)) {
        return $null
    }
    return ([string]$translated).Trim()
}

Write-Host "`nstarship" -ForegroundColor Cyan
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Host "  starship.exe is not on PATH. Install it with:" -ForegroundColor Yellow
    Write-Host "    winget install --id Starship.Starship" -ForegroundColor Yellow
}
Install-ConfigFile -Source $starshipSource -Destination (Join-Path $env:USERPROFILE '.config\starship.toml')

Write-Host "`nfish" -ForegroundColor Cyan
$candidates = @(
    'C:\msys64\usr\bin\fish.exe'
    'C:\cygwin64\bin\fish.exe'
) + $FishPath

$onPath = Get-Command fish -ErrorAction SilentlyContinue
if ($onPath) { $candidates += $onPath.Source }

$configured = 0
foreach ($fishExe in ($candidates | Select-Object -Unique)) {
    if (-not (Test-Path -LiteralPath $fishExe)) { continue }

    $configDir = Get-FishConfigDir -FishExe $fishExe
    if (-not $configDir) {
        Write-Host "  skipped    $fishExe (could not resolve its config dir)" -ForegroundColor Yellow
        continue
    }

    Write-Host "  $fishExe -> $configDir"
    Install-ConfigFile -Source $fishSource -Destination (Join-Path $configDir 'config.fish')
    $configured++
}

if ($configured -eq 0) {
    Write-Host "  No fish installation found. Install it with:" -ForegroundColor Yellow
    Write-Host "    pacman -S fish        # inside an msys2 shell" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nDone. Open a new fish shell to pick up the prompt.`n" -ForegroundColor Cyan
