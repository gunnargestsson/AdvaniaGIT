Function Set-NAVRemoteInstanceADRegistration {
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
                param([PSObject]$ServerInstance)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Write-Host "Stopping Instance $($ServerInstance.ServerInstance)..."
                Set-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance -Stop
                Write-Host "Updating Settings..."
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName AppIdUri -KeyValue ($ServerInstance.ADApplicationIdentifierUris | Select-Object -First 1)
                Set-NAVServerConfiguration -ServerInstance $ServerInstance.ServerInstance -KeyName ClientServicesFederationMetadataLocation -KeyValue $ServerInstance.ADApplicationFederationMetadataLocation
                                
                Write-Host "Starting Instance $($ServerInstance.ServerInstance) ..."
                Set-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance -Start
                Get-NAVTenant -ServerInstance $ServerInstance.ServerInstance | Sync-NAVTenant -Mode Sync -Force
                UnLoad-InstanceAdminTools
            } -ArgumentList $ServerInstance
    }
}