Function Mount-NAVRemoteInstanceTenant {
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
                Mount-NAVTenant `
                    -ServerInstance $SelectedTenant.ServerInstance `
                    -Id $SelectedTenant.Id `
                    -DatabaseName $Database.DatabaseName `
                    -DatabaseServer $Database.DatabaseServerName `
                    -AllowAppDatabaseWrite `
                    -AlternateId @($SelectedTenant.ClickOnceHost) `
                    -NasServicesEnabled `
                    -RunNasWithAdminRights `
                    -DatabaseCredentials $DatabaseCredentials 

                UnLoad-InstanceAdminTools
            } -ArgumentList (
                $SelectedTenant, 
                $Database)
    }    
}