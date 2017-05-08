Write-Host "Requesting new NAV backup for branch" $SetupParameters.Branchame
Write-Host "Removing NAV License from database before backing up..."
Remove-NAVDatabaseLicense -BranchSettings $BranchSettings
Create-NAVDatabaseBackup -SetupParameters $SetupParameters -BranchSettings $BranchSettings
$LicenseFilePath = Join-Path (Join-Path $SetupParameters.rootPath "License") $SetupParameters.licenseFile
if (Test-Path $LicenseFilePath) {  
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Update-NAVLicense -BranchSettings $BranchSettings -LicenseFilePath $LicenseFilePath
    UnLoad-InstanceAdminTools
}
