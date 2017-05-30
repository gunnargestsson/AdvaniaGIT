param
(
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
[String]$Installfolder
)

if (!$InstallFolder) {
  $Installfolder = $PSScriptRoot
}


# Install Powershell Path for the Installation Folder
if (-not (([Environment]::GetEnvironmentVariable('PSModulePath','Machine')) -like "*$Installfolder*")) 
{
    Write-Host -Object "Extending PSModulePath with $Installfolder" -ForegroundColor Green
    $env:PSModulePath = $env:PSModulePath + ';' + $Installfolder
    Write-Host -Object "Extending Computer wide PSModulePath with $PSScriptRoot" -ForegroundColor Green
    [Environment]::SetEnvironmentVariable('PSModulePath',[Environment]::GetEnvironmentVariable('PSModulePath','Machine')+';'+$Installfolder,'Machine')

    Write-Host 'Importing the modules' -ForegroundColor Green
    Import-Module AdvaniaGIT -DisableNameChecking -Global

} else 
{
    Write-Host -Object "PSModulePath already includes $Installfolder, skipping the setting" -ForegroundColor Green
}


# Create StartPowerShell.cmd file in Installation Folder
$startPowerShell = (Join-Path $env:SystemRoot 'StartPowerShell.cmd')
if (Test-Path $startPowerShell) {
  Remove-Item -Path $startPowerShell
}
New-Item -Path $startPowerShell -ItemType File

$CmdFile = "@echo off`r`n" + ` 
           "PowerShell.exe -noprofile -file " + (Join-Path $Installfolder 'Start-CustomAction.ps1 %1 %2 %3 %4') + "`r`n"
Set-Content $startPowerShell $CmdFile -Exclude ASCII

# Copy CustomActions.xml to SourceTree Settings
if (Test-Path (Join-Path $env:LOCALAPPDATA 'Atlassian\SourceTree')) {
  if (Test-Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'SourceTree\customactions.xml')) {
    Copy-Item -Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'SourceTree\CustomActions.xml') -Destination (Join-Path $env:LOCALAPPDATA 'Atlassian\SourceTree') -Force
  }
}
