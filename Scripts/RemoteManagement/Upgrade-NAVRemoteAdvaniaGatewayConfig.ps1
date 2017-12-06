Function Upgrade-NAVRemoteAdvaniaGatewayConfig {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [String]$FTPServer,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [String]$FTPUserName,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [String]$FTPPassWord
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                #Update Advania.Electronic.Gateway.Config
                param([String]$FTPServer,[String]$FTPUserName,[String]$FTPPassWord)

                if (!(Test-Path (Join-Path $setupParameters.navServicePath "Advania.Electronic.Gateway.Config"))) {
                    if ($FTPServer -gt "" -and $FTPUserName -gt "" -and $FTPPassWord -gt "") {
                        try { Get-FtpFile -Server $FTPServer -User $FTPUserName -Pass $FTPPassWord -FtpFilePath "Advania.Electronic.Gateway.Config" -LocalFilePath (Join-Path $setupParameters.navServicePath "Advania.Electronic.Gateway.Config") }
                        catch { }
                    }
                }
            } -ArgumentList ($FTPServer,$FTPUserName,$FTPPassWord)
    }    
}