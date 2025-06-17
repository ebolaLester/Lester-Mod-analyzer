# Lester Mod Analyzer - Made by Lester
# Cleaned & Enhanced with Legit Whitelist and Internal Cheat String Detection

Write-Host "\n=============================================" -ForegroundColor Cyan
Write-Host "      LESTER MOD ANALYZER - MADE BY LESTER" -ForegroundColor Green
Write-Host "=============================================\n" -ForegroundColor Cyan

# Prompt for path
$modsPath = Read-Host "👉 Enter path to your Minecraft 'mods' folder (e.g. C:\Users\YourName\AppData\Roaming\.minecraft\mods)"

if (!(Test-Path $modsPath)) {
    Write-Host "[!] The path does not exist. Exiting..." -ForegroundColor Red
    exit
}

# Legitimate mod names that should never be flagged
$whitelist = @(
    "sodium", "lithium", "voicechat", "replaymod", "modmenu", "seedcracker",
    "cloth-config", "roughlyenoughitems", "xaeros", "map", "cleanview",
    "exodium", "appleskin", "betterpingdisplay", "entityculling"
)

# Strings typically found in malicious mod jars
$susStrings = @(
    "AutoClicker", "KillAura", "AimAssist", "TriggerBot", "Reach",
    "Fly", "Scaffold", "SilentAim", "TargetStrafe", "Blink",
    "FastPlace", "WTap", "NoFall", "Criticals", "KeybindManager",
    "InventoryMove", "ESP", "XRay", "RenderManager", "Freecam"
)

# Function to scan inside each mod jar
Get-ChildItem -Path $modsPath -Filter *.jar | ForEach-Object {
    $mod = $_.FullName
    $modName = $_.Name.ToLower()

    # Skip if mod is in the whitelist
    if ($whitelist | Where-Object { $modName -like "*$_*" }) {
        Write-Host "✔ Clean: $modName" -ForegroundColor Green
        return
    }

    try {
        $found = $false
        $zip = [System.IO.Compression.ZipFile]::OpenRead($mod)

        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -match '\.(class|txt|json|cfg|xml)$') {
                $stream = $entry.Open()
                $reader = New-Object System.IO.StreamReader($stream)
                $text = $reader.ReadToEnd()
                $reader.Close()

                foreach ($sus in $susStrings) {
                    if ($text -match "\b$sus\b") {
                        Write-Host "❗ Detected: $modName -> [$sus]" -ForegroundColor Red
                        $found = $true
                        break
                    }
                }
                if ($found) { break }
            }
        }
        if (-not $found) {
            Write-Host "✔ Clean: $modName" -ForegroundColor Green
        }
        $zip.Dispose()
    } catch {
        Write-Host "⚠ Could not read $modName — Skipped." -ForegroundColor Yellow
    }
}

# Reminder for GitHub one-liner:
Write-Host "\n[💡] To run this from GitHub use:" -ForegroundColor Cyan
Write-Host "Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/ebolaLester/Lester-Mod-analyzer/main/LesterModAnalyzer.ps1)" -ForegroundColor Yellow




