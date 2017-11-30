Function Update-NAVKontoConfig {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$KontoConfig,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\KontoSettings.Json")
    )

    Set-Content -Path $SettingsFilePath -Value ($KontoConfig | ConvertTo-Json -Depth 5)             
}