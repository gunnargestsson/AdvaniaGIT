if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Write-Host "Restarting $($BranchSettings.instanceName) to start tests on clean service tier..."
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Restart 
    Sync-NAVTenant -ServerInstance $BranchSettings.instanceName -Tenant default -Mode Sync -Force     
    UnLoad-InstanceAdminTools
}
