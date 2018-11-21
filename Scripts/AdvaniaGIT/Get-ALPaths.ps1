function Get-ALPaths
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters = (New-Object -TypeName PSObject)
    )

    $ALPaths = @()

    if ($SetupParameters.ALProjectList) {
        foreach ($ALProject in $SetupParameters.ALProjectList.split(",")) {
            $ALPath = Join-Path $SetupParameters.Repository $ALProject
            if (!(Test-Path $ALPath)) {
                New-Item -Path $ALPath -ItemType Directory
            }
            $ALPaths += Get-Item -Path $ALPath
        }
    } else {
        if (!(Test-Path $SetupParameters.VSCodePath)) {
            New-Item -Path $SetupParameters.VSCodePath -ItemType Directory
        }
        $ALPaths += Get-Item -Path $SetupParameters.VSCodePath


        if (!(Test-Path $SetupParameters.VSCodeTestPath)) {
            New-Item -Path $SetupParameters.VSCodeTestPath -ItemType Directory
        }
        $ALPaths += Get-Item -Path $SetupParameters.VSCodeTestPath

    }

    return $ALPaths
}