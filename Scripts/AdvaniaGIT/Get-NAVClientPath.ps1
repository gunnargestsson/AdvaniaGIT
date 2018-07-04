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
                    (Join-Path (Join-Path ${env:ProgramFiles(x86)} "Microsoft Dynamics NAV") "*\Roletailored Client")
    foreach ($versionPath in $versionPaths) {
        if (Test-Path $versionPath) {
            return (Get-Item -Path $versionPath).FullName
        }
    }
    if ($ErrorIfNotFound) {
        Write-Host -ForegroundColor Red "Installed NAV Client Path not found!"    
        Throw
    } else {
        Write-Verbose "Installed NAV Client Path not found!"
    }
}
