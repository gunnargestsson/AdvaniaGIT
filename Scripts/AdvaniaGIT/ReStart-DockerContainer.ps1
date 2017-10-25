function ReStart-DockerContainer
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )
    
    $dockerContainer = Get-DockerContainers | Where-Object -Property Id -ieq $BranchSettings.dockerContainerName
    if (!$dockerContainer) {
        Write-Error "Docker Container $($BranchSettings.dockerContainerName) does not exist!  Please rebuild the NAV Environment." -ErrorAction Stop
    } 
    if ($dockerContainer.Status -match "Exited") {
        Write-Host "Starting Docker Container $($BranchSettings.dockerContainerName)..."
        $dockerContainerName = docker.exe start "$($BranchSettings.dockerContainerName)"

        $WaitForHealty = $true
        $LoopNo = 1
        while ($WaitForHealty -and $LoopNo -lt 20) {        
            $dockerContainer = Get-DockerContainers | Where-Object -Property Id -ieq $BranchSettings.dockerContainerName
            Write-Host "Container status: $($dockerContainer.Status)..."
            $WaitForHealty = $dockerContainer.Status -match "(health: starting)"
            if ($WaitForHealty) { Start-Sleep -Seconds 10 }
            $LoopNo ++
        }
        if (!($dockerContainer.Status -match "(healthy)")) {
            Write-Error "Container $($BranchSettings.dockerContainerName) unable to start !" -ErrorAction Stop
        }
    }
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Edit-DockerHostRegiststration -RemoveHostName $BranchSettings.dockerContainerName -AddHostName $BranchSettings.dockerContainerName -AddIpAddress (Get-DockerIPAddress -Session $Session)
    Remove-PSSession $Session
}
