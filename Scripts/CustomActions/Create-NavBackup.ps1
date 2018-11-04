Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Write-Host "Requesting new NAV backup for branch" $SetupParameters.projectName
    Write-Host "Removing NAV License from database before backing up..."
    Remove-NAVDatabaseLicense -BranchSettings $BranchSettings
    Create-NAVDatabaseBackup -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    if ($SetupParameters.LicenseFilePath) {        
        if (Test-Path $SetupParameters.LicenseFilePath) {  
            Write-Host "Importing license file from $($SetupParameters.LicenseFilePath)..."
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath
            UnLoad-InstanceAdminTools
        } elseif (Test-Path "c:\run\my\license.flf") {
            Write-Host "Importing license file from c:\run\my\license.flf..."
            Load-InstanceAdminTools -SetupParameters $SetupParameters
            Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath "c:\run\my\license.flf"
            UnLoad-InstanceAdminTools
        } 
    } else {
        Write-Host "No license file defined..."
    }
}