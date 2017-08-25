Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
if ($BranchSettings.dockerContainerId -gt "") {
    $WebClientUrl = "http://" + $BranchSettings.dockerContainerName + "/" + $BranchSettings.instanceName + "/WebClient"
} else {    
    $WebClientUrl = "http://" + $env:COMPUTERNAME + ":$(Get-WebClientPort -MainVersion $SetupParameters.mainVersion)/" + $BranchSettings.instanceName + "/WebClient"
}
if ($SetupParameters.targetPlatform -eq "Dynamics365") {
    $WebClientUrl += "?aid=fin"
}
Start-Process -FilePath $WebClientUrl
