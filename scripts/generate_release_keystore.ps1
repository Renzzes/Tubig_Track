# TubigTrack Release Keystore Generator
# Run from project root: .\scripts\generate_release_keystore.ps1
# BACK UP the generated .jks and key.properties securely after running.

$ErrorActionPreference = "Stop"
$androidDir = Join-Path $PSScriptRoot "..\android"
$keystorePath = Join-Path $androidDir "tubigtrack-release.jks"
$keyPropsPath = Join-Path $androidDir "key.properties"

if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists at $keystorePath"
    exit 0
}

function New-RandomPassword {
    param([int]$Length = 20)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    -join (1..$Length | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

$storePass = New-RandomPassword
$keyPass = $storePass

& keytool -genkeypair -v `
    -keystore $keystorePath `
    -keyalg RSA -keysize 2048 -validity 10000 `
    -alias tubigtrack `
    -storepass $storePass -keypass $keyPass `
    -dname "CN=TubigTrack, OU=Mobile, O=TubigTrack, L=Manila, ST=Metro Manila, C=PH"

@"
storePassword=$storePass
keyPassword=$keyPass
keyAlias=tubigtrack
storeFile=tubigtrack-release.jks
"@ | Set-Content -Path $keyPropsPath -Encoding Ascii

Write-Host ""
Write-Host "CRITICAL: Backup these files securely:"
Write-Host "  $keystorePath"
Write-Host "  $keyPropsPath"
Write-Host ""
Write-Host "Losing the keystore prevents future APK updates without uninstall."
