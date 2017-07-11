Function Download-NAVRemoteLatestCU {
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
                Download-LatestNAVUpdate -SetupParameters $SetupParameters -InstallWorkFolder $InstallWorkFolder -Language $Language
            } 
    }    
}