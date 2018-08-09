if ($BranchSettings.dockerContainerName -gt "") {
    if ([Bool](Get-Module NAVContainerHelper)) {
       Edit-DockerHostRegiststration -RemoveHostName $BranchSettings.dockerContainerName -AddHostName $BranchSettings.dockerContainerName -AddIpAddress (Get-NavContainerIpAddress -containerName $BranchSettings.dockerContainerName)        
    } else {
        $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
        Edit-DockerHostRegiststration -RemoveHostName $BranchSettings.dockerContainerName -AddHostName $BranchSettings.dockerContainerName -AddIpAddress (Get-DockerIPAddress -Session $Session) 
        Remove-PSSession $Session
    }
}
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
