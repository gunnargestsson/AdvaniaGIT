if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Write-Host "Requesting new NAV bacpac for branch" $SetupParameters.Branchame
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Stop -Force
    Create-NAVDatabaseBacpac -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Start -Force -ErrorAction Stop
    UnLoad-InstanceAdminTools 
}