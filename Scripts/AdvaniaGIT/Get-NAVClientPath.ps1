function Get-NAVClientPath
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$ErrorIfNotFound
    )

    $versionPaths = (Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") $SetupParameters.navVersion) "Roletailored Client"),
                    (Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") $SetupParameters.mainVersion) "Roletailored Client"),
                    (Get-Item (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") "*\Roletailored Client").FullName)
    foreach ($versionPath in $versionPaths) {
        if (![String]::IsNullOrEmpty($versionPath)) {
            if (Test-Path $versionPath) {
                return $versionPath
            }
        }
    }
    if ($ErrorIfNotFound) {
        Write-Host -ForegroundColor Red "Installed NAV Client Path not found!"    
        Throw
    } else {
        Write-Verbose "Installed NAV Client Path not found!"
    }
}
