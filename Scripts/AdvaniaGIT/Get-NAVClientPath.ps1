function Get-NAVClientPath
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    $versionPath = (Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") $SetupParameters.navVersion) "Roletailored Client")
    if (Test-Path $versionPath) {
        return $versionPath
    }
    else {      
        return (Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") $SetupParameters.mainVersion) "Roletailored Client")
    }
}
