function Get-DockerBranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DockerContainerName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\BranchSettings.Json")
    )
    $allBranchSettings = Get-Content -Path $SettingsFilePath | Out-String | ConvertFrom-Json
    $branchSettings = ($allBranchSettings.Branches | Where-Object -Property dockerContainerName -EQ $DockerContainerName)
    if ($branchSettings -eq $null) {
        $branchSettings = @{"branchId" = ""; "databaseServer" = ""; "databaseInstance" = ""; "databaseName" = ""; "instanceName" = ""; "clientServicesPort" = "7046"; "managementServicesPort" = "7045"; "developerServicesPort" = "7049"; "dockerContainerName" = ""; "dockerContainerId" = ""; "dockerContainerIp" = ""}
    }    
    Return $BranchSettings
}