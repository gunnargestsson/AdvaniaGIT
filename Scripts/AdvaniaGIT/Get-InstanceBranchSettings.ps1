function Get-InstanceBranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InstanceName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\BranchSettings.Json"
    )
    $allBranchSettings = Get-Content -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath) | Out-String | ConvertFrom-Json
    $branchSettings = ($allBranchSettings.Branches | Where-Object -Property instanceName -EQ $InstanceName)
    if ($branchSettings -eq $null) {
        $branchSettings = @{"branchId" = ""; "databaseServer" = ""; "databaseInstance" = ""; "databaseName" = ""; "instanceName" = ""; "clientServicesPort" = "7046"; "managementServicesPort" = "7045"; "dockerContainerName" = ""; "dockerContainerId" = ""}
    }    
    Return $BranchSettings
}