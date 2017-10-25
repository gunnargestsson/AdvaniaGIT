if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    UnLoad-InstanceAdminTools
}