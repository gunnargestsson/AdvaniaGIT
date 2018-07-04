function Get-NAVServicePath
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    $versionPaths = (Join-Path (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") $SetupParameters.navVersion) "Service"),
                    (Join-Path (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") $SetupParameters.mainVersion) "Service"),
                    (Get-Item (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") "*\Service").FullName)
    foreach ($versionPath in $versionPaths) {        
        if (Test-Path $versionPath) {
            return $versionPath
        }
    }
    Write-Error "NAV Service Path not found!"
    thow

}
