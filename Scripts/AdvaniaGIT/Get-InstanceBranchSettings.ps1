function Get-InstanceBranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InstanceName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\BranchSettings.Json")
    )
    $allBranchSettings = Get-Content -Path $SettingsFilePath | Out-String | ConvertFrom-Json
    $branchSettings = ($allBranchSettings.Branches | Where-Object -Property instanceName -EQ $InstanceName)
    if ($branchSettings -eq $null) {
        $branchSettings = @{"branchId" = ""; "databaseServer" = ""; "databaseInstance" = ""; "databaseName" = ""; "instanceName" = ""; "clientServicesPort" = "7046"; "developerServicePort" = "7049"; "managementServicesPort" = "7045"; "dockerContainerName" = ""; "dockerContainerId" = ""}
    }    
    Return $BranchSettings
}