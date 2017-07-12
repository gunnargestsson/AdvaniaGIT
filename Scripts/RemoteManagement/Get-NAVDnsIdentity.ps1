Function Get-NAVDnsIdentity {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {
        for ($i=1
            $i -lt ((Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)).Split('.').Count
            $i++) 
        {
            if ($DnsIdentity) {
                $DnsIdentity += "." + ((Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)).Split('.').GetValue($i)
            } else {
                $DnsIdentity = ((Split-Path (Split-Path $SelectedInstance.PublicWinBaseUrl -Parent) -Leaf).Split(':').GetValue(0)).Split('.').GetValue($i)
            }
        }
        return $DnsIdentity
    }
}
