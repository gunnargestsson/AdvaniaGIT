Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($SetupParameters.patchNoFunction -ne "") {
    Invoke-Expression $($SetupParameters.patchNoFunction)
}

if ($BranchSettings.dockerContainerId -gt "") {
    Copy-DockerFinSql -SetupParameters $SetupParameters 
    $finsqlexe = (Join-Path $SetupParameters.LogPath 'ApplicationFiles\finsql.exe')    
} else {    
    $finsqlexe = (Join-Path $SetupParameters.navIdePath 'finsql.exe')
}

$IdFile = Join-Path $SetupParameters.LogPath "finsqlsettings.zup"
$params="database=`"$($BranchSettings.databaseName)`",servername=`"$(Get-DatabaseServer -BranchSettings $BranchSettings)`",ID=`"$($IdFile)`""

Write-Host "Running: `"$finsqlexe`" $params" -ForegroundColor Green
Start-Process -FilePath $finsqlexe -ArgumentList $params 

