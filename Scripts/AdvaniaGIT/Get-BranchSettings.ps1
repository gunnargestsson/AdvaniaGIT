function Get-BranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))  "Data\BranchSettings.Json")
    )
    $allBranchSettings = Get-Content -Path $SettingsFilePath | Out-String | ConvertFrom-Json
    if (![String]::IsNullOrEmpty($SetupParameters.dockerShared) -and !$SetupParameters.BuildMode) {
        $branchSettings = ($allBranchSettings.Branches | Where-Object -Property dockerContainerName -EQ $SetupParameters.projectName)
    } else {
        $branchSettings = ($allBranchSettings.Branches | Where-Object -Property branchId -EQ $SetupParameters.branchId)
    }
    if ($branchSettings -eq $null) {
        $branchSettings = @{
            "branchId" = $SetupParameters.branchId; 
            "projectName" = $SetupParameters.projectName; 
            "databaseServer" = ""; 
            "databaseInstance" = ""; 
            "databaseName" = ""; 
            "instanceServer" = "localhost";
            "instanceName" = ""; 
            "clientServicesPort" = "7046"; 
            "managementServicesPort" = "7045";
            "developerServicesPort" = "7049";
            "dockerContainerName" = "";
            "dockerContainerId" = "";
            "dockerContainerIp" = "";}
        $allBranchSettings.Branches += $BranchSettings
        Set-Content -Path $SettingsFilePath -Value ($allBranchSettings | ConvertTo-Json)        
    } else {
        if (![bool]($BranchSettings.PSObject.Properties.name -match "dockerContainerName")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name dockerContainerName -Value ""
        }
        if (![bool]($BranchSettings.PSObject.Properties.name -match "dockerContainerId")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name dockerContainerId -Value ""
        }
        if (![bool]($BranchSettings.PSObject.Properties.name -match "dockerContainerIp")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name dockerContainerIp -Value ""
        }
        if (![bool]($BranchSettings.PSObject.Properties.name -match "developerServicesPort")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name developerServicesPort -Value "7049"
        }
        if (![bool]($BranchSettings.PSObject.Properties.name -match "instanceServer")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name instanceServer -Value "localhost"
        }
    }
    Return $BranchSettings
}