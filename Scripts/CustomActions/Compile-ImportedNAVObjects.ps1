if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-ModelTools -SetupParameters $SetupParameters
    Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    Import-PermissionSets -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    UnLoad-ModelTools
}