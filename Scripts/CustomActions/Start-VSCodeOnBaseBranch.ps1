$BaseSetupParameters = Get-BaseBranchSetupParameters -SetupParameters $SetupParameters
$BaseBranchSettings = Get-BranchSettings -SetupParameters $BaseSetupParameters
Check-NAVServiceRunning -SetupParameters $BaseSetupParameters -BranchSettings $BaseBranchSettings

if (!(Test-Path $SetupParameters.VSCodePath)) {
    New-Item -Path $SetupParameters.VSCodePath -ItemType Directory
}

$ALTestPath = "$($SetupParameters.VSCodePath)$(Split-Path $SetupParameters.testObjectsPath -Leaf)"
if (!(Test-Path $ALTestPath)) {
    New-Item -Path $ALTestPath -ItemType Directory
}

New-NAVAppJson -SetupParameters $SetupParameters
Update-NAVLaunchJson -SetupParameters $SetupParameters -BranchSettings $BaseBranchSettings
$VSCodePaths = @((Join-Path $env:ProgramFiles "Microsoft VS Code\Code.exe"); (Join-Path ${env:ProgramFiles(x86)} "Microsoft VS Code\Code.exe"))
foreach ($VSCodePath in $VSCodePaths) {
    if (Test-Path $VSCodePath) {
        Start-Process -FilePath $VSCodePath -ArgumentList "$($SetupParameters.VSCodePath)"
        Start-Process -FilePath $VSCodePath -ArgumentList "${ALTestPath}"                
    }
}
