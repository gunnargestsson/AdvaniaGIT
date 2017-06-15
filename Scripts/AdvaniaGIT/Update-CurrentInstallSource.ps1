Function Update-CurrentInstallSource
{
    param( 
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$MainVersion,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$NewInstallSource
    )

    $CurrentInstallSource = Get-CurrentInstallSource -MainVersion $MainVersion -ErrorAction Stop
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    Get-ChildItem -ErrorAction SilentlyContinue -path  "HKCR:\Installer\Products" -Recurse |
    foreach {
        Get-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::$_" | 
        foreach {
            $CurrentUserShellFoldersPath = $_.PSPath
            $SID = $CurrentUserShellFoldersPath.Split('\')[2]
            $_.PSObject.Properties |
            foreach {                
                if ($_.Value -like "$($CurrentInstallSource)*") {
                    Write-Verbose -Message "Path:`t`t"$CurrentUserShellFoldersPath
                    Write-Verbose -Message "SID:`t`t"$SID
                    Write-Verbose -Message "Name:`t`t"$_.Name
                    Write-Verbose -Message "Old Value:`t"$_.Value
                    $newValue = ($_.Value).Replace($CurrentInstallSource,$NewInstallSource)
                    Write-Verbose -Message "New Value:`t"$newValue
                    Set-ItemProperty -Path $CurrentUserShellFoldersPath -Name $_.Name -Value $newValue
                    Write-Verbose -Message "================================================================"
                }
            }
        }
    }
    Remove-PSDrive -Name HKCR -Force -ErrorAction SilentlyContinue
    Update-RegistryStringValue -RegistryPath "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DynamicsNav$MainVersion" -Name "InstallSource" -Value $installWorkFolder
    Update-RegistryStringValue -RegistryPath "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DynamicsNav$MainVersion" -Name "SourcePath" -Value $installWorkFolder

}