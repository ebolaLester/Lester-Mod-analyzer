# Set execution policy for the session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Title
$host.UI.RawUI.WindowTitle = "Lester Mod Analyzer"

# Intro
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "       LESTER MOD ANALYZER - POWERED BY PS     " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Setup
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$report = "$PSScriptRoot\LesterModAnalysis_$timestamp.txt"
$blacklist = @('doomsday','vape','sigma','flux','jigsaw')

# Detect all 'mods' folders inside .minecraft
$minecraftRoot = "$env:USERPROFILE\.minecraft"
$modsPaths = Get-ChildItem -Path $minecraftRoot -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -ieq "mods" }

# If no mods folders found
if (-not $modsPaths) {
    Write-Host "❌ No mods folder found in .minecraft" -ForegroundColor Red
    "❌ No mods folder found in .minecraft" | Out-File $report
    exit
}

# Report potential multiple mod folders
if ($modsPaths.Count -gt 1) {
    Write-Host "⚠️  Multiple mods folders found:" -ForegroundColor Yellow
    Add-Content $report "⚠️  Multiple mods folders found:"
    foreach ($path in $modsPaths) {
        Write-Host " - $($path.FullName)" -ForegroundColor DarkYellow
        Add-Content $report " - $($path.FullName)"
    }
    Write-Host ""
    Add-Content $report ""
}

# Analyze each mods folder
foreach ($modsFolder in $modsPaths) {
    Write-Host "`n🔍 Scanning: $($modsFolder.FullName)" -ForegroundColor Cyan
    Add-Content $report "`n🔍 Scanning: $($modsFolder.FullName)"

    $mods = Get-ChildItem -Path $modsFolder.FullName -Filter *.jar -File -ErrorAction SilentlyContinue
    if ($mods.Count -eq 0) {
        Write-Host "⚠️  No mod .jar files found." -ForegroundColor DarkYellow
        Add-Content $report "⚠️  No mod .jar files found."
        continue
    }

    foreach ($mod in $mods) {
        $modName = $mod.Name
        $sizeMB = "{0:N2}" -f ($mod.Length / 1MB)
        $matches = $blacklist | Where-Object { $modName -match [regex]::Escape($_) }

        if ($matches) {
            $line = "❗ Suspicious Mod: $modName | ${sizeMB}MB | Keyword(s): $($matches -join ', ')"
            Write-Host $line -ForegroundColor Red
            Add-Content $report $line
        } else {
            $line = "✔ $modName | ${sizeMB}MB | Clean"
            Write-Host $line -ForegroundColor Green
            Add-Content $report $line
        }
    }
}

# Finish
Write-Host "`n✅ Scan complete. Report saved to: $report" -ForegroundColor Cyan
Start-Sleep -Seconds 1
Invoke-Item $report
