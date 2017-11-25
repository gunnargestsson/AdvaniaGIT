function Get-DockerSettings
{
    param (
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\DockerSettings.Json") 
    )
                
    $DockerSettings = Get-Content -Path $SettingsFilePath -Encoding UTF8 | Out-String | ConvertFrom-Json

    if (![bool]($DockerSettings.PSObject.Properties.name -match "ClientFolders")) {
            $DockerSettings | Add-Member -MemberType NoteProperty -Name ClientFolders -Value @()
        }

    Write-Verbose -Message "Docker Settings loaded"
    Return $DockerSettings
}
