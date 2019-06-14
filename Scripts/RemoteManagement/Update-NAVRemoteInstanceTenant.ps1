Function Update-NAVRemoteInstanceTenant {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Database
    )
    PROCESS 
    {
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(                    
                    [PSObject]$SelectedTenant,
                    [PSObject]$Database
                    )
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters

                $DatabaseCredentials = New-Object System.Management.Automation.PSCredential($Database.DatabaseUserName, (ConvertTo-SecureString $Database.DatabasePassword -AsPlainText -Force))
                Write-Host "Updating $($Database.DatabaseName)..."
                $Param = @{
                    ServerInstance = $SelectedTenant.ServerInstance
                    Id = "Default"
                    DatabaseName = $Database.DatabaseName
                    DatabaseServer = $Database.DatabaseServerName
                    DatabaseCredentials = $DatabaseCredentials
                    Force = $true
                }

                Mount-NAVTenant @Param
                Sync-NAVTenant -ServerInstance $SelectedTenant.ServerInstance -Tenant Default -Mode Sync -Force
                Dismount-NAVTenant -ServerInstance $SelectedTenant.ServerInstance -Id Default -Force
                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant, 
                $Database)
    }    
}