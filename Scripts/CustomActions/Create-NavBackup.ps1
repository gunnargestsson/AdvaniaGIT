Write-Host "Requesting new NAV backup for branch" $SetupParameters.Branchame
Write-Host "Removing NAV License from database before backing up..."
Remove-NAVDatabaseLicense -BranchSettings $BranchSettings
Create-NAVDatabaseBackup -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if (Test-Path $SetupParameters.LicenseFilePath) {  
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $SetupParameters.LicenseFilePath
    UnLoad-InstanceAdminTools
}
