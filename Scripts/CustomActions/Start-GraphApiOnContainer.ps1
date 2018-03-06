Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($BranchSettings.dockerContainerId -gt "") {
    Write-Host "Restarting Server Instance on Docker to enable Graph API..."
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Enable-NAVGraphAPI -Session $Session 
    Remove-PSSession -Session $Session    
} else {    
    Write-Host -ForegroundColor Red "Function only available on Docker Container!"
}
