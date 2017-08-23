function Get-GITSettings
{
    param (
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\GITSettings.Json")
    )
                
    $GITSettings = Get-Content -Path $SettingsFilePath | Out-String | ConvertFrom-Json
    if (![bool]($GITSettings.PSObject.Properties.name -match "dockerContainerName")) {
            $GITSettings | Add-Member -MemberType NoteProperty -Name rootPath -Value (Split-Path -Parent $GITSettings.workFolder)
        }
    Write-Verbose -Message "Settings loaded"
    Return $GITSettings
}