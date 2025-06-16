# Temporary policy bypass
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Title
$host.UI.RawUI.WindowTitle = "Lester MOD ANALYZER - MADE BY LESTER"

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "       LESTER MOD ANALYZER - MADE BY LESTER     " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Ask user for .minecraft path
$modsFolder = Read-Host "👉 Enter your Minecraft 'mods' folder path (e.g. C:\Users\YourName\AppData\Roaming\.minecraft\mods)"

# Create report path
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$report = "$PSScriptRoot\LesterModReport_$timestamp.txt"

# Suspicious mod keywords
$blacklist = @('doomsday','vape','sigma','flux','jigsaw')

# Validate path
if (-not (Test-Path $modsFolder)) {
    Write-Host "❌ Invalid path. Folder not found: $modsFolder" -ForegroundColor Red
    "❌ Invalid path: $modsFolder" | Out-File $report
    exit
}

Write-Host "`n✅ Scanning folder: $modsFolder" -ForegroundColor Cyan
Add-Content $report "`n✅ Scanning folder: $modsFolder"

# Get mod .jar files
$mods = Get-ChildItem -Path $modsFolder -Filter *.jar -File -ErrorAction SilentlyContinue
if ($mods.Count -eq 0) {
    Write-Host "⚠️  No .jar mod files found in that folder." -ForegroundColor Yellow
    Add-Content $report "⚠️  No .jar mod files found."
    exit
}

# Analyze mods
foreach ($mod in $mods) {
    $modName = $mod.Name
    $sizeMB = "{0:N2}" -f ($mod.Length / 1MB)
    $matches = $blacklist | Where-Object { $modName -match [regex]::Escape($_) }

    if ($matches) {
        $line = "❗ Suspicious: $modName | ${sizeMB}MB | Match: $($matches -join ', ')"
        Write-Host $line -ForegroundColor Red
        Add-Content $report $line
    } else {
        $line = "✔ $modName | ${sizeMB}MB | Clean"
        Write-Host $line -ForegroundColor Green
        Add-Content $report $line
    }
}

Write-Host "`n✅ Scan complete. Report saved to: $report" -ForegroundColor Cyan
Start-Sleep -Seconds 1
Invoke-Item $report

