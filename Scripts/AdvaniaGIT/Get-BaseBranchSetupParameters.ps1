function Get-BaseBranchSetupParameters
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )

    Check-GitNotUnattached 
    Check-GitCommitted

    if (!$SetupParameters.baseBranch -or $SetupParameters.baseBranch -eq "") {
        Write-Error "Base Branch not configured in $($SetupParameters.setupPath)!" -ErrorAction Stop
    }
    $sourcebranch = git.exe rev-parse --abbrev-ref HEAD 
    Write-Host Switching Repository to $SetupParameters.baseBranch
    $result = git.exe checkout --force $SetupParameters.baseBranch --quiet 
    Write-Host Reading configuration from $SetupParameters.baseBranch
    $BaseSetupParameters = Get-Content $SetupParameters.setupPath | Out-String | ConvertFrom-Json
    Write-Host Switching Repository to $sourcebranch
    $result = git.exe checkout --force $sourcebranch --quiet
    return $BaseSetupParameters
}