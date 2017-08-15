Function Get-InstalledBuild
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters
    )
    
    $navServicePath = Join-Path $SetupParameters.navServicePath "Microsoft.Dynamics.Nav.Server.exe"
    if (Test-Path $navServicePath) {
        $navService = Get-Item -Path $navServicePath
        $navInstallationVersion = (Get-ItemProperty -Path $navService.FullName).VersionInfo.FileVersion
    }

    return $navInstallationVersion
}
