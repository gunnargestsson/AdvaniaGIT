function Update-DockerSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$DockerSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\DockerSettings.Json") 
    )     
    Set-Content -Path $SettingsFilePath -Value ($DockerSettings | ConvertTo-Json) -Encoding UTF8 -Force
    Write-Verbose -Message "Docker Settings saved"
}