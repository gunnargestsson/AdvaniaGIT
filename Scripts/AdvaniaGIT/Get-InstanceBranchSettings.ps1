function Get-InstanceBranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InstanceName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\BranchSettings.Json")
    )
    $file = $null
    while (!($file)) {
        try {
            $file = [System.IO.File]::Open($SettingsFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read)
        } catch [System.IO.IOException]  {
            Start-Sleep -Seconds 1
        }
    }
    $content = New-Object System.Byte[] ($file.Length)
    $file.Read($content, 0, $file.Length) | Out-Null    
    $allBranchSettings = [System.Text.Encoding]::UTF8.GetString($content) | Out-String | ConvertFrom-Json    
    $branchSettings = ($allBranchSettings.Branches | Where-Object -Property instanceName -EQ $InstanceName)
    if ($branchSettings -eq $null) {
        $branchSettings = @{"branchId" = ""; "databaseServer" = ""; "databaseInstance" = ""; "databaseName" = ""; "instanceName" = ""; "clientServicesPort" = "7046"; "managementServicesPort" = "7045"; "developerServicesPort" = "7049"; "dockerContainerName" = ""; "dockerContainerId" = ""; "dockerContainerIp" = ""}
    }
    $file.Dispose()    
    Return $BranchSettings
}