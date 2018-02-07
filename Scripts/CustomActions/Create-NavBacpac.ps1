Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
Write-Host "Requesting new NAV bacpac for branch" $SetupParameters.projectName
if ($BranchSettings.dockerContainerId -gt "") {
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Load-DockerInstanceAdminTools -Session $Session
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ServerInstance)
        Set-NAVServerInstance -ServerInstance $ServerInstance -Stop -Force
    } -ArgumentList $BranchSettings.instanceName
} else {       
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Stop -Force
}

Create-NAVDatabaseBacpac -SetupParameters $SetupParameters -BranchSettings $BranchSettings


if ($BranchSettings.dockerContainerId -gt "") {
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ServerInstance)
        Set-NAVServerInstance -ServerInstance $ServerInstance -Start -Force
    } -ArgumentList $BranchSettings.instanceName
    Remove-PSSession -Session $Session   
} else {       
    Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Start -Force -ErrorAction Stop
    UnLoad-InstanceAdminTools 
}

