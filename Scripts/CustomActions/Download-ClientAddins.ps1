if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

$FileName = Join-Path $SetupParameters.LogPath 'AddIns.zip'
Download-NAVFile -Url "https://addins.navleiga.is/addins.zip" -FileName $FileName
$AddInsPath = Join-Path $SetupParameters.navIdePath "Add-ins\AdvaniaGIT"
New-Item -Path $AddInsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
Expand-Archive -LiteralPath $FileName -DestinationPath $AddInsPath -Force
