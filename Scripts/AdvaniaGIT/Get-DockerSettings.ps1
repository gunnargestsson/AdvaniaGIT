function Get-DockerSettings
{
    param (
        [String]$SettingsFilePath = "Data\DockerSettings.Json"
    )
                
    $DockerSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json
    Write-Verbose -Message "Docker Settings loaded"
    Return $DockerSettings
}
