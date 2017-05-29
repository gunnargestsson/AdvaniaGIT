function Get-GITSettings
{
    param (
        [String]$SettingsFilePath = "Data\GITSettings.Json"
    )
                
    $GITSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json
    $GITSettings |  add-member "rootPath" (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    Write-Verbose -Message "Settings loaded"
    Return $GITSettings
}