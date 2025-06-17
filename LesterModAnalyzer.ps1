# === Lester MOD ANALYZER (Habibi-style) ===
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
$host.UI.RawUI.WindowTitle = "LESTER MOD ANALYZER - MADE BY LESTER"

Write-Host "`n═════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "         LESTER MOD ANALYZER - MADE BY LESTER         " -ForegroundColor Green
Write-Host "═════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Prompt for mods directory
$modsPath = Read-Host "👉 Enter path to your Minecraft 'mods' folder"
if (-not (Test-Path $modsPath)) {
    Write-Host "❌ Invalid path." -ForegroundColor Red
    exit
}

# Suspicious string list
$susStrings = @(
    "vape", "doomsday", "sigma", "killaura", "ghost", "autoclicker", "aimassist", 
    "crackedclient", "tokenlogger", "liquidbounce", "xray", "reach", "clicker", 
    "backdoor", "exploit", "jigsaw", "inertia", "skid", "injector", "bypass"
)

# Scan each .jar mod
$mods = Get-ChildItem $modsPath -Filter *.jar -File
if ($mods.Count -eq 0) {
    Write-Host "⚠️  No .jar mods found in: $modsPath" -ForegroundColor Yellow
    exit
}

foreach ($mod in $mods) {
    $modName = $mod.Name
    $modPath = $mod.FullName
    $flagged = $false
    $hitList = @()

    try {
        # Read raw bytes and convert to readable ASCII strings
        $bytes = [System.IO.File]::ReadAllBytes($modPath)
        $text = [System.Text.Encoding]::ASCII.GetString($bytes)

        foreach ($sus in $susStrings) {
            if ($text -match $sus) {
                $hitList += $sus
                $flagged = $true
            }
        }

        if ($flagged) {
            Write-Host "❗ Detected: $modName -> [$($hitList -join ', ')]" -ForegroundColor Red
        } else {
            Write-Host "✔ Clean: $modName" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Could not scan: $modName — Skipped." -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Scan complete. Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")



