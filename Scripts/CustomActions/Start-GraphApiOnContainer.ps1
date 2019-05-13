Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ($BranchSettings.dockerContainerId -gt "") {
    Write-Host "Restarting Server Instance on Docker to enable Graph API..."
    Enable-NAVGraphAPI -BranchSettings $BranchSettings  
} else {    
    Write-Host -ForegroundColor Red "Function only available on Docker Container!"
}
