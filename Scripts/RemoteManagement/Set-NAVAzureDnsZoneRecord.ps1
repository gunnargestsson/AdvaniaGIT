Function Set-NAVAzureDnsZoneRecord {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DnsHostName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$OldDnsHostName
        )
    Write-Host "Updating DNS Record for ${DnsHostName}..."
    $DnsZone = Get-NAVAzureDnsZone  -DnsHostName $DnsHostName 
    if ($OldDnsHostName) { Remove-NAVAzureDnsZoneRecordSet  -DnsZone $DnsZone -DnsHostName $OldDnsHostName }
    if ($DnsHostName) { Remove-NAVAzureDnsZoneRecordSet  -DnsZone $DnsZone -DnsHostName $DnsHostName }

    $RemoteConfig = Get-NAVRemoteConfig
    $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
    if (!$Remotes.ClickOnceEndpoint) { Throw "ClickOnce Endpoint not defined for deployment $DeploymentName!" }

    if ($DnsHostName -gt "") {
        $DnsRecord = New-AzureRmDnsRecordSet -Name $DnsHostName.Split('.').GetValue(0) -ZoneName $DnsZone.Name -ResourceGroupName $DnsZone.ResourceGroupName -Ttl 3600 -RecordType CNAME -DnsRecords (New-AzureRmDnsRecordConfig -Cname $Remotes.ClickOnceEndpoint)
    }
}
           