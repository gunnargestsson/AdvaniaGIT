Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Write-Host "Requesting new NAV backup for branch" $SetupParameters.projectName
    Write-Host "Removing NAV License from database before backing up..."
    Remove-NAVDatabaseLicense -BranchSettings $BranchSettings
    Create-NAVDatabaseBackup -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    if (Test-Path $SetupParameters.LicenseFilePath) {  
        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath
        UnLoad-InstanceAdminTools
    }
}