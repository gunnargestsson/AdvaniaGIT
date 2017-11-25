function Get-GITSettings
{
    param (
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\GITSettings.Json")
    )
                
    $GITSettings = Get-Content -Path $SettingsFilePath | Out-String | ConvertFrom-Json
    if (![bool]($GITSettings.PSObject.Properties.name -match "rootPath")) {
            $GITSettings | Add-Member -MemberType NoteProperty -Name rootPath -Value (Split-Path -Parent $GITSettings.workFolder)
        }
    ## Defaults added
    if (![bool]($GITSettings.PSObject.Properties.name -match "buildSourcePath")) {
            $GITSettings | Add-Member -MemberType NoteProperty -Name buildSourcePath -Value "Source"
        }
    if (![bool]($GITSettings.PSObject.Properties.name -match "filesEncoding")) {
            $GITSettings | Add-Member -MemberType NoteProperty -Name filesEncoding -Value "cp850"
        }
    Write-Verbose -Message "Settings loaded"
    Return $GITSettings
}