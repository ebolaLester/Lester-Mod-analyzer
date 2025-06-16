# Temporary bypass
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Set console title
$host.UI.RawUI.WindowTitle = "Lester MOD ANALYZER - MADE BY LESTER"

# Intro
Write-Host "`n═════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "         LESTER MOD ANALYZER - MADE BY LESTER         " -ForegroundColor Green
Write-Host "═════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Ask for the mods folder
$modsFolder = Read-Host "👉 Enter path to your Minecraft 'mods' folder"

# Suspicious keywords
$blacklist = @('doomsday','vape','sigma','flux','jigsaw','huzuni','wurst','impact','liquidbounce','aimassist','autoclicker','xray','killaura')

# Validate path
if (-not (Test-Path $modsFolder)) {
    Write-Host "❌ Invalid path: $modsFolder" -ForegroundColor Red
    exit
}

# Get .jar mod files
$mods = Get-ChildItem -Path $modsFolder -Filter *.jar -File -ErrorAction SilentlyContinue
if ($mods.Count -eq 0) {
    Write-Host "⚠️  No .jar mod files found in that folder." -ForegroundColor Yellow
    exit
}

# Scan each mod
foreach ($mod in $mods) {
    $modName = $mod.Name
    $path = $mod.FullName
    $sizeMB = "{0:N2}" -f ($mod.Length / 1MB)
    $flagged = $false
    $found = @()

    # Check filename first
    foreach ($keyword in $blacklist) {
        if ($modName -match [regex]::Escape($keyword)) {
            $found += "filename: $keyword"
            $flagged = $true
        }
    }

    # Check internal strings
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($path)
        foreach ($entry in $zip.Entries) {
            foreach ($keyword in $blacklist) {
                if ($entry.FullName -match $keyword) {
                    $found += "inside: $keyword"
                    $flagged = $true
                }
            }
        }
        $zip.Dispose()
    } catch {
        Write-Host "⚠️  Could not read $modName — Skipped." -ForegroundColor Yellow
        continue
    }

    # Output result
    if ($flagged) {
        Write-Host "❗ Suspicious: $modName | $sizeMB MB | $($found -join ', ')" -ForegroundColor Red
    } else {
        Write-Host "✔ Clean: $modName | $sizeMB MB" -ForegroundColor Green
    }
}

Write-Host "`n✅ Done. Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


