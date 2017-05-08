function Get-BuildSettings
{
    param (
        [String]$SettingsFilePath = "Data\BuildSettings.Json"
    )
                
    $BuildSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | ConvertFrom-Json
    Write-Verbose -Message "Settings loaded"
    Return $BuildSettings
}