function Get-EnvironmentNo
{
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\BuildSettings.Json"
    )
    $BuildSettings = Get-BuildSettings -SettingsFilePath $SettingsFilePath
    [int]$LastBuildNo = $BuildSettings.LastBuildNo
    $LastBuildNo++
    $BuildSettings.LastBuildNo = $LastBuildNo.ToString().PadLeft(7,'0')
    Update-BuildSettings -BuildSettings $BuildSettings
    Return $BuildSettings.LastBuildNo
}