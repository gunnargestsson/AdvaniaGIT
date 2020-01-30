if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings    
} else {
    $FileName = Join-Path $SetupParameters.LogPath 'AddIns.zip'
    if ($SetupParameters.addinsUrl) {
        Download-NAVFile -Url $SetupParameters.addinsUrl -FileName $FileName
    } else {
        Download-NAVFile -Url "https://addins.navleiga.is/addins.zip" -FileName $FileName
    }

    if ([String]::IsNullOrEmpty($SetupParameters.navServicePath)) {
        $AddInsPath = Join-Path (Get-NAVServicePath -SetupParameters $SetupParameters -ErrorIfNotFound) "Add-ins\AdvaniaGIT"
    } else  {
        $AddInsPath = Join-Path $SetupParameters.navServicePath "Add-ins\AdvaniaGIT"
    }
    New-Item -Path $AddInsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    Expand-Archive -LiteralPath $FileName -DestinationPath $AddInsPath -Force
}