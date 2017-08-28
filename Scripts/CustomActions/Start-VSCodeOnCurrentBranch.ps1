Check-NAVServiceRunning -SetupParameters $SetupParameters -BranchSettings $BranchSettings

New-NAVAppJson -SetupParameters $SetupParameters
Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BranchSettings
$VSCodePaths = @((Join-Path $env:ProgramFiles "Microsoft VS Code\Code.exe"); (Join-Path ${env:ProgramFiles(x86)} "Microsoft VS Code\Code.exe"))
foreach ($VSCodePath in $VSCodePaths) {
    if (Test-Path $VSCodePath) {
        & $VSCodePath "$($SetupParameters.VSCodePath)"
    }
}

