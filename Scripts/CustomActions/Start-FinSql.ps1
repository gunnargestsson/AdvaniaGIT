Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($SetupParameters.patchNoFunction -ne "") {
    Invoke-Expression $($SetupParameters.patchNoFunction)
}

if ($BranchSettings.dockerContainerId -gt "") {
    $clientPath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    $finsqlexe = Join-Path $clientPath '\finsql.exe'
    $IdFile = Join-Path $clientPath 'finsqlsettings.zup'
} else {    
    $finsqlexe = (Join-Path $SetupParameters.navIdePath 'finsql.exe')
    $IdFile = "$($SetupParameters.navRelease)-$($SetupParameters.projectName).zup"
}

$params="database=`"$($BranchSettings.databaseName)`",servername=`"$(Get-DatabaseServer -BranchSettings $BranchSettings)`",ID=`"$($IdFile)`""
if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 12) {
  $params += ",generatesymbolreference=1"
}

if ([String]::IsNullOrEmpty($SetupParameters.dockerAuthentication)) {
    $params += ",ntauthentication=1"
} else {
    switch ($SetupParameters.dockerAuthentication)
    {
        "NavUserPassword" { $params += ",ntauthentication=0" }
        default {$params += ",ntauthentication=1"}
    }
}


Write-Host "Running: `"$finsqlexe`" $params" -ForegroundColor Green
Start-Process -FilePath $finsqlexe -ArgumentList $params 

