Function Upgrade-NAVRemoteAdvaniaGatewayConfig {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                #Update Advania.Electronic.Gateway.Config
                if ($SetupParameters.ftpServer -gt "") {
                    try { Get-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath "Advania.Electronic.Gateway.Config" -LocalFilePath (Join-Path $setupParameters.navServicePath "Advania.Electronic.Gateway.Config") }
                    catch { }
                }
            }
    }    
}