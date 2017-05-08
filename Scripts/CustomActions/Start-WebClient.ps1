Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
$WebClientUrl = "http://" + $env:COMPUTERNAME + ":$(Get-WebClientPort -MainVersion $SetupParameters.mainVersion)/" + $BranchSettings.instanceName + "/WebClient"
if ($SetupParameters.targetPlatform -eq "Dynamics365") {
    $WebClientUrl += "?aid=fin"
}
Start-Process -FilePath $WebClientUrl
