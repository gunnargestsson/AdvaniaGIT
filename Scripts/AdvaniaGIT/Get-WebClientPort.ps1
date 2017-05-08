function Get-WebClientPort
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$MainVersion,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\NAVVersions.Json"
    )
                
    $navVersions = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | ConvertFrom-Json
    $webClientPort = ($navVersions.Releases | Where-Object -Property mainVersion -EQ $MainVersion).webClientPort
    
    Return $webClientPort
}