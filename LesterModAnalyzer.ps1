Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "        LESTER MOD ANALYZER - MADE BY LESTER            " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$modPath = Read-Host "👉 Enter path to your Minecraft 'mods' folder"
if (-Not (Test-Path $modPath)) {
    Write-Host "❌ Invalid path. Exiting..." -ForegroundColor Red
    exit
}

$suspiciousKeywords = @(
    "vergin", "argon", "prestige", "hvh", "aimbot", "clicker",
    "killaura", "xray", "exploit", "autoarmor", "autoclick", "vclip"
)

function Analyze-Mod {
    param($filePath)
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($filePath)
        $found = $false
        foreach ($entry in $zip.Entries) {
            if ($entry.Name -like "*.class") { continue }
            $reader = New-Object System.IO.StreamReader($entry.Open())
            $text = $reader.ReadToEnd()
            $reader.Close()
            foreach ($key in $suspiciousKeywords) {
                if ($text -match $key) {
                    Write-Host "❗ Detected: $(Split-Path $filePath -Leaf) -> [$key]" -ForegroundColor Red
                    $found = $true
                    break
                }
            }
            if ($found) { break }
        }
        if (-not $found) {
            Write-Host "✔️ Clean: $(Split-Path $filePath -Leaf)" -ForegroundColor Green
        }
        $zip.Dispose()
    } catch {
        Write-Host "⚠️ Could not read $(Split-Path $filePath -Leaf) – Skipped." -ForegroundColor Yellow
    }
}

Get-ChildItem -Path $modPath -Filter *.jar | ForEach-Object {
    Analyze-Mod -filePath $_.FullName
}





