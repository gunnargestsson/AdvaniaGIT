$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
Check-NAVServiceRunning -SetupParameters $BaseSetupParameters -BranchSettings $BaseBranchSettings

$WebClientUrl = "http://" + $env:COMPUTERNAME + ":$(Get-WebClientPort -MainVersion $SetupParameters.mainVersion)/" + $BaseBranchSettings.instanceName + "/WebClient"
if ($SetupParameters.targetPlatform -eq "Dynamics365") {
    $WebClientUrl += "?aid=fin"
}
Start-Process -FilePath $WebClientUrl
