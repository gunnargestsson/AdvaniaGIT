Function Set-AzureDnsZoneRecord {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DnsHostName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$OldDnsHostName
        )
    Write-Host "Updating DNS Record..."
    $DnsZone = Get-AzureDnsZone  -DnsHostName $DnsHostName 
    if ($OldDnsHostName) { Remove-AzureDnsZoneRecordSet  -DnsZone $DnsZone -DnsHostName $OldDnsHostName }
    if ($DnsHostName) { Remove-AzureDnsZoneRecordSet  -DnsZone $DnsZone -DnsHostName $DnsHostName }

    $RemoteConfig = Get-RemoteConfig
    $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
    if (!$Remotes.ClickOnceEndpoint) { Throw "ClickOnce Endpoint not defined for deployment $DeploymentName!" }

    if ($DnsHostName -gt "") {
        New-AzureRmDnsRecordSet -Name $DnsHostName.Split('.').GetValue(0) -ZoneName $DnsZone.Name -ResourceGroupName $DnsZone.ResourceGroupName -Ttl 3600 -RecordType CNAME -DnsRecords (New-AzureRmDnsRecordConfig -Cname $Remotes.ClickOnceEndpoint)
    }
}
           