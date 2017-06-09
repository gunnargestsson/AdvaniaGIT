function Get-NAVVersions
{
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\NAVVersions.Json"
    )
                
    $navVersions = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json       
    Return $navVersions
}