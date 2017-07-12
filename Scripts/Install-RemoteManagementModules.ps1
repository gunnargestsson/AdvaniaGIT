function New-DesktopShortcut
{
	Param
	(
		[Parameter(Mandatory=$true)]
		[string]$Name,
		[Parameter(Mandatory=$true)]
		[string]$TargetPath,
		[Parameter(Mandatory=$false)]
		[string]$WorkingDirectory,
		[Parameter(Mandatory=$false)]
		[string]$IconLocation,
		[Parameter(Mandatory=$false)]
		[string]$Arguments
	)

    $filename = Join-Path $env:SystemDrive "Users\Public\Desktop\$Name.lnk"
    if (!(Test-Path -Path $filename)) {
        $Shell =  New-object -comobject WScript.Shell
        $Shortcut = $Shell.CreateShortcut($filename)
        $Shortcut.TargetPath = $TargetPath
        if (!$WorkingDirectory) {
            $WorkingDirectory = Split-Path $TargetPath
        }
        $Shortcut.WorkingDirectory = $WorkingDirectory
        if ($Arguments) {
            $Shortcut.Arguments = $Arguments
        }
        if ($IconLocation) {
            $Shortcut.IconLocation = $IconLocation
        }
        $Shortcut.save()
    }
}

function Remove-DesktopShortcut
{
	Param
	(
		[Parameter(Mandatory=$true)]
		[string]$Name
        )

    $filename = Join-Path $env:SystemDrive "Users\Public\Desktop\$Name.lnk"
    Remove-Item $filename -Force -ErrorAction Ignore
}

Install-PackageProvider Nuget –force –verbose
Install-Module –Name PowerShellGet –Force –Verbose

$PowerShellGet = Get-Module PowerShellGet -list | Select-Object Name,Version,Path
if ($PowerShellGet) {
    Install-Module AzureRM -SkipPublisherCheck -Force -AllowClobber
    Get-Module AzureRM -list | Select-Object Name,Version,Path
    Install-Module AzureAD -SkipPublisherCheck -Force -AllowClobber
    Get-Module AzureAD -list | Select-Object Name,Version,Path
} else {
    Write-Host "Please manually install PackageManagement modules..."
    Start-Process "https://blogs.msdn.microsoft.com/powershell/2016/09/29/powershellget-and-packagemanagement-in-powershell-gallery-and-github/"
}

# Create Icons on Desktop
$ScriptPath = Join-Path $PSScriptRoot "Start-RemoteConfiguration.ps1"
Remove-DesktopShortcut -Name "Azure Remote Configuration"
New-DesktopShortcut -Name "Azure Remote Configuration" -TargetPath "powershell.exe" -WorkingDirectory $PSScriptRoot -Arguments "-noprofile -file ""${ScriptPath}"""

$ScriptPath = Join-Path $PSScriptRoot "Start-RemoteManagement.ps1"
Remove-DesktopShortcut -Name "Azure Remote Management"
New-DesktopShortcut -Name "Azure Remote Management" -TargetPath "powershell.exe" -WorkingDirectory $PSScriptRoot -Arguments "-noprofile -file ""${ScriptPath}"""

$ScriptPath = Join-Path $PSScriptRoot "Start-AzureSqlManagement.ps1"
Remove-DesktopShortcut -Name "Azure Sql Remote Management"
New-DesktopShortcut -Name "Azure Sql Remote Management" -TargetPath "powershell.exe" -WorkingDirectory $PSScriptRoot -Arguments "-noprofile -file ""${ScriptPath}"""