# Inspired by
# https://www.axians-infoma.com/navblog/dynamics-365-bc-extension-build-in-tfs-vsts-using-containers/
#

if ($BranchSettings.dockerContainerName -eq "") {
    Write-Host -ForegroundColor Red "Symbols required Docker Container!"
    throw
}

$baseUrl = "http://$($BranchSettings.dockerContainerName):$($BranchSettings.developerServicesPort)/$($BranchSettings.instanceName)/dev/packages"
$appUrl = $baseUrl + "?publisher=Microsoft&appName=Application&versionText=$($SetupParameters.navVersion)"
$sysUrl = $baseurl + "?publisher=Microsoft&appName=System&versionText=$($SetupParameters.navVersion)"

Write-Host "Downloading Application from $appUrl..."
Invoke-RestMethod -Method Get -Uri ($appUrl) -OutFile (Join-Path $SetupParameters.LogPath 'Application.app') -UseDefaultCredentials
Write-Host "Downloading System from $sysUrl..."
Invoke-RestMethod -Method Get -Uri ($sysUrl) -OutFile (Join-Path $SetupParameters.LogPath 'System.app') -UseDefaultCredentials

if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.WorkFolder $SetupParameters.branchId
    New-Item -Path $BranchWorkFolder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path (Join-Path $BranchWorkFolder 'Symbols') -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -Path (Join-Path $BranchWorkFolder 'Symbols') -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Move-Item -Path (Join-Path $SetupParameters.LogPath 'Application.app') -Destination (Join-Path $BranchWorkFolder 'Symbols') -Force
    Move-Item -Path (Join-Path $SetupParameters.LogPath 'System.app') -Destination (Join-Path $BranchWorkFolder 'Symbols') -Force
}

