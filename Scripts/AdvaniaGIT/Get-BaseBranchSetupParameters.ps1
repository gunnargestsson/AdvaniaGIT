function Get-BaseBranchSetupParameters
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )

    if (!$SetupParameters.baseBranch -or $SetupParameters.baseBranch -eq "") {
        Write-Error "Base Branch not configured in $($SetupParameters.setupPath)!" -ErrorAction Stop
    }
    $BaseBranchSetup = "$($SetupParameters.baseBranch):$(Split-Path $SetupParameters.SetupPath -Leaf)"
    $BaseSetupParameters = git.exe show $BaseBranchSetup
    #for ($i=1;$i -lt $BaseSetupParameters.Length;$i++) {
    #    if (($BaseSetupParameters | Select-Object -Index $i) -match "{") {
    #        return $BaseSetupParameters | Select-Object -Skip $i | Out-String | ConvertFrom-Json
    #    }
    #}
    return $BaseSetupParameters | Out-String | ConvertFrom-Json
}