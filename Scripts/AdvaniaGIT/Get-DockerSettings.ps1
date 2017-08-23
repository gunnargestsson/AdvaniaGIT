function Get-DockerSettings
{
    param (
        [String]$SettingsFilePath = "Data\DockerSettings.Json"
    )
                
    $DockerSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json
    $DockerSettings |  add-member "rootPath" (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    Write-Verbose -Message "Settings loaded"
    Return $DockerSettings
}