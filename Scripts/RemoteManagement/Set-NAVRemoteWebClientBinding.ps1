Function Set-NAVRemoteWebClientBinding {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ServicesCertificateThumbprint
    )
    PROCESS 
    {
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServicesCertificateThumbprint)
                Write-Host "Update Web Client Bindings..."

                $certificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq $ServicesCertificateThumbprint} 
                $WebSite = Get-Website | Where-Object -Property Name -like "*Web Client"
                $WebSite | Stop-Website
                $WebSite | Get-WebBinding | Remove-WebBinding 
                New-WebBinding -Protocol "https" -Port 443 -Name $WebSite.Name
                (Get-WebBinding -Protocol "https" -Port 443 -Name $WebSite.Name).AddSslCertificate($ServicesCertificateThumbprint, "MY")
                $WebSite | Start-Website

            } -ArgumentList ($ServicesCertificateThumbprint)
    }    
}