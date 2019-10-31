function Get-ALPaths
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters = (New-Object -TypeName PSObject),
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$ReverseOrder
    )

    $ALPaths = @()
    $WorkspaceFile = Get-ChildItem -Path $SetupParameters.Repository -Filter "*.code-workspace"
    if ($WorkspaceFile -and (Test-Path $WorkspaceFile.FullName)) {
        $WorkspaceFolders = (Get-Content -Path $WorkspaceFile.FullName -Encoding UTF8 | ConvertFrom-Json).folders
        foreach ($WorkspaceFolder in $WorkspaceFolders.path) {
            $WorkspaceFolder = (Join-Path $SetupParameters.Repository $WorkspaceFolder)
            if (Test-Path -Path (Join-Path $WorkspaceFolder "app.json")) {
                $ALPaths += Get-Item -Path $WorkspaceFolder
            }
        }
    } else {
        if ($SetupParameters.ALProjectList) {
            foreach ($ALProject in $SetupParameters.ALProjectList.split(",")) {
                $ALPath = Join-Path $SetupParameters.Repository $ALProject
                if (!(Test-Path $ALPath)) {
                    New-Item -Path $ALPath -ItemType Directory
                }
                if (Test-Path -Path (Join-Path $ALPath "app.json")) {
                    $ALPaths += Get-Item -Path $ALPath
                }
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
    }
    if ($ReverseOrder) { $ALPaths = Reverse-HashTable $ALPaths }
    return $ALPaths
}