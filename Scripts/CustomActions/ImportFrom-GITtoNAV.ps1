Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
Load-ModelTools -SetupParameters $SetupParameters
$ObjectsPath = Build-Solution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath
Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath -MarkToDelete
Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Wait
Import-PermissionSets -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
