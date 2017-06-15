Function Get-CurrentInstallSource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$MainVersion
    )

    return (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DynamicsNav$MainVersion" -Name InstallSource).InstallSource
}