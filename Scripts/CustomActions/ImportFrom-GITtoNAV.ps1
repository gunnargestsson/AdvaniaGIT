Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
Load-ModelTools -SetupParameters $SetupParameters
$ObjectsPath = Build-Solution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $SetupParameters.ObjectsPath
if ($SetupParameters.objectProperties -eq "false") {
    & (Join-Path $PSScriptRoot 'Export-GITtoSource.ps1')
    Write-Host "Importing All objects..."
    $command = "UPDATE [dbo].[Object] SET [Version List] = '#DELETED' WHERE [ID] < 2000000004"
    Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null
    Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path (Join-Path $SetupParameters.WorkFolder "Source.txt") -ImportAction Overwrite -SynchronizeSchemaChanges Force 
} else {
Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath -MarkToDelete
}
Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Wait
Import-PermissionSets -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
