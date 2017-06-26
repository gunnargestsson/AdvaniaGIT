Function Prepare-NAVRemoteClickOnceSite {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$RemoteComputer
        )
    PROCESS
    {
        # Do some tests and import modules 
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$HostConfig)
                if (!(Test-Path $SetupParameters.MageExeLocation)) {
                    Throw "Mage.exe not found on $($HostConfig.FQDN)!"
                }

                if (!(Test-Path $SetupParameters.codeSigningCertificate)) {
                    Throw "Code Signing Certificate not found on $($HostConfig.FQDN)!"
                }

                if ($SetupParameters.codeSigningCertificatePassword -eq "") {
                    Throw "Password for Code Signing Certificate not found on $($HostConfig.FQDN)!"
                }

                Write-Host "Importing NAV DVD Management Module..."
                $NAVDVDFilePath = $HostConfig.NAVDVDPath
                $NAVModulePath = Join-Path $NAVDVDFilePath "WindowsPowerShellScripts\Cloud\NAVAdministration\NAVAdministration.psm1"
                if (Test-Path $NAVModulePath) {
                    Import-Module $NAVModulePath -DisableNameChecking -ErrorAction Stop
                } else {
                    Throw "NAV DVD Module not found on $($HostConfig.FQDN)!"
                }

                Write-Host "Importing IIS Management PowerShell Module..."
                Import-Module WebAdministration

            } -ArgumentList $RemoteComputer
        Return $Result
    }
}