Function Get-NAVServiceCertificateValue {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstance
    )
    PROCESS 
    {
        Write-Host "Downloading Certificate Value..."
        $CertValue = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$ServerInstance)
                $x509 = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object -Property Thumbprint -EQ $ServerInstance.ServicesCertificateThumbprint
                $CertValue = [System.Convert]::ToBase64String($x509.GetRawCertData())
                Return $CertValue
            } -ArgumentList $ServerInstance -ErrorAction Stop
        return $CertValue
    }    
}