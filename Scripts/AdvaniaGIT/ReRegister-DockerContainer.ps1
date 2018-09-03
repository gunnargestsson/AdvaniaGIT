function ReRegister-DockerContainer
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )
    
    if ([Bool](Get-Module NAVContainerHelper)) {
        Edit-DockerHostRegistration -RemoveHostName $BranchSettings.dockerContainerName -AddHostName $BranchSettings.dockerContainerName -AddIpAddress (Get-NavContainerIpAddress -containerName $BranchSettings.dockerContainerName)        
    } else {
        $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
        Edit-DockerHostRegistration -RemoveHostName $BranchSettings.dockerContainerName -AddHostName $BranchSettings.dockerContainerName -AddIpAddress (Get-DockerIPAddress -Session $Session) 
        Remove-PSSession $Session
    }
}
