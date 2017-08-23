function Update-GITSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$GITSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\GITSettings.Json")
    )
                
    Set-Content -Path $SettingsFilePath -Value ($GITSettings | ConvertTo-Json)             
}