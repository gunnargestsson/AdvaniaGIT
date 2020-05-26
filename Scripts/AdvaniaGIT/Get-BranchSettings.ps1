function Get-BranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))  "Data\BranchSettings.Json")
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
        $content = [System.Text.Encoding]::UTF8.GetBytes(($allBranchSettings | ConvertTo-Json))
        $file.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
        $file.Write($content, 0, $content.Length)
        $file.SetLength($content.Length)
        $file.Flush()        
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
    $file.Dispose()
    Return $BranchSettings
}