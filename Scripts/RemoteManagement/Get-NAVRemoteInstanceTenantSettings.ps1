Function Get-NAVRemoteInstanceTenantSettings {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $TenantSettings = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([String]$ServerInstance, [String]$TenantId)
                $Tenant = New-Object -TypeName PSObject
                $Tenant | Add-Member -MemberType NoteProperty -Name Id -Value $TenantId
                $Tenant | Add-Member -MemberType NoteProperty -Name ServerInstance -Value "MicrosoftDynamicsNavServer`$$ServerInstance"
                $TenantSettings = Get-TenantSettings -Tenant $Tenant
                Return $TenantSettings
            } -ArgumentList ($SelectedTenant.ServerInstance, $SelectedTenant.Id)
        Return $TenantSettings
    }    
}