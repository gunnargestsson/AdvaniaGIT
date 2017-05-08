Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($SetupParameters.patchNoFunction -ne "") {
    Invoke-Expression $($SetupParameters.patchNoFunction)
}

$finsqlexe = (Join-Path $SetupParameters.navIdePath 'finsql.exe')
$IdFile = Join-Path $LogPath "finsqlsettings.zup"
$params="database=`"$($BranchSettings.databaseName)`",servername=`"$(Get-DatabaseServer -BranchSettings $BranchSettings)`",ID=`"$($IdFile)`""

Write-Host "Running: `"$finsqlexe`" $params" -ForegroundColor Green
Start-Process -FilePath $finsqlexe -ArgumentList $params 

