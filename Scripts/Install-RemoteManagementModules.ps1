Install-PackageProvider Nuget –force –verbose
Install-Module –Name PowerShellGet –Force –Verbose

$PowerShellGet = Get-Module PowerShellGet -list | Select-Object Name,Version,Path
if ($PowerShellGet) {
    Install-Module AzureRM -SkipPublisherCheck -Force -AllowClobber
    Get-Module AzureRM -list | Select-Object Name,Version,Path
} else {
    Write-Host "Please manually install PackageManagement modules..."
    Start-Process "https://blogs.msdn.microsoft.com/powershell/2016/09/29/powershellget-and-packagemanagement-in-powershell-gallery-and-github/"
}
