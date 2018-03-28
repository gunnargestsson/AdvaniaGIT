if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Load-InstanceAppTools -SetupParameters $SetupParameters
    Get-NAVTenant -ServerInstance $BranchSettings.instanceName | Start-NAVAppDataUpgrade -Force
    UnLoad-InstanceAppTools
    UnLoad-InstanceAdminTools
}