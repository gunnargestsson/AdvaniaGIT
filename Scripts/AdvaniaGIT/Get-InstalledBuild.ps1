Function Get-InstalledBuild
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters
    )

    $navService = Get-Item -Path (Join-Path $SetupParameters.navServicePath "Microsoft.Dynamics.Nav.Server.exe")
    $navInstallationVersion = (Get-ItemProperty -Path $navService.FullName).VersionInfo.FileVersion    

    return $navInstallationVersion
}
