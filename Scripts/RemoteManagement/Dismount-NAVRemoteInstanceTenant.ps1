Function Dismount-NAVRemoteInstanceTenant
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )
    PROCESS 
    {
        $confirmTenantId = Read-Host -Prompt "Confirm dismount by typing the tenant id ($($SelectedTenant.Id))"
        if ($confirmTenantId -ieq $SelectedTenant.Id) {
            $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$SelectedTenant)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Write-Verbose "Dismounting tenant $($SelectedTenant.Id)..."
                Dismount-NAVTenant -ServerInstance $SelectedTenant.ServerInstance -Tenant $SelectedTenant.Id -Force
                UnLoad-InstanceAdminTools
            } -ArgumentList $SelectedTenant
        }
        if ($SelectedTenant.ClickOnceHost) {
            $DnsZone = Get-NAVAzureDnsZone -DnsHostName $SelectedTenant.ClickOnceHost
            if ($DnsZone) {
                Remove-NAVAzureDnsZoneRecordSet -DnsZone $DnsZone -DnsHostName $SelectedTenant.ClickOnceHost 
            }
        }

    }    
}