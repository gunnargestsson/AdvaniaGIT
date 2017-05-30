# Remove NAV Environment
& (Join-Path $PSScriptRoot 'Remove-NavEnvironment.ps1')
$BranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId
# Build NAV Environment
& (Join-path $PSScriptRoot 'Build-NavEnvironment.ps1')
# Update from Git
& (Join-path $PSScriptRoot 'ImportFrom-GITtoNAV.ps1')
# Compile All Objects
& (Join-Path $PSScriptRoot 'Start-Compile.ps1')
# Export FOB file
& (Join-Path $PSScriptRoot 'Export-NavFob.ps1')
# Create SQL Backup
& (Join-Path $PSScriptRoot 'Create-NavBackup.ps1')

$backupFileName = (Join-Path $BackupPath "$($SetupParameters.navRelease)-$($SetupParameters.projectName).bak")
$fobFileName = (Join-path $WorkFolder 'AllObjects.fob')

$destination = 'C:\NAVManagementWorkFolder\Build'
# Copy Fob File to...
Move-Item -Path $fobFileName -Destination $destination -Force
# Copy Backup File to...
Move-Item -Path $backupFileName -Destination $destination -Force
# Copy Log file to ...
Get-ChildItem $LogPath | Move-Item -Destination $destination -Force
# Remove NAV Environment
& (Join-Path $PSScriptRoot 'Remove-NavEnvironment.ps1')
