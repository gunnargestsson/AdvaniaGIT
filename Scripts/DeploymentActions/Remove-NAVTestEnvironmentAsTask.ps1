Write-Host "Remove instance and database for $($DeploymentSettings.instanceName)..."

# Find NAV major version based on the repository NAV version - client
if (Test-Path "$($Env:ProgramFiles)\Microsoft Dynamics NAV\*\Service") {
    $SetupParameters | Add-Member "navServicePath" (Get-Item -Path "$($Env:ProgramFiles)\Microsoft Dynamics NAV\*\Service").FullName
    $SetupParameters | Add-Member "mainVersion" (Split-Path (Split-Path $SetupParameters.navServicePath -Parent) -Leaf)
    $SetupParameters | Add-Member "navRelease" (Get-NAVRelease -mainVersion (Split-Path (Split-Path $SetupParameters.navServicePath -Parent) -Leaf))
    $SetupParameters | Add-Member "navVersion" (Get-Item -Path (Join-Path $SetupParameters.navServicePath "Microsoft.Dynamics.Nav.Server.exe")).VersionInfo.ProductVersion
}
if (Test-Path "$(${env:ProgramFiles(x86)})\Microsoft Dynamics NAV\*\Roletailored Client") {
    $SetupParameters | Add-Member "navIdePath" (Get-Item -Path "$(${env:ProgramFiles(x86)})\Microsoft Dynamics NAV\*\Roletailored Client").FullName
}

$SetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $DeploymentSettings.branchId -Force
$BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
if ($BranchSettings.instanceName -ieq $DeploymentSettings.instanceName) {
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    Remove-NAVEnvironment -BranchSettings $BranchSettings
    UnLoad-InstanceAdminTools
}
