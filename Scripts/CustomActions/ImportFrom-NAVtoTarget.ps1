Check-GitNotUnattached
Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    $ExportPath = Join-Path $SetupParameters.WorkFolder 'Target.txt'
    Remove-Item -Path $ExportPath -Force -ErrorAction SilentlyContinue
    Write-Host -Object 'Exporting all files...'
    Export-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ExportTxtSkipUnlicensed -Path $ExportPath -Filter 'Compiled=0|1' 
}