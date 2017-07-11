Function Set-NAVRemoteInstanceDefaults {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstance
    )
    PROCESS 
    { 
        
        Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$ServerInstance)
                Write-Host "Setting Service Instance $($ServerInstance.ServerInstance) Default Settings..."
                if ($ServerInstance.ServicesCertificateThumbprint -eq "") { 
                    $ServerInstance.ServicesCertificateThumbprint = (Get-ChildItem Cert:\LocalMachine\My | Where-Object -Property Subject -Like 'CN=?.*' | Select-Object -First 1).Thumbprint
                }
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Set-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance -Stop               
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName ServicesCertificateThumbprint -KeyValue $ServerInstance.ServicesCertificateThumbprint
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName ClientServicesCredentialType -KeyValue $ServerInstance.ClientServicesCredentialType
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName SOAPServicesSSLEnabled -KeyValue true
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName ODataServicesSSLEnabled -KeyValue true
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName SOAPServicesEnabled -KeyValue false
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName ODataServicesEnabled -KeyValue false
                UnLoad-InstanceAdminTools
            } -ArgumentList $ServerInstance -ErrorAction Stop        
    }    
}