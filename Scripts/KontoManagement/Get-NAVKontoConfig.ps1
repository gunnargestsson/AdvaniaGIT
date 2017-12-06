Function Get-NAVKontoConfig {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\KontoSettings.Json")
    )

    $Config = Get-Content -Path $SettingsFilePath -Encoding UTF8 | Out-String | ConvertFrom-Json
    return $Config
}