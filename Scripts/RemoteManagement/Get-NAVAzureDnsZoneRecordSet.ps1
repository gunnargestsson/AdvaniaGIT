Function Get-NAVAzureDnsZoneRecordSet {
    param(

        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$DnsZone,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DnsHostName
    )

    if (!$DnsZone) { $DnsZone = Get-AzureDnsZone -DnsHostName $DnsHostName }
    $DnsRecordSetEntry = Get-AzureRmDnsRecordSet -Name $DnsHostName.Split('.').GetValue(0) -ZoneName $DnsZone.Name -ResourceGroupName $DnsZone.ResourceGroupName 
    Return $DnsRecordSetEntry
}