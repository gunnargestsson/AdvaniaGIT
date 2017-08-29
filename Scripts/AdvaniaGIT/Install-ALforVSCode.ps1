Function Install-ALforVSCode
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings
    )

    $Extension = Get-Item -Path (Join-Path $SetupParameters.LogPath "*.vsix")
    if ($Extension) {
        $VSCodePaths = @((Join-Path $env:ProgramFiles "Microsoft VS Code\Code.exe"); (Join-Path ${env:ProgramFiles(x86)} "Microsoft VS Code\Bin\Code.cmd"))
        foreach ($VSCodePath in $VSCodePaths) {
            if (Test-Path $VSCodePath) {
                & Code --install-extension $($Extension.FullName)
            }
        }
    }
}