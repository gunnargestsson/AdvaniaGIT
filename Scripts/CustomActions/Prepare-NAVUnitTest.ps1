if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings -RestartService
    UnLoad-InstanceAdminTools
}