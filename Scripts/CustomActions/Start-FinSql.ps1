Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($SetupParameters.patchNoFunction -ne "") {
    Invoke-Expression $($SetupParameters.patchNoFunction)
}

$finsqlexe = (Join-Path $SetupParameters.navIdePath 'finsql.exe')
$IdFile = Join-Path $LogPath "finsqlsettings.zup"
if ($BranchSettings.databaseInstance -gt "") {
    $params="database=`"$($BranchSettings.databaseName)`",servername=`"$($BranchSettings.databaseServer)\$($BranchSettings.instanceName)`",ID=`"$($IdFile)`""
} else {
    $params="database=`"$($BranchSettings.databaseName)`",servername=`"$($BranchSettings.databaseServer)`",ID=`"$($IdFile)`""
}
Write-Host "Running: `"$finsqlexe`" $params" -ForegroundColor Green
Start-Process -FilePath $finsqlexe -ArgumentList $params 

