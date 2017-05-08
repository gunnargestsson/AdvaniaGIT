function Get-NAVServicePath
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    $versionPath = (Join-Path (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") $SetupParameters.navVersion) "Service")
    if (Test-Path $versionPath) {
        return $versionPath
    }
    else {      
        return (Join-Path (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") $SetupParameters.mainVersion) "Service")
    }
}
