Function Get-NAVAzureDnsZone {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DnsHostName
    )

    for ($i=1
     $i -lt ($DnsHostName.Split('.').Count)
     $i++){
        if ($ZoneName) {
            $ZoneName += "." + $DnsHostName.Split('.').GetValue($i)
        } else {
            $ZoneName = $DnsHostName.Split('.').GetValue($i)
        }
     }

     $DnsZones = Get-AzureRmDnsZone
     $DnsZone = $DnsZones | Where-Object -Property Name -EQ $ZoneName
     Return $DnsZone
}
