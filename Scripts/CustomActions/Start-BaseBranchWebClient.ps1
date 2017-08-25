$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
Check-NAVServiceRunning -SetupParameters $BaseSetupParameters -BranchSettings $BaseBranchSettings

if ($BaseBranchSettings.dockerContainerId -gt "") {
    $WebClientUrl = "http://" + $BaseBranchSettings.dockerContainerName + "/" + $BaseBranchSettings.instanceName + "/WebClient"
} else {    
    $WebClientUrl = "http://" + $env:COMPUTERNAME + ":$(Get-WebClientPort -MainVersion $SetupParameters.mainVersion)/" + $BaseBranchSettings.instanceName + "/WebClient"
}

if ($SetupParameters.targetPlatform -eq "Dynamics365") {
    $WebClientUrl += "?aid=fin"
}

Start-Process -FilePath $WebClientUrl
