# Inspired by
# https://www.axians-infoma.com/navblog/dynamics-365-bc-extension-build-in-tfs-vsts-using-containers/
#

if ($BranchSettings.dockerContainerName -eq "") {
    Write-Host -ForegroundColor Red "VSIX download required Docker Container!"
    throw
}

Copy-DockerALExtension -SetupParameters $SetupParameters -BranchSettings $BranchSettings

if ($SetupParameters.BuildMode) {
    $BranchWorkFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
    New-Item -Path $BranchWorkFolder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path (Join-Path $BranchWorkFolder 'vsix') -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    $vsixFile = (Get-ChildItem -Path $SetupParameters.LogPath -Filter "al*.vsix")[0]
    Copy-Item -Path $vsixFile.FullName -Destination (Join-Path $BranchWorkFolder 'vsix\al.zip')
    Expand-Archive -Path (Join-Path $BranchWorkFolder 'vsix\al.zip') -DestinationPath (Join-Path $BranchWorkFolder 'vsix') -Force
    Remove-Item -Path (Join-Path $BranchWorkFolder 'vsix\al.zip')
}

