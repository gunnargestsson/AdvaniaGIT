Function Start-NAVRemoteInstallationRepair {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                $Language = Get-InstalledLanguage -SetupParameters $SetupParameters
                $installWorkFolder = Join-Path $SetupParameters.rootPath "$($SetupParameters.navRelease)$($Language)\"
                Update-CurrentInstallSource -MainVersion $SetupParameters.mainVersion -NewInstallSource $installWorkFolder
                Write-Host "Starting $($SetupParameters.navRelease) update by running $(Join-Path $installWorkFolder "Setup.exe") /quiet /repair ..."
                Start-Process -FilePath (Join-Path $installWorkFolder "Setup.exe") -ArgumentList "/quiet /repair" -Wait
                Write-Host "$($SetupParameters.navRelease) updated!"
            } 
    }    
}