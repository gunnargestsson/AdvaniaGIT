function Get-NAVServicePath
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$ErrorIfNotFound
    )
    $versionPaths = (Join-Path (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") $SetupParameters.navVersion) "Service"),
                    (Join-Path (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") $SetupParameters.mainVersion) "Service"),
                    (Get-Item (Join-Path (Join-Path ${env:ProgramFiles} "Microsoft Dynamics NAV") "*\Service").FullName)
    foreach ($versionPath in $versionPaths) {        
        if (Test-Path $versionPath) {
            return $versionPath
        }
    }
    if ($ErrorIfNotFound) {
        Write-Host -ForegroundColor Red "Installed NAV Service Path not found!"
        Throw
    } else {
        Write-Verbose "Installed NAV Service Path not found!"
    }
}
