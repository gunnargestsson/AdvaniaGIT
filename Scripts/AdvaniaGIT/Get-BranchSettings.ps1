function Get-BranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))  "Data\BranchSettings.Json")
    )
    $allBranchSettings = Get-Content -Path $SettingsFilePath | Out-String | ConvertFrom-Json
    $branchSettings = ($allBranchSettings.Branches | Where-Object -Property branchId -EQ $SetupParameters.branchId)
    if ($branchSettings -eq $null) {
        $branchSettings = @{
            "branchId" = $SetupParameters.branchId; 
            "projectName" = $SetupParameters.projectName; 
            "databaseServer" = ""; 
            "databaseInstance" = ""; 
            "databaseName" = ""; 
            "instanceName" = ""; 
            "clientServicesPort" = "7046"; 
            "managementServicesPort" = "7045";
            "developerServicePort" = "7049";
            "dockerContainerName" = "";
            "dockerContainerId" = ""}
        $allBranchSettings.Branches += $BranchSettings
        Set-Content -Path $SettingsFilePath -Value ($allBranchSettings | ConvertTo-Json)        
    } else {
        if (![bool]($BranchSettings.PSObject.Properties.name -match "dockerContainerName")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name dockerContainerName -Value ""
        }
        if (![bool]($BranchSettings.PSObject.Properties.name -match "dockerContainerId")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name dockerContainerId -Value ""
        }
        if (![bool]($BranchSettings.PSObject.Properties.name -match "developerServicePort")) {
            $BranchSettings | Add-Member -MemberType NoteProperty -Name developerServicePort -Value "7049"
        }
    }
    Return $BranchSettings
}