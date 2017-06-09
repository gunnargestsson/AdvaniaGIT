Function Get-BaseObjectsPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    if ($SetupParameters.targetPlatform -EQ "Dynamics365") {
        $BaseObjects = "D365" + $SetupParameters.navSolution + '.txt'
        if (Test-Path -Path (Join-Path $SetupParameters.WorkFolder $BaseObjects)) {
            return (Join-Path $SetupParameters.WorkFolder $BaseObjects)
        }
    }
    $BaseObjects = $SetupParameters.navRelease + $SetupParameters.navSolution + '.txt'
    if (Test-Path -Path (Join-Path $SetupParameters.WorkFolder $BaseObjects)) {
        return (Join-Path $SetupParameters.WorkFolder $BaseObjects)
    }
    $BaseObjects = $SetupParameters.navSolution + '.txt'
        if (Test-Path -Path (Join-Path $SetupParameters.WorkFolder $BaseObjects)) {
        return (Join-Path $SetupParameters.WorkFolder $BaseObjects)
    }
    Write-Error "Base Application not found" -ErrorAction Stop
}

    