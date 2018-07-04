function Get-NAVClientPath
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )

    $versionPaths = (Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") $SetupParameters.navVersion) "Roletailored Client"),
                    (Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") $SetupParameters.mainVersion) "Roletailored Client"),
                    (Get-Item (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") "*\Roletailored Client").FullName)
    foreach ($versionPath in $versionPaths) {        
        if (Test-Path $versionPath) {
            return $versionPath
        }
    }
    Write-Error "NAV Client Path not found!"
    thow
}
